variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "team" {
  description = "Team name for resource tagging"
  type        = string
}

variable "enable_defender" {
  description = "Enable Microsoft Defender for Cloud"
  type        = bool
  default     = true
}

variable "defender_plan_types" {
  description = "List of Defender for Cloud plan types to enable"
  type        = list(string)
  default = [
    "VirtualMachines",
    "AppServices",
    "SqlServers",
    "SqlServerVirtualMachines",
    "StorageAccounts",
    "KubernetesService",
    "ContainerRegistry",
    "KeyVaults",
    "Dns",
    "Arm",
    "Containers",
  ]
}

variable "security_contact_email" {
  description = "Email address for Defender for Cloud security alerts"
  type        = string
  default     = ""
}

variable "security_contact_phone" {
  description = "Phone number for Defender for Cloud security alerts"
  type        = string
  default     = ""
}

variable "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace for Defender data export"
  type        = string
  default     = null
}
