{
  targetCfg,
  ...
}:
let
  inherit (targetCfg) domain paths;
  inherit (targetCfg.ports) paperless;
  dataRoot = "${paths.data}/paperless-ngx";
  vhost = "paperless.${domain}";
in
{
  services = {
    paperless = {
      enable = true;
      address = "0.0.0.0";
      inherit (paperless) port;
      dataDir = "${dataRoot}/data";
      mediaDir = "${dataRoot}/media";
      consumptionDir = "${dataRoot}/consume";
      database.createLocally = true;
      configureTika = true;
      settings = {
        PAPERLESS_OCR_LANGUAGE = "eng";
        PAPERLESS_OCR_USER_ARGS.invalidate_digital_signatures = true;
        PAPERLESS_URL = "https://${vhost}";
        PAPERLESS_USE_X_FORWARD_HOST = true;
      };
    };

    gotenberg.port = paperless.gotenberg_port;
    tika.port = paperless.tika_port;
  };
}
