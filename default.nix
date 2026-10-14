{
  config,
  pkgs,
  lib,
  ...
}:

let
  user = config.common.username;
  cfg = config.services.slskdClient;
in
{
  options.services.slskdClient = {
    enable = lib.mkEnableOption "slskd (Soulseek music sharing)";
    downloadPath = lib.mkOption {
      type = lib.types.str;
      default = "/away/main/Downloads";
      description = "Download directory for slskd.";
    };
    environmentFile = lib.mkOption {
      type = lib.types.str;
      default = "/etc/slskd/env";
      description = "Environment file for slskd (host should provide via secrets).";
    };
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Open Soulseek firewall ports (5030/tcp and udp).";
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups.downloads = { };

    users.users.${user} = {
      extraGroups = lib.mkAfter [ "downloads" ];
    };

    users.users.slskd.extraGroups = [ "downloads" ];

    networking.firewall.allowedTCPPorts = lib.mkAfter [ 5030 ];
    networking.firewall.allowedUDPPorts = lib.mkAfter [ 5030 ];

    services.slskd = {
      enable = true;
      openFirewall = cfg.openFirewall;
      environmentFile = cfg.environmentFile;
      settings = {
        web.authentication.disabled = true;
        directories.downloads = cfg.downloadPath;
      };
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.downloadPath} 2775 ${user} downloads -"
    ];

    systemd.services.slskd.serviceConfig.UMask = lib.mkForce "0002";
  };
}
