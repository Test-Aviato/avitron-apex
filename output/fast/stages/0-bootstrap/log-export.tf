/**
 * Copyright 2025 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# tfdoc:file:description Audit log project and sink.

locals {
  log_sink_destinations = merge(
    {
      for k, v in var.log_sinks : k => {
        id = module.log-export-project.project_id
      } if v.type == "project"
    },
    # use the same dataset for all sinks with `bigquery` as  destination
    {
      for k, v in var.log_sinks :
      k => module.log-export-dataset[0] if v.type == "bigquery"
    },
    # use the same gcs bucket for all sinks with `storage` as destination
    {
      for k, v in var.log_sinks :
      k => module.log-export-gcs[0] if v.type == "storage"
    },
    # use separate pubsub topics and logging buckets for sinks with
    # destination `pubsub` and `logging`
    module.log-export-pubsub,
    module.log-export-logbucket
  )
  log_types = toset([for k, v in var.log_sinks : v.type])
}

module "log-export-project" {
  source          = "../../../modules/project"
  billing_account = var.billing_account.id
  name            = var.resource_names["project-logs"]
  parent = coalesce(
    var.project_parent_ids.logging, "organizations/${var.organization.id}"
  )
  prefix   = var.prefix
  universe = var.universe
  contacts = (
    var.bootstrap_user != null || var.essential_contacts == null
    ? {}
    : { (var.essential_contacts) = ["ALL"] }
  )
  iam = {
    "roles/owner"  = [module.automation-tf-bootstrap-sa.iam_email]
    "roles/viewer" = [module.automation-tf-bootstrap-r-sa.iam_email]
  }
  services = [
    # "cloudresourcemanager.googleapis.com",
    # "iam.googleapis.com",
    # "serviceusage.googleapis.com",
    "bigquery.googleapis.com",
    "storage.googleapis.com",
    "stackdriver.googleapis.com",
		"containeranalysis.googleapis.com",
    "containerscanning.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
		"cloudasset.googleapis.com",
  ]
}

# one log export per type, with conditionals to skip those not needed

module "log-export-dataset" {
  source        = "../../../modules/bigquery-dataset"
  count         = contains(local.log_types, "bigquery") ? 1 : 0
  project_id    = module.log-export-project.project_id
  id            = var.resource_names["bq-logs"]
  friendly_name = "Audit logs export."
  location      = local.locations.bq
}

module "log-export-gcs" {
  source     = "../../../modules/gcs"
  count      = contains(local.log_types, "storage") ? 1 : 0
  project_id = module.log-export-project.project_id
  name       = var.resource_names["gcs-logs"]
  prefix     = var.prefix
  location   = local.locations.gcs
}

module "log-export-logbucket" {
  source        = "../../../modules/logging-bucket"
  for_each      = toset([for k, v in var.log_sinks : k if v.type == "logging"])
  parent_type   = "project"
  parent        = module.log-export-project.project_id
  id            = each.key
  location      = local.locations.logging
  log_analytics = { enable = true }
  # org-level logging settings ready before we create any logging buckets
  depends_on = [module.organization-logging]
}

module "log-export-pubsub" {
  source     = "../../../modules/pubsub"
  for_each   = toset([for k, v in var.log_sinks : k if v.type == "pubsub"])
  project_id = module.log-export-project.project_id
  name = templatestring(
    var.resource_names["pubsub-logs_template"], { key = each.key }
  )
  regions = local.locations.pubsub
}

resource "google_project_service" "containeranalysis" {
  project                    = module.log-export-project.project_id
  service                    = "containeranalysis.googleapis.com"
  disable_on_destroy         = false
  disable_dependent_services = false
}

resource "google_project_service" "containerscanning" {
  project                    = module.log-export-project.project_id
  service                    = "containerscanning.googleapis.com"
  disable_on_destroy         = false
  disable_dependent_services = false
}

resource "google_project_service" "cloudasset" {
  project                    = module.log-export-project.project_id
  service                    = "cloudasset.googleapis.com"
  disable_on_destroy         = false
  disable_dependent_services = false
}

resource "google_logging_metric" "audit_config_changes" {
  count       = 1
  name        = "audit-config-changes"
  project     = module.log-export-project.project_id
  description = "Metric for tracking Audit Configuration Changes"
  filter      = <<-FILTER
    logName:"projects/${module.log-export-project.project_id}/logs/cloudaudit.googleapis.com%2Factivity"
    AND protoPayload.methodName:"SetIamPolicy"
    AND protoPayload.serviceName="cloudresourcemanager.googleapis.com"
    AND resource.type="project"
    AND -protoPayload.authenticationInfo.principalEmail:"${module.automation-tf-bootstrap-sa.iam_email}"
  FILTER
  metric_descriptor {
    launch_stage = "BETA"
    name         = "metric.googleapis.com/logging/attributions/project"
    type         = "GAUGE"
    unit         = "1"
    labels {
      key         = "project_id"
      description = "The project"
      value_type  = "STRING"
    }
  }
  value_extractor = "EXTRACT(jsonPayload.protoPayload.authenticationInfo.principalEmail)"
  label_extractors = {
    project_id = "EXTRACT(resource.labels.project_id)"
  }
}

resource "google_monitoring_alert_policy" "audit_config_changes" {
  count = 1
  project                  = module.log-export-project.project_id
  display_name             = "Audit configuration changes in project"
  combiner                 = "OR"
  enabled                  = true
  notification_channels    = []
  alert_strategy {
    auto_close = "604800s"
  }
  conditions {
    display_name = "Metric Absence"
    condition_threshold {
      filter                     = <<-FILTER
          resource.type = "gcp_project"
          AND metric.type = "logging.googleapis.com/log_based_metrics"
          AND metric.name = "metric.googleapis.com/logging/attributions/project"
      FILTER
      duration                    = "300s"
      comparison                  = "COMPARISON_GT"
      threshold_value           = 0
      trigger {
        count = 1
      }
    }
  }
}

resource "google_logging_metric" "bucket_permission_changes" {
  count       = 1
  name        = "bucket-permission-changes"
  project     = module.log-export-project.project_id
  description = "Metric for tracking Cloud Storage Bucket IAM Permission Changes"
  filter      = <<-FILTER
    logName:"projects/${module.log-export-project.project_id}/logs/cloudaudit.googleapis.com%2Fdata_access"
    AND protoPayload.methodName="storage.setIamPermissions"
    AND resource.type="gcs_bucket"
    AND -protoPayload.authenticationInfo.principalEmail:"${module.automation-tf-bootstrap-sa.iam_email}"
  FILTER
  metric_descriptor {
    launch_stage = "BETA"
    name         = "metric.googleapis.com/logging/storage/bucket-iam-changes"
    type         = "GAUGE"
    unit         = "1"
    labels {
      key         = "bucket_name"
      description = "The bucket"
      value_type  = "STRING"
    }
  }
  value_extractor = "EXTRACT(resource.labels.bucket_name)"
  label_extractors = {
    project_id = "EXTRACT(resource.labels.project_id)"
  }
}

resource "google_monitoring_alert_policy" "bucket_permission_changes" {
  count = 1
  project                  = module.log-export-project.project_id
  display_name             = "Cloud Storage Bucket IAM changes"
  combiner                 = "OR"
  enabled                  = true
  notification_channels    = []
  alert_strategy {
    auto_close = "604800s"
  }
  conditions {
    display_name = "Metric Absence"
    condition_threshold {
      filter                     = <<-FILTER
          resource.type = "gcs_bucket"
          AND metric.type = "logging.googleapis.com/log_based_metrics"
          AND metric.name = "metric.googleapis.com/logging/storage/bucket-iam-changes"
      FILTER
      duration                    = "300s"
      comparison                  = "COMPARISON_GT"
      threshold_value           = 0
      trigger {
        count = 1
      }
    }
  }
}

resource "google_logging_metric" "custom_role_changes" {
  count       = 1
  name        = "custom-role-changes"
  project     = module.log-export-project.project_id
  description = "Metric for tracking Custom Role Changes"
  filter      = <<-FILTER
    logName:"projects/${module.log-export-project.project_id}/logs/cloudaudit.googleapis.com%2Factivity"
    AND protoPayload.methodName=("google.iam.admin.v1.CreateRole" OR "google.iam.admin.v1.DeleteRole" OR "google.iam.admin.v1.UpdateRole")
    AND resource.type="organization"
    AND -protoPayload.authenticationInfo.principalEmail:"${module.automation-tf-bootstrap-sa.iam_email}"
  FILTER
  metric_descriptor {
    launch_stage = "BETA"
    name         = "metric.googleapis.com/logging/iam/custom-role-changes"
    type         = "GAUGE"
    unit         = "1"
    labels {
      key         = "member_id"
      description = "The Custom Role"
      value_type  = "STRING"
    }
  }
  value_extractor = "EXTRACT(resource.labels.project_id)"
  label_extractors = {
    project_id = "EXTRACT(resource.labels.project_id)"
  }
}

resource "google_monitoring_alert_policy" "custom_role_changes" {
  count = 1
  project                  = module.log-export-project.project_id
  display_name             = "Custom Role Changes in organization"
  combiner                 = "OR"
  enabled                  = true
  notification_channels    = []
  alert_strategy {
    auto_close = "604800s"
  }
  conditions {
    display_name = "Metric Absence"
    condition_threshold {
      filter                     = <<-FILTER
          resource.type = "gcp_project"
          AND metric.type = "logging.googleapis.com/log_based_metrics"
          AND metric.name = "metric.googleapis.com/logging/iam/custom-role-changes"
      FILTER
      duration                    = "300s"
      comparison                  = "COMPARISON_GT"
      threshold_value           = 0
      trigger {
        count = 1
      }
    }
  }
}

resource "google_logging_metric" "project_ownership_changes" {
  count       = 1
  name        = "project-ownership-changes"
  project     = module.log-export-project.project_id
  description = "Metric for tracking Project Ownership Assignments/Changes"
  filter      = <<-FILTER
    logName:"projects/${module.log-export-project.project_id}/logs/cloudaudit.googleapis.com%2Factivity"
    AND protoPayload.methodName=("SetIamPolicy")
    AND protoPayload.serviceName="cloudresourcemanager.googleapis.com"
    AND resource.type="project"
    AND protoPayload.requestMetadata.callerSuppliedUserAgent:"gcloud-projects-update"
  FILTER
  metric_descriptor {
    launch_stage = "BETA"
    name         = "metric.googleapis.com/logging/project
