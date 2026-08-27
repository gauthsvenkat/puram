provider "scaleway" {
  region     = "nl-ams"
  project_id = "00000000-0000-0000-0000-000000000000" # Backup
}

locals {
  # single-project org: the organization and its default project "Backup" share this id
  scaleway_org_id = "00000000-0000-0000-0000-000000000000"
}

resource "scaleway_object_bucket" "elitedesk_backup" {
  name          = "backups"
  force_destroy = false

  # cleans up parts of uploads that never completed (interrupted restic runs)
  lifecycle_rule {
    id                                     = "abort-incomplete-multipart-uploads"
    enabled                                = true
    abort_incomplete_multipart_upload_days = 7
  }
}

resource "scaleway_iam_application" "restic" {
  name        = "restic-elitedesk"
  description = "restic backups from elitedesk"
}

resource "scaleway_iam_policy" "restic" {
  name           = "Object Storage access"
  application_id = scaleway_iam_application.restic.id

  rule {
    permission_set_names = ["ObjectStorageFullAccess"]
    project_ids          = [local.scaleway_org_id]
  }
}

resource "scaleway_iam_api_key" "restic" {
  application_id     = scaleway_iam_application.restic.id
  description        = "For restic backups from elitedesk"
  default_project_id = local.scaleway_org_id
  expires_at         = "2027-07-30T15:11:28Z"
}

resource "scaleway_iam_application" "opentofu" {
  name = "opentofu-infra"
}

resource "scaleway_iam_policy" "opentofu" {
  name           = "opentofu"
  application_id = scaleway_iam_application.opentofu.id

  rule {
    permission_set_names = ["ObjectStorageBucketsRead", "ObjectStorageBucketsWrite", "ObjectStorageObjectsRead"]
    project_ids          = [local.scaleway_org_id]
  }
  rule {
    permission_set_names = ["IAMManager"]
    organization_id      = local.scaleway_org_id
  }
}

resource "scaleway_iam_api_key" "opentofu" {
  application_id     = scaleway_iam_application.opentofu.id
  description        = "opentofu provisioning"
  default_project_id = local.scaleway_org_id
  expires_at         = "2027-08-25T22:00:00Z"

  # replacing this key must create the successor before revoking the
  # credential the apply itself is running on
  lifecycle {
    create_before_destroy = true
  }
}

# imported 2026-08-26
import {
  to = scaleway_object_bucket.elitedesk_backup
  id = "nl-ams/backups"
}

# imported 2026-08-27
import {
  to = scaleway_iam_application.restic
  id = "00000000-0000-0000-0000-000000000001" # application_id
}
import {
  to = scaleway_iam_policy.restic
  id = "00000000-0000-0000-0000-000000000003" # policy_id
}
import {
  to = scaleway_iam_api_key.restic
  id = "SCW00000000000000000" # access_key
}
import {
  to = scaleway_iam_application.opentofu
  id = "00000000-0000-0000-0000-000000000002" # application_id
}
import {
  to = scaleway_iam_policy.opentofu
  id = "00000000-0000-0000-0000-000000000004" # policy_id
}
import {
  to = scaleway_iam_api_key.opentofu
  id = "SCW00000000000000001" # access_key
}
