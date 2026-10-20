# legion turma:vox - Media server deployment

## First-boot steps

1. Boot the node, join Tailscale:
   ```bash
   sudo tsh login

    Deploy the Jellyfin quadlet:

   mkdir -p ~/.config/containers/systemd
   # Copy/create quadlet file (see docs/quadlets/jellyfin.container)
   sudo systemctl daemon-reload
   sudo systemctl start jellyfin

    Point Jellyfin at your media storage:
        Configure libraries in Jellyfin web UI (tailscale-ip:8096)
        Map /media mount points to NAS/Horreum storage

    Enable hardware transcoding in Jellyfin:
        Settings → Playback → Hardware acceleration: VA-API
        Device: /dev/dri/renderD128


This doesn't get committed to the image itself — it's documentation for first boot.