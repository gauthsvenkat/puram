{
  hostCfg,
  ...
}:
let
  inherit (hostCfg.ports) paperless;
  dataRoot = "${hostCfg.paths.data}/paperless-ngx";
  vhost = "paperless.${hostCfg.domain}";
in
{
  services.paperless = {
    enable = true;
    address = "0.0.0.0";
    port = paperless.port;
    dataDir = "${dataRoot}/data";
    mediaDir = "${dataRoot}/media";
    consumptionDir = "${dataRoot}/consume";
    database.createLocally = true;
    configureTika = true;
    settings = {
      PAPERLESS_OCR_LANGUAGE = "eng";
      PAPERLESS_OCR_USER_ARGS.invalidate_digital_signatures = true;
      PAPERLESS_TIKA_ENDPOINT = "http://localhost:${toString paperless.tika_port}";
      PAPERLESS_TIKA_GOTENBERG_ENDPOINT = "http://localhost:${toString paperless.gotenberg_port}";
      PAPERLESS_URL = "https://${vhost}";
      PAPERLESS_USE_X_FORWARD_HOST = true;
    };
  };

  services.gotenberg.port = paperless.gotenberg_port;
  services.tika.port = paperless.tika_port;

  services.caddy.virtualHosts.${vhost}.extraConfig = ''
    reverse_proxy 127.0.0.1:${toString paperless.port}
  '';

  networking.firewall.allowedTCPPorts = [ paperless.port ];
}
