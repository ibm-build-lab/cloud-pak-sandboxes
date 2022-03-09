output "cluster_id" {
  depends_on = [
    data.external.get_endpoints,
  ]
  value = var.cluster_id
}

output "cluster_name" {
  depends_on = [
    data.external.get_endpoints,
  ]
  value = join("", [var.roks_project, "-", var.environment, "-cluster"])
}

output "kubeconfig" {
  depends_on = [
    data.external.get_endpoints,
  ]
  value = var.cluster_config_path
}

output "db2_host_name" {
    depends_on = [
    data.external.get_endpoints,
  ]
  value = var.db2_host_address
}

output "db2_port_number" {
    depends_on = [
    data.external.get_endpoints,
  ]
  value = var.db2_ports
}

output "cp4ba_endpoint" {
  depends_on = [
    data.external.get_endpoints,
  ]
  value = length(data.external.get_endpoints) > 0 ? data.external.get_endpoints.0.result.endpoint : ""
}

output "cp4ba_user" {
  depends_on = [
    data.external.get_endpoints,
  ]
  value = length(data.external.get_endpoints) > 0 ? data.external.get_endpoints.0.result.username : ""
}

output "cp4ba_password" {
  depends_on = [
    data.external.get_endpoints,
  ]
  value = length(data.external.get_endpoints) > 0 ? data.external.get_endpoints.0.result.password : ""
}


