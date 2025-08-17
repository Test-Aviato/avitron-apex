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

variable "essential_contacts" {
  description = "Email used for essential contacts, unset if null."
  type        = string
  default     = "essential-contacts@example.com"
}

variable "locations" {
  description = "Optional locations for GCS, BigQuery, and logging buckets created here."
  type = object({
    bq      = optional(string, "EU")
    gcs     = optional(string, "EU")
    logging = optional(string, "global")
    pubsub  = optional(list(string), [])
  })
  nullable = false
  default  = {}
}

variable "org_policies_config" {
  description = "Organization policies customization."
  type = object({
    iac_policy_member_domains = optional(list(string))
    import_defaults           = optional(bool, false)
    tag_name                  = optional(string, "org-policies")
    tag_values = optional(map(object({
      description = optional(string, "Managed by the Terraform organization module.")
      iam         = optional(map(list(string)), {})
      id          = optional(string)
    })), {})
  })
  nullable = false
  default  = {}
}

variable "organization" {
  description = "Organization details."
  type = object({
    id          = number
    domain      = optional(string)
    customer_id = optional(string)
  })
  nullable = false
}

variable "outputs_location" {
  description = "Enable writing provider, tfvars and CI/CD workflow files to local filesystem. Leave null to disable."
  type        = string
  default     = null
}

variable "prefix" {
  description = "Prefix used for resources that need unique names. Use 9 characters or less."
  type        = string
  validation {
    condition     = try(length(var.prefix), 0) < 10
    error_message = "Use a maximum of 9 characters for prefix."
  }
}

variable "project_parent_ids" {
  description = "Optional parents for projects created here in folders/nnnnnnn format. Null values will use the organization as parent."
  type = object({
    automation = optional(string)
    billing    = optional(string)
    logging    = optional(string)
  })
  default  = {}
  nullable = false
}

variable "resource_names" {
  description = "Resource names overrides for specific resources. Prefix is always set via code, except where noted in the variable type."
  type = object({
    bq-billing           = optional(string, "billing_export")
    bq-logs              = optional(string, "logs")
    gcs-bootstrap        = optional(string, "prod-iac-core-bootstrap-0")
    gcs-logs             = optional(string, "prod-audit-logs-0")
    gcs-outputs          = optional(string, "prod-iac-core-outputs-0")
    gcs-resman           = optional(string, "prod-iac-core-resman-0")
    gcs-vpcsc            = optional(string, "prod-iac-core-vpcsc-0")
    project-automation   = optional(string, "prod-iac-core-0")
    project-billing      = optional(string, "prod-billing-exp-0")
    project-logs         = optional(string, "prod-audit-logs-0")
    pubsub-logs_template = optional(string, "$${key}")
    sa-bootstrap         = optional(string, "prod-bootstrap-0")
    sa-bootstrap_ro      = optional(string, "prod-bootstrap-0r")
    sa-cicd_template     = optional(string, "prod-$${key}-1")
    sa-cicd_template_ro  = optional(string, "prod-$${key}-1r")
    sa-resman            = optional(string, "prod-resman-0")
    sa-resman_ro         = optional(string, "prod-resman-0r")
    sa-vpcsc             = optional(string, "prod-vpcsc-0")
    sa-vpcsc_ro          = optional(string, "prod-vpcsc-0r")
    # the identity provider resources also interpolate prefix
    wf-bootstrap          = optional(string, "$${prefix}-bootstrap")
    wf-provider_template  = optional(string, "$${prefix}-bootstrap-$${key}")
    wif-bootstrap         = optional(string, "$${prefix}-bootstrap")
    wif-provider_template = optional(string, "$${prefix}-bootstrap-$${key}")
  })
  nullable = false
  default  = {}
}

variable "universe" {
  description = "Target GCP universe."
  type = object({
    domain               = string
    prefix               = string
    unavailable_services = optional(list(string), [])
  })
  default = null
}

variable "workforce_identity_providers" {
  description = "Workforce Identity Federation pools."
  type = map(object({
    attribute_condition = optional(string)
    issuer              = string
    display_name        = string
    description         = string
    disabled            = optional(bool, false)
    saml = optional(object({
      idp_metadata_xml = string
    }), null)
  }))
  default  = {}
  nullable = false
}

variable "workload_identity_providers" {
  description = "Workload Identity Federation pools. The `cicd_repositories` variable references keys here."
  type = map(object({
    attribute_condition = optional(string)
    issuer              = string
    custom_settings = optional(object({
      issuer_uri = optional(string)
      audiences  = optional(list(string), [])
      jwks_json  = optional(string)
    }), {})
  }))
  default  = {}
  nullable = false
  # TODO: fix validation
  # validation {
  #   condition     = var.federated_identity_providers.custom_settings == null
  #   error_message = "Custom settings cannot be null."
  # }
}
