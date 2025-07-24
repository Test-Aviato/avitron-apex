module "log-export-project" {
  source = "../../../modules/project"
  name   = var.resource_names["project-logs"]
  parent = coalesce(
    var.project_parent_ids.logging, "organizations/${var.organization.id}"
  )
  prefix          = var.prefix
  universe        = var.universe
  billing_account = var.billing_account.id
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
	  "cloudasset.googleapis.com",
      "containeranalysis.googleapis.com",
      "containerscanning.googleapis.com",
  ]
}
