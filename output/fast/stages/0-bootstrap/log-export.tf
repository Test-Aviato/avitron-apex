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
  source = "../../../modules/project"
  name   = var.resource_names["project-logs"]
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
    "accesscontextmanager.googleapis.com",
    "adsdatahub.googleapis.com",
    "aiplatform.googleapis.com",
    "alpha-documentai.googleapis.com",
    "apigee.googleapis.com",
    "apigeeconnect.googleapis.com",
    "artifactregistry.googleapis.com",
    "assuredworkloads.googleapis.com",
    "automl.googleapis.com",
    "bigquery.googleapis.com",
    "bigqueryreservation.googleapis.com",
    "bigquerystorage.googleapis.com",
    "bigtable.googleapis.com",
    "binaryauthorization.googleapis.com",
    "cloudasset.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudkms.googleapis.com",
    "cloudprofiler.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudsearch.googleapis.com",
    "cloudtrace.googleapis.com",
    "composer.googleapis.com",
    "compute.googleapis.com",
    "connectgateway.googleapis.com",
    "contactcenterinsights.googleapis.com",
    "container.googleapis.com",
    "containeranalysis.googleapis.com",
    "containerregistry.googleapis.com",
    "containerthreatdetection.googleapis.com",
    "datacatalog.googleapis.com",
    "dataflow.googleapis.com",
    "datafusion.googleapis.com",
    "dataproc.googleapis.com",
    "datastream.googleapis.com",
    "dialogflow.googleapis.com",
    "dlp.googleapis.com",
    "dns.googleapis.com",
    "documentai.googleapis.com",
    "essentialcontacts.googleapis.com",
    "eventarc.googleapis.com",
    "file.googleapis.com",
    "gameservices.googleapis.com",
    "gkeconnect.googleapis.com",
    "gkehub.googleapis.com",
    "healthcare.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "logging.googleapis.com",
    "managedidentities.googleapis.com",
    "memcache.googleapis.com",
    "meshca.googleapis.com",
    "metastore.googleapis.com",
    "ml.googleapis.com",
    "monitoring.googleapis.com",
    "networkconnectivity.googleapis.com",
    "networkmanagement.googleapis.com",
    "networksecurity.googleapis.com",
    "networkservices.googleapis.com",
    "notebooks.googleapis.com",
    "orgpolicy.googleapis.com",
    "privateca.googleapis.com",
    "pubsub.googleapis.com",
    "pubsublite.googleapis.com",
    "recaptchaenterprise.googleapis.com",
    "recommender.googleapis.com",
    "redis.googleapis.com",
    "run.googleapis.com",
    "secretmanager.googleapis.com",
    "servicecontrol.googleapis.com",
    "servicedirectory.googleapis.com",
    "spanner.googleapis.com",
    "speakerid.googleapis.com",
    "speech.googleapis.com",
    "sqladmin.googleapis.com",
    "storage-component.googleapis.com",
    "storage.googleapis.com",
    "storagetransfer.googleapis.com",
    "sts.googleapis.com",
    "texttospeech.googleapis.com",
    "tpu.googleapis.com",
    "trafficdirector.googleapis.com",
    "transcoder.googleapis.com",
    "translate.googleapis.com",
      "videointelligence.googleapis.com",
      "vision.googleapis.com",
      "vpcaccess.googleapis.com",
      "containerscanning.googleapis.com",
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
