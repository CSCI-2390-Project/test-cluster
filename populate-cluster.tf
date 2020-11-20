# Deliberately kept insecure in that it only uses HTTP Basic Auth. 
# We should fix this eventually, but good enough for testing for now.
provider "kubectl" {
  apply_retry_count = 3
  load_config_file = "false"

  host = "https://${google_container_cluster.primary.endpoint}"
  insecure = true
  username = "admin"
  password = var.password
}

data "kubectl_file_documents" "manifests" {
    content = file(var.yamls_folder_path)
}

resource "kubectl_manifest" "microservices" {
    for_each = toset(data.kubectl_file_documents.manifests.documents)
    yaml_body = each.value
}