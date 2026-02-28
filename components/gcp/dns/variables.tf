variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "team" {
  description = "The team owning this infrastructure"
  type        = string
}

variable "domain_name" {
  description = "The domain name for the DNS managed zone"
  type        = string
}

variable "create_managed_zone" {
  description = "Whether to create a Cloud DNS managed zone"
  type        = bool
  default     = true
}

variable "enable_dnssec" {
  description = "Whether to enable DNSSEC for the managed zone"
  type        = bool
  default     = false
}
