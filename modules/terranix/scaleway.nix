{
  targetCfg,
  targetCfgs,
  lib,
  ...
}:
let
  inherit (targetCfg.scaleway) orgId;
in
{
  provider.scaleway = {
    inherit (targetCfg.scaleway) region;
    project_id = orgId;
  };

  resource = {
    scaleway_iam_api_key = {
      "opentofu" = {
        application_id = lib.tf.ref "scaleway_iam_application.opentofu.id";
        default_project_id = orgId;
        description = "opentofu provisioning";
        expires_at = "2027-08-25T22:00:00Z";
        # The apply runs on this key, so create its successor before revoking it.
        lifecycle.create_before_destroy = true;
      };
      "restic" = {
        application_id = lib.tf.ref "scaleway_iam_application.restic.id";
        default_project_id = orgId;
        description = "For restic backups from elitedesk";
        # NOTE: Rotate before this; the offsite backup unit will fails otherwise.
        expires_at = "2027-07-30T15:11:28Z";
      };
    };

    scaleway_iam_application = {
      "opentofu".name = "opentofu-infra";
      "restic" = {
        name = "restic-elitedesk";
        description = "restic backups from elitedesk";
      };
    };

    scaleway_iam_policy = {
      # NOTE: tofu's own credentials.
      "opentofu" = {
        name = "opentofu";
        application_id = lib.tf.ref "scaleway_iam_application.opentofu.id";
        rule = [
          {
            permission_set_names = [
              "ObjectStorageBucketsRead"
              "ObjectStorageBucketsWrite"
              "ObjectStorageObjectsRead"
            ];
            project_ids = [ orgId ];
          }
          {
            permission_set_names = [ "IAMManager" ];
            organization_id = orgId;
          }
        ];
      };
      "restic" = {
        name = "Object Storage access";
        application_id = lib.tf.ref "scaleway_iam_application.restic.id";
        rule = [
          {
            permission_set_names = [ "ObjectStorageFullAccess" ];
            project_ids = [ orgId ];
          }
        ];
      };
    };

    scaleway_object_bucket."elitedesk_backup" = {
      name = targetCfgs.nixos."elitedesk".offsiteBucket;
      force_destroy = false;
      # NOTE: Only clean up uploads that never completed (interrupted restic runs).
      # Never add object expiration: restic owns deletion, and age-based expiry
      # corrupts the repository.
      lifecycle_rule = [
        {
          id = "abort-incomplete-multipart-uploads";
          enabled = true;
          abort_incomplete_multipart_upload_days = 7;
        }
      ];
    };
  };

  output = {
    scaleway_backups_access_key = {
      value = lib.tf.ref "scaleway_iam_api_key.restic.access_key";
      sensitive = true;
    };
    scaleway_backups_secret_key = {
      value = lib.tf.ref "scaleway_iam_api_key.restic.secret_key";
      sensitive = true;
    };
    scw_access_key = {
      value = lib.tf.ref "scaleway_iam_api_key.opentofu.access_key";
      sensitive = true;
    };
    scw_secret_key = {
      value = lib.tf.ref "scaleway_iam_api_key.opentofu.secret_key";
      sensitive = true;
    };
  };
}
