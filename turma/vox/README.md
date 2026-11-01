# Vox — private media server

Turma-line node. Media streaming over the tailnet only.

Vox streams movies, music, and TV shows to the fleet — no
public access, no transcoding, just file serving at native
speed. It sits between Horreum (storage) and the end users
(phones, laptops, TVs on the tailnet). Like Lumen, it
serves media; unlike Lumen, it never touches the internet.

## What's inside

**Plex / Jellyfin** — media library management and streaming.
Client discovery happens on the tailnet; no public port
forwarding. Transcoding is disabled unless explicitly needed,
so CPU load stays low and latency stays low.

**Storage** — mounts large datasets from Horreum (the NAS
node). Vox is the streaming interface; Horreum is the data
layer. They're logically separated so media storage can grow
independently of streaming hardware.

**Subtitles** — embedded where possible, or served from a
local subtitle index. External subtitle fetching respects
the tailnet boundary.

## Difference from Lumen

Both serve files over HTTP; only Lumen touches the public
internet. Vox's Caddyfile listens on internal addresses
only, no ACME, no public firewall zone. Media traffic
doesn't compete with Lumen's HTTP load.

## Planned

- Subtitle indexing and matching automation
- Library metadata repair scripts
- Backup sync from Horreum (if not mirrored there)
- Client device whitelisting if the library grows