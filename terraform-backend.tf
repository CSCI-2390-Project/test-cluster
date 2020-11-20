terraform {
  backend "gcs" {
    bucket  = "tfstate-backend" # REPLACE THIS WITH A NEW BUCKET YOU CREATE
    prefix  = "terraform/state"
  }
}