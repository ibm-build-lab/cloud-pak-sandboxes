// General output parameters
output "resource_group" {
  value = var.resource_group
}

// ROKS output parameters
output "cluster_endpoint" {
  value = module.create_cluster.endpoint
}
output "cluster_id" {
  value = local.enable_cluster ? module.create_cluster.id : var.cluster_id
}
output "cluster_name" {
  value = local.enable_cluster ? module.create_cluster.name : ""
}
output "kubeconfig" {
  value = data.ibm_container_cluster_config.cluster_config.config_file_path
}

// output "cluster_config" {
//   value = module.cluster.config
// }

// CP4Auto Output Parameters
// Dashboard URL

output "cp4aiops_url" {
  description = "Access your Cloud Pak for AIOPS deployment at this URL."
  value = module.install_cp4aiops.cp4aiops_endpoint
}

output "cp4aiops_user" {
  description = "Username for your Cloud Pak for AIOPS deployment."
  value = module.install_cp4aiops.cp4aiops_user
}

output "cp4aiops_password" {
  description = "Password for your Cloud Pak for AIOPS deployment."
  value = module.install_cp4aiops.cp4aiops_password
}
