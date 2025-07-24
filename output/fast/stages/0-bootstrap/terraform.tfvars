billing_account = {
  id = "012345-67890A-BCDEF0"
}

locations = {
  bq      = "EU"
  gcs     = "EU"
  logging = "global"
  pubsub  = []
}

organization = {
  domain      = "example.org"
  id          = 1234567890
  customer_id = "C000001"
}

outputs_location = "~/fast-config"

prefix = "abcd"

essential_contacts = "admin@example.org"
gcloud services enable containeranalysis.googleapis.com --project=bootstrap-project-summit-25
gcloud services enable containerscanning.googleapis.com --project=bootstrap-project-summit-25
gcloud services enable cloudasset.googleapis.com --project=bootstrap-project-summit-25
gcloud services enable logging.googleapis.com --project=bootstrap-project-summit-25
gcloud services enable monitoring.googleapis.com --project=bootstrap-project-summit-25
