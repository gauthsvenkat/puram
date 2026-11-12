{
  flakeCfg,
  targetCfg,
  ...
}:
let
  inherit (flakeCfg) domain;
  inherit (targetCfg) paths;
  inherit (targetCfg.ports) paperless;
  dataRoot = "${paths.data}/paperless-ngx";
  vhost = "paperless.${domain}";
in
{
  services = {
    gotenberg.port = paperless.gotenberg_port;
    tika.port = paperless.tika_port;

    paperless = {
      enable = true;
      address = "0.0.0.0";
      configureTika = true;
      consumptionDir = "${dataRoot}/consume";
      dataDir = "${dataRoot}/data";
      database.createLocally = true;
      mediaDir = "${dataRoot}/media";
      inherit (paperless) port;
      settings = {
        PAPERLESS_OCR_LANGUAGE = "eng";
        PAPERLESS_OCR_USER_ARGS.invalidate_digital_signatures = true;
        PAPERLESS_URL = "https://${vhost}";
        PAPERLESS_USE_X_FORWARD_HOST = true;
      };
    };
  };
}
