{ targetCfg, lib, ... }:
let
  inherit (targetCfg.scaleway) orgId;
in
{
  provider.scaleway = {
    region = "nl-ams";
    project_id = orgId;
  };

  resource = {
    scaleway_iam_api_key = {
      opentofu = {
        application_id = lib.tf.ref "scaleway_iam_application.opentofu.id";
        default_project_id = orgId;
        description = "opentofu provisioning";
        expires_at = "2027-08-25T22:00:00Z";
        # replacing this key must create the successor before revoking the
        # credential the apply itself is running on
        lifecycle.create_before_destroy = true;
      };
      restic = {
        application_id = lib.tf.ref "scaleway_iam_application.restic.id";
        default_project_id = orgId;
        description = "For restic backups from elitedesk";
        expires_at = "2027-07-30T15:11:28Z";
      };
    };

    scaleway_iam_application = {
      opentofu.name = "opentofu-infra";
      restic = {
        name = "restic-elitedesk";
        description = "restic backups from elitedesk";
      };
    };

    scaleway_iam_policy = {
      opentofu = {
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
      restic = {
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

    scaleway_object_bucket.elitedesk_backup = {
      name = "backups";
      force_destroy = false;
      # cleans up parts of uploads that never completed (interrupted restic runs)
      lifecycle_rule = [
        {
          id = "abort-incomplete-multipart-uploads";
          enabled = true;
          abort_incomplete_multipart_upload_days = 7;
        }
      ];
    };
  };
}
