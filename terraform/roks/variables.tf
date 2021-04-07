variable "project_name" {}
variable "environment" {}

variable "resource_group" {
  type    = string
}

variable "region" {
  type    = string
}

variable "vpc_zone_names" {
  type    = list(string)
}

variable "enable_custom_address_prefix" {
  type    = bool
}

variable "address_prefix_cidr" {
  type    = list(string)
}

variable "enable_custom_subnet" {
  type    = bool
}

variable "subnet_cidr" {
  type    = list(string)
}

variable "enable_public_gateway" {
    # default = false
  type    = bool
}

variable "flavors" {
  type    = list(string)
}

variable "workers_count" {
  type    = list(number)
}

variable "k8s_version" {
  type    = string
}

# variable "enable_db_service" {
#   type    = bool
# }

# variable "db_name" {
#   type    = string
# }

# variable "db_plan" {
#   type    = string
# }

# variable "db_service_name" {
#   type    = string
# }

# variable "db_admin_password" {
#   type    = string
# }

# variable "db_memory_allocation" {
#   type    = number
# }

# variable "db_disk_allocation" {
#   type    = number
# }

# variable "db_whitelist_ip_address" {
#   type    = string
# }

# variable "es_kafka_service_name" {
#   type    = string
# }

# variable "enable_event_streams_service" {
#   type    = bool
# }

# variable "es_kafka_plan" {
#   type    = string
# }

# variable "es_kafka_topic_name" {
#   type    = string
# }

# variable "es_kafka_topic_partitions" {
#   type    = number
# }

# variable "es_kafka_topic_cleanup_policy" {
#   type    = string
# }

# variable "es_kafka_topic_retention_ms" {
#   type    = number
# }

# variable "es_kafka_topic_retention_bytes" {
#   type    = number
# }

# variable "es_kafka_topic_segment_bytes" {
#   type    = number
# }

# variable "enable_vpn" {
#   type    = bool
# }

# variable "vpn_connection_pre_shared_key" {
#   type    = list(string)
# }

# variable "vpn_connection_interval" {
#   type    = list(number)
# }

# variable "vpn_connection_timeout" {
#   type    = list(number)
# }

# variable "vpn_connection_admin_state_up" {
#   type    = list(bool)
# }

# variable "vpn_connection_action" {
#   type    = list(string)
# }

# variable "vpn_peer_cidr" {
#   type    = list(string)
# }

# variable "vpn_peer_public_address" {
#   type    = list(string)
# }

locals {
  max_size = length(var.vpc_zone_names)
}