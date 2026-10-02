"use strict";

const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const modules = process.env.BROWSER_TEST_MODULES;
const { chromium } = require(modules ? path.join(modules, "playwright") : "playwright");
const AxeBuilder = require(modules ? path.join(modules, "@axe-core/playwright") : "@axe-core/playwright").default;
const root = path.resolve(__dirname, "../..");
const baseURL = process.env.SITE_URL || "http://127.0.0.1:8765/";
const artifacts = path.join(root, "artifacts");
const entries = JSON.parse(fs.readFileSync(path.join(root, "content/entries.json"), "utf8"));
fs.mkdirSync(artifacts, { recursive: true });

async function run() {
  const browser = await chromium.launch(process.env.BROWSER_CHANNEL ? { channel: process.env.BROWSER_CHANNEL } : {});
  const report = { entries: entries.length, layouts: [], find: [], requests: [], axeViolations: 0 };
  try {
    const context = await browser.newContext({ viewport: { width: 1440, height: 1000 }, permissions: ["clipboard-read", "clipboard-write"] });
    const page = await context.newPage();
    const errors = [];
    page.on("pageerror", error => errors.push(String(error)));
    page.on("request", request => report.requests.push(request.url()));
    await page.addInitScript(() => {
      window.layoutShiftTotal = 0;
      new PerformanceObserver(list => {
        for (const entry of list.getEntries()) {
          if (!entry.hadRecentInput) window.layoutShiftTotal += entry.value;
        }
      }).observe({ type: "layout-shift", buffered: true });
    });
    await page.goto(baseURL);
    assert.equal(await page.locator("article").count(), entries.length);
    for (const entry of entries) {
      assert.equal(await page.locator(`#code-${entry.id}`).textContent(), fs.readFileSync(path.join(root, entry.file), "utf8"));
      assert(await page.locator(`#${entry.id}`).isVisible());
    }
    await page.keyboard.press("Tab");
    assert.equal(await page.locator(":focus").textContent(), "Skip to reference");
    await page.screenshot({ path: path.join(artifacts, "keyboard-focus.png") });
    await page.keyboard.press("Enter");
    assert.equal(await page.locator(":focus").getAttribute("id"), "main");
    await page.evaluate(() => { document.activeElement.blur(); window.scrollTo(0, 0); });
    await page.screenshot({ path: path.join(artifacts, "desktop.png") });
    for (const query of ["dollars", "heapify", "lower bound", "Djikstra", "@Bindable", "prepareForReuse", "weak delegate", "rounding", "String.Index", "UIHostingController"]) {
      const result = await page.evaluate(text => {
        window.getSelection().removeAllRanges();
        window.scrollTo(0, 0);
        const started = performance.now();
        const found = window.find(text, false, false, true);
        return { query: text, found, elapsedMs: performance.now() - started };
      }, query);
      assert(result.found, `Native find missed ${query}`);
      report.find.push(result);
    }
    await page.locator('[data-copy="code-currency"]').click();
    assert.equal(await page.evaluate(() => navigator.clipboard.readText()), fs.readFileSync(path.join(root, "examples/dsa/Money.swift"), "utf8"));
    assert.equal(await page.locator('#currency [role="status"]').textContent(), "Code copied.");
    await page.locator('.section-nav a[href="#swiftui"]').click();
    await page.locator('.section-nav a[href="#uikit"]').click();
    await page.goBack();
    assert.equal(new URL(page.url()).hash, "#swiftui");
    await page.goForward();
    assert.equal(new URL(page.url()).hash, "#uikit");
    await page.goto(baseURL + "#unknown-topic");
    assert.equal(await page.locator("article").count(), entries.length);

    for (const layout of [
      { name: "desktop", width: 1440, height: 1000, colorScheme: "light" },
      { name: "half-width", width: 720, height: 1000, colorScheme: "light" },
      { name: "narrow", width: 320, height: 900, colorScheme: "light" },
      { name: "dark", width: 1440, height: 1000, colorScheme: "dark" }
    ]) {
      await page.setViewportSize({ width: layout.width, height: layout.height });
      await page.emulateMedia({ colorScheme: layout.colorScheme, reducedMotion: "reduce" });
      await page.goto(baseURL + "#currency");
      const overflow = await page.evaluate(() => document.documentElement.scrollWidth > innerWidth);
      assert(!overflow, `${layout.name} has page overflow`);
      const audit = await new AxeBuilder({ page }).withTags(["wcag2a", "wcag2aa", "wcag21aa", "wcag22aa"]).analyze();
      report.axeViolations += audit.violations.length;
      assert.deepEqual(audit.violations.map(violation => ({ id: violation.id, nodes: violation.nodes.map(node => node.target) })), [], `${layout.name} accessibility audit`);
      await page.screenshot({ path: path.join(artifacts, `${layout.name}-currency.png`) });
      report.layouts.push({ ...layout, overflow, axeViolations: audit.violations.length });
    }
    await page.setViewportSize({ width: 640, height: 900 });
    await page.addStyleTag({ content: "html { font-size: 200%; }" });
    assert.equal(await page.evaluate(() => document.documentElement.scrollWidth > innerWidth), false);
    await page.screenshot({ path: path.join(artifacts, "text-200-percent.png") });
    await page.emulateMedia({ forcedColors: "active" });
    await page.screenshot({ path: path.join(artifacts, "forced-colors.png") });
    assert.equal(await page.locator("#currency").isVisible(), true);
    report.layoutShiftTotal = await page.evaluate(() => window.layoutShiftTotal);
    assert(report.layoutShiftTotal < 0.01, "Unexpected layout shift");
    assert.deepEqual(errors, []);
    assert(report.requests.every(url => new URL(url).origin === new URL(baseURL).origin));
    await context.close();

    const baseline = await browser.newContext({ javaScriptEnabled: false, viewport: { width: 320, height: 900 } });
    const plain = await baseline.newPage();
    await plain.goto(baseURL + "#dijkstra");
    assert.equal(await plain.locator("article").count(), entries.length);
    assert.equal(await plain.locator(".copy:visible").count(), 0);
    assert.equal(await plain.locator("#code-dijkstra").textContent(), fs.readFileSync(path.join(root, "examples/dsa/Dijkstra.swift"), "utf8"));
    await plain.screenshot({ path: path.join(artifacts, "no-javascript.png") });
    await baseline.close();

    const failures = await browser.newContext();
    await failures.addInitScript(() => {
      Object.defineProperty(navigator, "clipboard", { value: { writeText: async () => { throw new Error("Denied"); } } });
      Object.defineProperty(window, "localStorage", { get() { throw new Error("Blocked"); } });
    });
    const fallback = await failures.newPage();
    await fallback.goto(baseURL + "#heap");
    await fallback.locator('[data-copy="code-heap"]').click();
    assert.equal(await fallback.locator('#heap [role="status"]').textContent(), "Select the code to copy it.");
    assert.equal(await fallback.locator("#code-heap").isVisible(), true);
    await fallback.screenshot({ path: path.join(artifacts, "copy-failure.png") });
    await failures.close();
    report.requests = [...new Set(report.requests)];
    fs.writeFileSync(path.join(artifacts, "browser-results.json"), JSON.stringify(report, null, 2));
    console.log(JSON.stringify(report, null, 2));
  } finally {
    await browser.close();
  }
}

run().catch(error => { console.error(error); process.exitCode = 1; });
