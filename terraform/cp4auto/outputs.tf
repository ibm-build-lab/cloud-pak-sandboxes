// General output parameters
output "resource_group" {
  value = var.resource_group
}

// ROKS output parameters
output "cluster_endpoint" {
  value = module.cluster.endpoint
}
output "cluster_id" {
  value = local.enable_cluster ? module.cluster.id : var.cluster_id
}
output "cluster_name" {
  value = local.enable_cluster ? module.cluster.name : ""
}
output "kubeconfig" {
  value = data.ibm_container_cluster_config.cluster_config.config_file_path
}

//output "namespace" {
//  value = var.namespace
//}

//output "cp4ba_url" {
//  description = "Use this URL to access your Cloud Pak for Business Automation"
//  value       = module.cp4auto.cp4auto_endpoint
//}

output "cp4ba_username" {
  description = "Username for your Cloud Pak for Business Automation"
  value = module.cp4auto.cp4auto_username
}

output "cp4ba_password" {
  description = "Password for your Cloud Pak Integration deployment"
  value = module.cp4auto.cp4auto_password
}

// output "cluster_config" {
//   value = module.cluster.config
// }


