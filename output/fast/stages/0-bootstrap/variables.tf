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
