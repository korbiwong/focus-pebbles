// Focus Pebbles offline support: keep the app files on the device so it opens without internet.
// Bump VERSION whenever index.html changes, so devices pick up the new copy.
const VERSION = "fp-v13";
const APP = ["./", "index.html", "manifest.webmanifest", "firebase-config.js","icons/icon.svg", "icons/icon-180.png", "icons/icon-192.png", "icons/icon-512.png"];

self.addEventListener("install", e => {
  e.waitUntil(caches.open(VERSION).then(c => c.addAll(APP)).then(() => self.skipWaiting()));
});

self.addEventListener("activate", e => {
  e.waitUntil(caches.keys()
    .then(keys => Promise.all(keys.filter(k => k !== VERSION).map(k => caches.delete(k))))
    .then(() => self.clients.claim()));
});

self.addEventListener("fetch", e => {
  const req = e.request;
  if (req.method !== "GET") return;
  const url = new URL(req.url);

  // The page itself: try the network first so updates show up, fall back to the saved copy offline.
  if (req.mode === "navigate") {
    e.respondWith(fetch(req)
      .then(res => { const copy = res.clone(); caches.open(VERSION).then(c => c.put("index.html", copy)); return res; })
      .catch(() => caches.match("index.html")));
    return;
  }

  // Your sign-in setup: fetch fresh when online so a new config takes effect, saved copy when offline.
  if (url.origin === location.origin && url.pathname.endsWith("/firebase-config.js")) {
    e.respondWith(fetch(req, { cache: "no-store" }).then(res => { const copy = res.clone(); caches.open(VERSION).then(c => c.put(req, copy)); return res; })
      .catch(() => caches.match(req)));
    return;
  }

  // App files, Google Fonts and the Firebase library: use the saved copy, and save anything new.
  // (Firebase sign-in and sync requests are not cached; they always go to the network.)
  if (url.origin === location.origin || url.hostname.endsWith("fonts.googleapis.com") || url.hostname.endsWith("fonts.gstatic.com")
      || (url.hostname === "www.gstatic.com" && url.pathname.startsWith("/firebasejs/"))) {
    e.respondWith(caches.match(req).then(hit => hit || fetch(req).then(res => {
      if (res.ok || res.type === "opaque") { const copy = res.clone(); caches.open(VERSION).then(c => c.put(req, copy)); }
      return res;
    })));
  }
});
