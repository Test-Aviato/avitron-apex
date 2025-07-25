/**
 * Copyright 2024 Google LLC
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

variable "factories_config" {
  description = "Configuration for YAML-based factories."
  type = object({
    folders_data_path  = optional(string, "data/hierarchy")
    projects_data_path = optional(string, "data/projects")
    budgets = optional(object({
      billing_account       = string
      budgets_data_path     = optional(string, "data/budgets")
      notification_channels = optional(map(any), {})
    }))
    context = optional(object({
      custom_roles      = optional(map(string), {})
      folder_ids        = optional(map(string), {})
      kms_keys          = optional(map(string), {})
      iam_principals    = optional(map(string), {})
      tag_values        = optional(map(string), {})
      vpc_host_projects = optional(map(string), {})
    }), {})
    projects_config = optional(object({
      key_ignores_path = optional(bool, false)
    }), {})
  })
  nullable = false
  default  = {}
}

variable "outputs_location" {
  description = "Enable writing provider, tfvars and CI/CD workflow files to local filesystem. Leave null to disable."
  type        = string
  default     = null
}

variable "stage_name" {
  description = "FAST stage name. Used to separate output files across different factories."
  type        = string
  nullable    = false
  default     = "2-project-factory"
}

variable "bucket_name" {
  description = "Name of the GCS bucket to store Terraform state files."
  type        = string
  nullable    = false
  default     = ""
}

variable "project_id" {
  description = "Project ID for the project factory."
  type        = string
  nullable    = false
  default     = ""
}