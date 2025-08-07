variable "log_sinks" {
  description = "Org-level log sinks, in name => {type, filter} format."
  type = map(object({
    filter     = string
    type       = string
    disabled   = optional(bool, false)
    exclusions = optional(map(string), {})
  }))
  nullable = false
  default = {
    audit-logs = {
      # activity logs include Google Workspace / Cloud Identity logs
      # exclude them via additional filter stanza if needed
      filter = <<-FILTER
        log_id("cloudaudit.googleapis.com/activity") OR
        log_id("cloudaudit.googleapis.com/system_event") OR
        log_id("cloudaudit.googleapis.com/policy") OR
        log_id("cloudaudit.googleapis.com/access_transparency")
      FILTER
      type   = "logging"
      # exclusions = {
      #   gke-audit = "protoPayload.serviceName=\"k8s.io\""
      # }
    }
    iam = {
      filter = <<-FILTER
        protoPayload.serviceName="iamcredentials.googleapis.com" OR
        protoPayload.serviceName="iam.googleapis.com" OR
        protoPayload.serviceName="sts.googleapis.com"
      FILTER
      type   = "logging"
    }
    vpc-sc = {
      filter = <<-FILTER
        protoPayload.metadata.@type="type.googleapis.com/google.cloud.audit.VpcServiceControlAuditMetadata"
      FILTER
      type   = "logging"
    }
    workspace-audit-logs = {
      filter = <<-FILTER
        protoPayload.serviceName="admin.googleapis.com" OR
        protoPayload.serviceName="cloudidentity.googleapis.com" OR
        protoPayload.serviceName="login.googleapis.com"
      FILTER
      type   = "logging"
    }
  }
  validation {
    condition = alltrue([
      for k, v in var.log_sinks :
      contains(["bigquery", "logging", "project", "pubsub", "storage"], v.type)
    ])
    error_message = "Type must be one of 'bigquery', 'logging', 'project', 'pubsub', 'storage'."
  }
}
