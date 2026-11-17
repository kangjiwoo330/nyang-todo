// 냥이 투두 - 오프라인 실행용 서비스 워커
// 앱 파일만 저장해 두고, 인터넷이 될 때는 새 버전을 받아 다음 실행 때 반영합니다.
// 할 일 데이터는 여기서 다루지 않습니다 (브라우저 localStorage에만 저장).
const CACHE = 'nyang-todo-v1';
const FILES = ['./', './index.html', './manifest.webmanifest', './cat.ico',
               './icon-192.png', './icon-512.png', './icon-maskable-512.png', './apple-touch-icon.png'];

self.addEventListener('install', e => {
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(FILES)).then(() => self.skipWaiting()));
});

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys()
      .then(keys => Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', e => {
  const req = e.request;
  if (req.method !== 'GET' || new URL(req.url).origin !== location.origin) return;
  e.respondWith(
    caches.open(CACHE).then(async cache => {
      const cached = await cache.match(req, { ignoreSearch: true });
      const fresh = fetch(req).then(res => {
        if (res && res.ok) cache.put(req, res.clone());
        return res;
      }).catch(() => cached);
      return cached || fresh;
    })
  );
});
