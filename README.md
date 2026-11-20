# slskd

Soulseek via [slskd](https://github.com/slskd/slskd): service config, `downloads` group membership, firewall **5030/tcp** (web UI) and **50300/tcp+udp** (Soulseek listen, via nixpkgs + UDP).

NixOS only. Requires `./common`. Host must supply `environment.etc."slskd/env"` (see SRVR `secrets.nix`). Not related to Transmission; both may use the same download path on the host.

Import `./src/slskd` in `configuration.nix` to activate. Opt out with `services.slskdClient.enable = false` or remove the import.

The wrapper sets `HOME=/var/lib/slskd` and relaxes nixpkgs systemd sandbox flags so slskd’s singleton mutex and web UI can start (default `HOME` is `/var/empty`, which breaks .NET mutex creation under `ProtectSystem=strict`).
