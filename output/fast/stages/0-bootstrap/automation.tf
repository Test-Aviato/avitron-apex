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

# tfdoc:file:description Automation project and resources.

module "automation-project" {
  source          = "../../../modules/project"
  billing_account = var.billing_account.id
  name            = var.resource_names["project-automation"]
  parent = coalesce(
    var.project_parent_ids.automation, "organizations/${var.organization.id}"
  )
  prefix   = var.prefix
  universe = var.universe
  contacts = (
    var.bootstrap_user != null || var.essential_contacts == null
    ? {}
    : { (var.essential_contacts) = ["ALL"] }
  )
  factories_config = {
    org_policies = (
      var.bootstrap_user != null ? null : var.factories_config.org_policies_iac
    )
  }
  # human (groups) IAM bindings
  iam_by_principals = {
    (local.principals.gcp-devops) = [
      "roles/iam.serviceAccountAdmin",
      "roles/iam.serviceAccountTokenCreator",
    ]
    (local.principals.gcp-organization-admins) = [
      "roles/iam.serviceAccountTokenCreator",
      "roles/iam.workloadIdentityPoolAdmin"
    ]
  }
  # machine (service accounts) IAM bindings
  iam = {
    "roles/owner" = [
      module.automation-tf-bootstrap-sa.iam_email
    ]
    "roles/artifactregistry.reader" = [
      module.automation-tf-bootstrap-sa.iam_email
    ]
    "roles/containeranalysis.occurrences.viewer" = [
      module.automation-tf-bootstrap-sa.iam_email
    ]
    "roles/cloudasset.owner" = [module.automation-tf-bootstrap-sa.iam_email]
    "roles/iam.serviceAccountTokenCreator" = [
      module.automation-tf-resman-sa.iam_email
    ]
    "roles/cloudbuild.builds.editor" = [
      module.automation-tf-resman-sa.iam_email
    ]
    "roles/iam.serviceAccountAdmin" = [
      module.automation-tf-resman-sa.iam_email
    ]
    "roles/iam.workloadIdentityPoolAdmin" = [
      module.automation-tf-resman-sa.iam_email
    ]
    "roles/source.admin" = [
      module.automation-tf-resman-sa.iam_email
    ]
    "roles/storage.admin" = [
      module.automation-tf-resman-sa.iam_email
    ]
    (module.organization.custom_role_id["storage_viewer"]) = [
      module.automation-tf-bootstrap-r-sa.iam_email,
      module.automation-tf-resman-r-sa.iam_email
    ]
    "roles/viewer" = [
      module.automation-tf-bootstrap-r-sa.iam_email,
      module.automation-tf-resman-r-sa.iam_email
    ]
  }
  iam_bindings = {
    delegated_grants_resman = {
      members = [module.automation-tf-resman-sa.iam_email]
      role    = "roles/resourcemanager.projectIamAdmin"
      condition = {
        title       = "resman_delegated_grant"
        description = "Resource manager service account delegated grant."
        expression = format(
          "api.getAttribute('iam.googleapis.com/modifiedGrantsByRole', []).hasOnly(['%s'])",
          "roles/serviceusage.serviceUsageConsumer"
        )
      }
    }
  }
  iam_bindings_additive = {
    serviceusage_resman = {
      member = module.automation-tf-resman-sa.iam_email
      role   = "roles/serviceusage.serviceUsageConsumer"
    }
    serviceusage_resman_r = {
      member = module.automation-tf-resman-r-sa.iam_email
      role   = "roles/serviceusage.serviceUsageViewer"
    }
  }
  org_policies = (
    var.bootstrap_user != null || var.org_policies_config.iac_policy_member_domains == null
    ? {}
    : {
      "iam.allowedPolicyMemberDomains" = {
        inherit_from_parent = true
        rules = [{
          allow = {
            values = var.org_policies_config.iac_policy_member_domains
          }
        }]
      }
    }
  )
  services = concat(
    [
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
    ],
    # enable specific service only after org policies have been applied
    var.bootstrap_user != null ? [] : [
      "cloudbuild.googleapis.com",
      "compute.googleapis.com",
      "container.googleapis.com",
      "artifactregistry.googleapis.com",
      "containerscanning.googleapis.com",
    ]
  )
  # Enable IAM data access logs to capture impersonation and service
  # account token generation/exchanges events. This is implemented within the
  # automation project to limit log volume. For heightened security,
  # consider enabling it at the organization level. A log sink within
  # the organization will collect and store these logs in a logging
  # bucket. See
  # https://cloud.google.com/iam/docs/audit-logging#audited_operations
  logging_data_access = {
    "iam.googleapis.com" = {
      # ADMIN_READ captures impersonation and token generation/exchanges
      ADMIN_READ = {}
      # enable DATA_WRITE if you want to capture configuration changes
      # to IAM-related resources (roles, deny policies, service
      # accounts, identity pools, etc)
      # DATA_WRITE = {}
    }
  }
}
