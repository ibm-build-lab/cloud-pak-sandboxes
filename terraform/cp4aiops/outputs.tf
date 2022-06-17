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

output "cp4aiops_aiman_url" {
  description = "Access your Cloud Pak for AIOPS AIManager deployment at this URL."
  value = module.install_cp4aiops.ai_manager_endpoint
}

output "cp4aiops_aiman_user" {
  description = "Username for your Cloud Pak for AIOPS AIManager deployment."
  value = module.install_cp4aiops.ai_manager_user
}

output "cp4aiops_aiman_password" {
  description = "Password for your Cloud Pak for AIOPSAIManager  deployment."
  value = module.install_cp4aiops.ai_manager_password
}

output "cp4aiops_evtman_url" {
  description = "Access your Cloud Pak for AIOP EventManager deployment at this URL."
  value = module.install_cp4aiops.event_manager_endpoint
}

output "cp4aiops_evtman_user" {
  description = "Username for your Cloud Pak for AIOPS EventManager deployment."
  value = module.install_cp4aiops.event_manager_user
}

output "cp4aiops_evtman_password" {
  description = "Password for your Cloud Pak for AIOPS EventManager deployment."
  value = module.install_cp4aiops.event_manager_password
}
