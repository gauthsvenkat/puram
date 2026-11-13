{
  flakeCfg,
  targetCfg,
  ...
}:
let
  inherit (flakeCfg) domain;
  inherit (targetCfg) paths ports;
  dataRoot = "${paths.data}/paperless-ngx";
  vhost = "paperless.${domain}";
in
{
  services = {
    gotenberg.port = ports.paperless-gotenberg;
    tika.port = ports.paperless-tika;

    paperless = {
      enable = true;
      address = "0.0.0.0";
      configureTika = true;
      consumptionDir = "${dataRoot}/consume";
      dataDir = "${dataRoot}/data";
      database.createLocally = true;
      mediaDir = "${dataRoot}/media";
      port = ports.paperless;
      settings = {
        PAPERLESS_OCR_LANGUAGE = "eng";
        PAPERLESS_OCR_USER_ARGS.invalidate_digital_signatures = true;
        PAPERLESS_URL = "https://${vhost}";
        PAPERLESS_USE_X_FORWARD_HOST = true;
      };
    };
  };
}
