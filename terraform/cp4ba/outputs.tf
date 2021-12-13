output "cp4ba_endpoint" {
  depends_on = [
    data.external.get_endpoints,
  ]
  value = var.enable && length(data.external.get_endpoints) > 0 ? data.external.get_endpoints.0.result.endpoint : ""
}

output "cp4ba_user" {
  depends_on = [
    data.external.get_endpoints,
  ]
  value = var.enable && length(data.external.get_endpoints) > 0 ? data.external.get_endpoints.0.result.username : ""
}

output "cp4ba_password" {
  depends_on = [
    data.external.get_endpoints,
  ]
  value = var.enable && length(data.external.get_endpoints) > 0 ? data.external.get_endpoints.0.result.password : ""
}

output "db2_host_name" {
    depends_on = [
    data.external.get_endpoints,
  ]
  value = var.db2_host_name
}

output "db2_host_ip" {
    depends_on = [
    data.external.get_endpoints,
  ]
  value = var.db2_host_ip
}

output "db2_port_number" {
    depends_on = [
    data.external.get_endpoints,
  ]
  value = var.db2_port_number
}
