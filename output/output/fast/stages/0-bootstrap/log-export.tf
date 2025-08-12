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
  count       = 1
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
  count     = 1
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
  count       = 1
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
    name         = "metric.googleapis.com/logging/project-changes"
    type         = "GAUGE"
    unit         = "1"
    labels {
      key         = "project_id"
      description = "The project"
      value_type  = "STRING"
    }
  }
  value_extractor = "EXTRACT(resource.labels.project_id)"
  label_extractors = {
    "channel" = "EXTRACT(protoPayload.serviceData.policyDelta.bindingDeltas[0].action)"
  }
}

resource "google_monitoring_alert_policy" "project_ownership_changes" {
  count                        = 1
  project                      = module.log-export-project.project_id
  display_name                 = "Project Ownership Assignments/Changes"
  combiner                     = "OR"
  enabled                      = true
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
          AND metric.name = "metric.googleapis.com/logging/project-changes"
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
