"use strict";

const copyStatus = document.querySelector(".copy-status");
for (const button of document.querySelectorAll("[data-copy]")) {
  button.hidden = false;
  button.addEventListener("click", async () => {
    const source = document.getElementById(button.dataset.copy);
    copyStatus.textContent = "";
    try {
      if (!navigator.clipboard?.writeText || !source) throw new Error("Clipboard unavailable");
      await navigator.clipboard.writeText(source.textContent);
      copyStatus.textContent = "Code copied.";
    } catch {
      copyStatus.textContent = "Select the code to copy it.";
    }
  });
}
