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

// output "cluster_config" {
//   value = module.cluster.config
// }

// CP4DATA output parameters
// output "cp4data_endpoint" {
//   value = module.cp4data.endpoint
// }
// output "cp4data_user" {
//   value = module.cp4data.user
// }
// output "cp4data_password" {
//   value = module.cp4data.password
// }
output "cp4data_namespace" {
  value = module.cp4data.namespace
}
