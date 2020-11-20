provider "google-beta" {

  project = "ms-demo-2390"
  credentials = file(var.service_account_key_path)
  region  = "us-east1"
  zone    = "us-east1-b"

}

resource "google_container_cluster" "primary" {

  provider = google-beta
  name               = "primary"
  initial_node_count = 3

  node_config {
    machine_type = "n1-standard-2"
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  master_auth {
    username = "admin"
    password = var.password
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  addons_config {
    istio_config {
      disabled = "false"
    }
  }

  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials primary --zone us-east1-b --project ms-demo-2390"
    interpreter = ["/bin/bash", "-c"]
    environment = {
      GOOGLE_APPLICATION_CREDENTIALS = var.service_account_key_path
    }
  }

  # Set istio-injection by default into the `default` namespace. 
  # Thus, pods will automatically get Envoy inserted into them.
  provisioner "local-exec" {
    command = "kubectl config use-context ms-demo-2390_us-east1-b_primary; kubectl label namespace default istio-injection=enabled"
    interpreter = ["/bin/bash", "-c"]
  }

  provisioner "local-exec" {
    when    = destroy
    command = "kubectl config delete-context ms-demo-2390_us-east1-b_primary"
    interpreter = ["/bin/bash", "-c"]
  }

}

output "cluster_name" {
  value = google_container_cluster.primary.name
}


output "cluster_zone" {
  value = google_container_cluster.primary.zone
}

output "cluster_project" {
  value = google_container_cluster.primary.zone
}