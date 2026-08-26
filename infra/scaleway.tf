provider "scaleway" {
  region     = "nl-ams"
  project_id = "00000000-0000-0000-0000-000000000000" # Backup
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

# imported 2026-08-26
import {
  to = scaleway_object_bucket.elitedesk_backup
  id = "nl-ams/backups"
}
