# slskd

Soulseek via [slskd](https://github.com/slskd/slskd): service config, `downloads` group membership, and firewall port 5030.

NixOS only. Requires `./common`. Host must supply `environment.etc."slskd/env"` (see SRVR `secrets.nix`). Not related to Transmission; both may use the same download path on the host.

Import `./src/slskd` in `configuration.nix` to activate. Opt out with `services.slskdClient.enable = false` or remove the import.
