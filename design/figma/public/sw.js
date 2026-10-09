// Sari service worker: makes the app work with no internet.
// Install: cache the app shell and every hashed asset it references (JS, CSS, fonts, mascot images).
// Fetch: network-first for navigations (fallback to cache), cache-first for same-origin assets.
const CACHE = "sari-shell-v4";
const ASSET_RE = /[^"'()\s]+\.(?:js|css|png|webp|jpe?g|svg|woff2?|mp4|webm|mov)/g;

async function precache() {
  const cache = await caches.open(CACHE);
  const root = new URL("./", self.location).href;
  const html = await (await fetch(root, { cache: "reload" })).text();
  await cache.put(root, new Response(html, { headers: { "Content-Type": "text/html" } }));

  const urls = new Set(["manifest.webmanifest", "icons/icon-192.png", "icons/icon-512.png", "icons/apple-touch-icon.png", "icons/favicon.ico", "icons/favicon-32.png", "icons/favicon-48.png", "icons/icon-maskable-512.png"].map((p) => new URL(p, root).href));
  for (const m of html.matchAll(/(?:src|href)="([^"]+)"/g)) urls.add(new URL(m[1], root).href);

  // Assets referenced from the JS/CSS bundles (fonts, mascot poses) are discovered one level deep.
  for (const url of [...urls].filter((u) => /\.(js|css)$/.test(u))) {
    const text = await (await fetch(url)).text();
    for (const m of text.matchAll(ASSET_RE)) {
      try { urls.add(new URL(m[0], url).href); } catch { /* ignore */ }
    }
  }
  await Promise.all([...urls].filter((u) => u.startsWith(self.location.origin)).map((u) => cache.add(u).catch(() => {})));
}

self.addEventListener("install", (event) => {
  event.waitUntil(precache().then(() => self.skipWaiting()));
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys().then((keys) => Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k)))).then(() => self.clients.claim()),
  );
});

self.addEventListener("fetch", (event) => {
  const req = event.request;
  if (req.method !== "GET" || new URL(req.url).origin !== self.location.origin) return;

  if (req.mode === "navigate") {
    event.respondWith(
      fetch(req).then((res) => {
        const copy = res.clone();
        caches.open(CACHE).then((c) => c.put(new URL("./", self.location).href, copy));
        return res;
      }).catch(() => caches.match(new URL("./", self.location).href)),
    );
    return;
  }

  event.respondWith(
    caches.match(req).then((hit) => hit || fetch(req).then((res) => {
      const copy = res.clone();
      caches.open(CACHE).then((c) => c.put(req, copy));
      return res;
    })),
  );
});
