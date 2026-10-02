"use strict";

// Progressive enhancement only: the page is complete without this file.
// Nothing here creates or hides content (decision 001).

const HIGHLIGHT_MS = 1500;
const MAX_RESULTS = 12;

function markCurrentSection() {
  const links = new Map(
    [...document.querySelectorAll(".toc ol ol a")].map((link) => [
      link.hash.slice(1),
      link,
    ]),
  );
  let current = null;
  const observer = new IntersectionObserver(
    (entries) => {
      for (const entry of entries) {
        if (!entry.isIntersecting) continue;
        current?.removeAttribute("aria-current");
        current = links.get(entry.target.id) ?? null;
        current?.setAttribute("aria-current", "location");
      }
    },
    { rootMargin: "-10% 0px -85% 0px" },
  );
  for (const section of document.querySelectorAll("main .section")) {
    observer.observe(section);
  }
}

function jumpTo(id) {
  const target = document.getElementById(id);
  if (!target) return;
  history.replaceState(null, "", `#${id}`);
  target.scrollIntoView({ block: "start" });
  const heading = target.querySelector("h2, h3, h4") ?? target;
  heading.classList.add("is-target");
  heading.setAttribute("tabindex", "-1");
  heading.focus({ preventScroll: true });
  setTimeout(() => heading.classList.remove("is-target"), HIGHLIGHT_MS);
}

function setUpJumpList() {
  const dialog = document.getElementById("jump-dialog");
  const input = document.getElementById("jump-input");
  const results = document.getElementById("jump-results");
  const rows = JSON.parse(document.getElementById("jump-index").textContent);
  const items = rows.map(([id, title, context, keywords, kind]) => ({
    id,
    title,
    context,
    kind,
    lowerTitle: title.toLowerCase(),
    text: `${title} ${context} ${keywords}`.toLowerCase(),
  }));
  let matches = [];
  let active = 0;

  function score(item, query, words) {
    if (!words.every((word) => item.text.includes(word))) return -1;
    if (item.lowerTitle.startsWith(query)) return 0;
    if (item.lowerTitle.includes(query)) return 1;
    return 2;
  }

  function search(query) {
    const cleaned = query.trim().toLowerCase();
    if (!cleaned) return items.filter((item) => item.kind === "section");
    const words = cleaned.split(/\s+/);
    return items
      .map((item, order) => ({ item, order, rank: score(item, cleaned, words) }))
      .filter((match) => match.rank >= 0)
      .sort((a, b) => a.rank - b.rank || a.order - b.order)
      .slice(0, MAX_RESULTS)
      .map((match) => match.item);
  }

  function render() {
    const options = matches.map((item, index) => {
      const option = document.createElement("li");
      option.id = `jump-option-${index}`;
      option.setAttribute("role", "option");
      option.setAttribute("aria-selected", String(index === active));
      const title = document.createElement("span");
      title.textContent = item.title;
      const context = document.createElement("span");
      context.className = "jump-context";
      context.textContent = item.context;
      option.append(title, context);
      option.addEventListener("mousedown", (event) => {
        event.preventDefault();
        choose(index);
      });
      return option;
    });
    if (options.length === 0) {
      const empty = document.createElement("li");
      empty.className = "jump-empty";
      empty.textContent = "No match. Cmd+F searches every word on the page.";
      options.push(empty);
    }
    results.replaceChildren(...options);
    if (matches.length) {
      input.setAttribute("aria-activedescendant", `jump-option-${active}`);
      document.getElementById(`jump-option-${active}`)
        .scrollIntoView({ block: "nearest" });
    } else {
      input.removeAttribute("aria-activedescendant");
    }
  }

  function update() {
    matches = search(input.value);
    active = 0;
    render();
  }

  function choose(index) {
    const item = matches[index];
    if (!item) return;
    dialog.close();
    jumpTo(item.id);
  }

  function open() {
    input.value = "";
    update();
    dialog.showModal();
    input.focus();
  }

  input.addEventListener("input", update);
  input.addEventListener("keydown", (event) => {
    if (event.key === "ArrowDown" || event.key === "ArrowUp") {
      event.preventDefault();
      const step = event.key === "ArrowDown" ? 1 : -1;
      active = (active + step + matches.length) % Math.max(matches.length, 1);
      render();
    } else if (event.key === "Enter") {
      event.preventDefault();
      choose(active);
    }
  });
  dialog.addEventListener("click", (event) => {
    if (event.target === dialog) dialog.close();
  });
  document.getElementById("jump-button").addEventListener("click", open);
  document.addEventListener("keydown", (event) => {
    const typing = event.target instanceof Element
      && event.target.closest("input, textarea, [contenteditable]");
    if (event.key === "/" && !typing && !dialog.open) {
      event.preventDefault();
      open();
    }
  });
}

function entryCode(entry) {
  return [...entry.querySelectorAll("pre code")]
    .map((code) =>
      [...code.querySelectorAll(".line")]
        .map((line) => line.textContent)
        .join("\n"),
    )
    .join("\n\n");
}

function selectCode(entry) {
  const range = document.createRange();
  range.selectNodeContents(entry.querySelector("pre"));
  getSelection().removeAllRanges();
  getSelection().addRange(range);
}

function addCopyButtons() {
  for (const entry of document.querySelectorAll(".entry")) {
    if (!entry.querySelector("pre")) continue;
    const title = entry.querySelector("h4").textContent;
    const button = document.createElement("button");
    button.type = "button";
    button.className = "copy-button";
    button.textContent = "Copy";
    button.setAttribute("aria-label", `Copy code: ${title}`);
    button.addEventListener("click", async () => {
      try {
        await navigator.clipboard.writeText(entryCode(entry));
        button.textContent = "Copied";
      } catch {
        selectCode(entry);
        button.textContent = "Press Cmd+C";
      }
      setTimeout(() => (button.textContent = "Copy"), HIGHLIGHT_MS);
    });
    entry.append(button);
  }
}

function setUpThemeToggle() {
  const root = document.documentElement;
  const button = document.getElementById("theme-button");
  const themes = ["system", "light", "dark"];
  let theme = root.dataset.theme ?? "system";
  const label = () => {
    button.textContent = `Theme: ${theme[0].toUpperCase()}${theme.slice(1)}`;
  };
  button.addEventListener("click", () => {
    theme = themes[(themes.indexOf(theme) + 1) % themes.length];
    try {
      if (theme === "system") localStorage.removeItem("theme");
      else localStorage.setItem("theme", theme);
    } catch {}
    if (theme === "system") delete root.dataset.theme;
    else root.dataset.theme = theme;
    label();
  });
  label();
}

markCurrentSection();
setUpJumpList();
addCopyButtons();
setUpThemeToggle();
document.querySelector(".controls").hidden = false;
