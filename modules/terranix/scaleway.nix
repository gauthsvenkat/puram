{
  flakeCfg,
  targetCfg,

  lib,
  ...
}:
let
  inherit (flakeCfg) buckets;
  inherit (targetCfg) alertEmail;
  inherit (targetCfg.scaleway) orgId ownerEmail;
  # attrNames :: { app::String -> bucketName::String } -> [ app::String ]
  apps = lib.attrNames buckets;
in
{
  provider.scaleway = {
    organization_id = orgId;
    project_id = orgId;
    inherit (targetCfg.scaleway) region;
  };

  data.scaleway_iam_user."owner".email = ownerEmail;

  resource = {
    # Auth
    # application
    scaleway_iam_application = {
      "opentofu".name = "opentofu-infra";
    }
    # genAttrs :: [ app::String ] -> (app::String -> application) -> { app::String -> application }
    #   where application = { name :: String }
    // lib.genAttrs apps (app: {
      name = "backup-${app}";
    });

    # group
    scaleway_iam_group."backup_writers" = {
      name = "backup-writers";
      # map :: (app::String -> applicationId::String) -> [ app::String ] -> [ applicationId::String ]
      application_ids = map (app: lib.tf.ref "scaleway_iam_application.${app}.id") apps;
    };

    # api-key
    scaleway_iam_api_key = {
      "opentofu" = {
        application_id = lib.tf.ref "scaleway_iam_application.opentofu.id";
        default_project_id = orgId;
        description = "opentofu provisioning";
        expires_at = "2027-08-25T22:00:00Z";
        # The apply runs on this key, so create its successor before revoking it.
        lifecycle.create_before_destroy = true;
      };
    }
    # genAttrs :: [ app::String ] -> (app::String -> apiKey) -> { app::String -> apiKey }
    #   where apiKey = { application_id :: String; default_project_id :: String; description :: String }
    // lib.genAttrs apps (app: {
      application_id = lib.tf.ref "scaleway_iam_application.${app}.id";
      default_project_id = orgId;
      description = "${app} backups";
    });

    # policy
    scaleway_iam_policy = {
      "backup_writers" = {
        name = "backup-writers";
        group_id = lib.tf.ref "scaleway_iam_group.backup_writers.id";
        rule = [
          {
            project_ids = [ orgId ];
            permission_set_names = [
              "ObjectStorageObjectsDelete"
              "ObjectStorageObjectsRead"
              "ObjectStorageObjectsWrite"
            ];
          }
        ];
      };
      "opentofu" = {
        name = "opentofu";
        application_id = lib.tf.ref "scaleway_iam_application.opentofu.id";
        rule = [
          {
            project_ids = [ orgId ];
            permission_set_names = [
              "ObjectStorageBucketPolicyFullAccess"
              "ObjectStorageBucketsRead"
              "ObjectStorageBucketsWrite"
              "ObjectStorageObjectsRead"
            ];
          }
          {
            organization_id = orgId;
            permission_set_names = [
              "BillingManager"
              "IAMManager"
            ];
          }
        ];
      };
    };

    # Billing
    # budget
    scaleway_billing_budget."main" = {
      organization_id = orgId;
      consumption_limit = 5; # € per month, incl taxes
    };

    # alert
    scaleway_billing_budget_alert = {
      "full" = {
        budget_id = lib.tf.ref "scaleway_billing_budget.main.id";
        threshold = 100;
      };
      "half" = {
        budget_id = lib.tf.ref "scaleway_billing_budget.main.id";
        threshold = 50;
      };
    };
    scaleway_billing_budget_alert_notification = {
      "full" = {
        budget_alert_id = lib.tf.ref "scaleway_billing_budget_alert.full.id";
        email_addresses = [ alertEmail ];
      };
      "half" = {
        budget_alert_id = lib.tf.ref "scaleway_billing_budget_alert.half.id";
        email_addresses = [ alertEmail ];
      };
    };

    # Storage
    # bucket
    # mapAttrs :: (app::String -> bucketName::String -> bucket) -> { app::String -> bucketName::String } -> { app::String -> bucket }
    #   where bucket = { name :: String; force_destroy :: Bool; versioning :: { enabled :: Bool }; lifecycle_rule :: [ lifecycleRule ] }; lifecycleRule = { id :: String; enabled :: Bool; <one action> }
    scaleway_object_bucket = lib.mapAttrs (_: name: {
      inherit name;
      force_destroy = false;
      versioning.enabled = true;
      # NOTE: Do not mess with lifecycle rules and current data!
      # They can potentially corrupt current data depending on how
      # the backup tool works. The tool itself is expected to own
      # deletion of files.
      lifecycle_rule = [
        {
          id = "abort-incomplete-multipart-uploads";
          enabled = true;
          abort_incomplete_multipart_upload_days = 7;
        }
        {
          id = "expire-noncurrent-versions";
          enabled = true;
          noncurrent_version_expiration.noncurrent_days = 30;
        }
        {
          id = "remove-expired-delete-markers";
          enabled = true;
          expiration.expired_object_delete_marker = true;
        }
      ];
    }) buckets;

    # bucket-policy
    # mapAttrs :: (app::String -> bucketName::String -> bucketPolicy) -> { app::String -> bucketName::String } -> { app::String -> bucketPolicy }
    #   where bucketPolicy = { bucket :: String; policy :: String }
    scaleway_object_bucket_policy = lib.mapAttrs (app: name: {
      bucket = lib.tf.ref "scaleway_object_bucket.${app}.name";
      policy = lib.toJSON {
        Version = "2023-04-17";
        Statement = [
          {
            Sid = "backup";
            Effect = "Allow";
            Principal.SCW = "application_id:${lib.tf.ref "scaleway_iam_application.${app}.id"}";
            Action = [
              "s3:AbortMultipartUpload"
              "s3:DeleteObject"
              "s3:GetBucketLocation"
              "s3:GetObject"
              "s3:ListBucket"
              "s3:ListBucketMultipartUploads"
              "s3:ListMultipartUploadParts"
              "s3:PutObject"
            ];
            Resource = [
              name
              "${name}/*"
            ];
          }
          {
            Sid = "admin";
            Effect = "Allow";
            Principal.SCW = [
              "application_id:${lib.tf.ref "scaleway_iam_application.opentofu.id"}"
              "user_id:${lib.tf.ref "data.scaleway_iam_user.owner.id"}"
            ];
            Action = "*";
            Resource = [
              name
              "${name}/*"
            ];
          }
        ];
      };
    }) buckets;
  };

  # map :: (app::String -> { outputName::String -> output }) -> [ app::String ] -> [ { outputName::String -> output } ]
  # mergeAttrsList :: [ { outputName::String -> output } ] -> { outputName::String -> output }
  #   where output = { value :: String; sensitive :: Bool }
  output =
    lib.mergeAttrsList (
      map (app: {
        "scaleway_access_key_${app}" = {
          value = lib.tf.ref "scaleway_iam_api_key.${app}.access_key";
          sensitive = true;
        };
        "scaleway_secret_key_${app}" = {
          value = lib.tf.ref "scaleway_iam_api_key.${app}.secret_key";
          sensitive = true;
        };
      }) apps
    )
    // {
      scw_access_key_tofu = {
        value = lib.tf.ref "scaleway_iam_api_key.opentofu.access_key";
        sensitive = true;
      };
      scw_secret_key_tofu = {
        value = lib.tf.ref "scaleway_iam_api_key.opentofu.secret_key";
        sensitive = true;
      };
    };
}
