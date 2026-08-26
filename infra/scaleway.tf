provider "scaleway" {
  region     = "nl-ams"
  project_id = "49f36768-efc3-4a06-8c8e-0f66f870d0c4" # Backup
}

resource "scaleway_object_bucket" "elitedesk_backup" {
  name          = "elitedesk-backup"
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
  id = "nl-ams/elitedesk-backup"
}
