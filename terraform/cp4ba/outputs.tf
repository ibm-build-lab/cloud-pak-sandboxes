# --- ROKS output parameters
output "cluster_name" {
  value = local.enable_cluster ? module.create_cluster.name : data.ibm_container_cluster_config.cluster_config.cluster_name_id
}


output "cluster_id" {
  value = local.enable_cluster ? module.create_cluster.id : var.cluster_id
}

output "cluster_endpoint" {
  value = local.enable_cluster == false ? var.cluster_ingress_subdomain : module.create_cluster.endpoint
}

output "kubeconfig" {
  value = data.ibm_container_cluster_config.cluster_config.config_dir # config_file_path
}

# --- Db2 outputs
output "db2_host_address" {
  value = var.enable_db2 ? module.install_db2.db2_host_address : local.db2_host_address
}

output "db2_ports" {
  value = var.enable_db2 ? module.install_db2.db2_ports : local.db2_ports
}

output "db2_pod_name" {
  description = "This is the pod running Db2 for executing Db2 commands."
  value = var.enable_db2 ? module.install_db2.db2_pod_name : local.db2_pod_name
}

# --- CP4BA Outputs
output "cp4ba_endpoint" {
  description = "Access your Cloud Pak for Business Automation deployment at this URL."
  value       = module.install_cp4ba.cp4ba_endpoint
}

output "cp4ba_user" {
  value = module.install_cp4ba.cp4ba_admin_username
}

output "cp4ba_password" {
  description = "Password for your Cloud Pak for Business Automation deployment."
  value = module.install_cp4ba.cp4ba_admin_password
}





