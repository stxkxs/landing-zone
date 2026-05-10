variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "team" {
  description = "The team owning this infrastructure"
  type        = string
}

variable "enable_shared_vpc" {
  description = "Whether to enable Shared VPC configuration"
  type        = bool
  default     = true
}

variable "service_project_ids" {
  description = "The list of service project IDs to attach to the Shared VPC host"
  type        = list(string)
  default     = []
}

variable "private_dns_zones" {
  description = "Private DNS zones for inter-project resolution"
  type = map(object({
    dns_name    = string
    description = string
  }))
  default = {}
}

variable "enable_dns_inbound_forwarding" {
  description = "Whether to enable DNS inbound forwarding on the Shared VPC"
  type        = bool
  default     = false
}

variable "internal_cidr_ranges" {
  description = "The internal CIDR ranges allowed in the Shared VPC firewall"
  type        = list(string)
  default     = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
}
