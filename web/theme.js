// Runs in <head> before first paint so a saved theme never flashes.
try {
  const saved = localStorage.getItem("theme");
  if (saved === "light" || saved === "dark") {
    document.documentElement.dataset.theme = saved;
  }
} catch {}
