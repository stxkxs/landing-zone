variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "team" {
  description = "Team name for resource tagging"
  type        = string
}

variable "management_group_id" {
  description = "Management group ID for policy scope"
  type        = string
}

variable "location" {
  description = "Azure region for managed identity deployment"
  type        = string
}

variable "enable_guardrails_initiative" {
  description = "Enable the organization guardrails policy initiative"
  type        = bool
  default     = true
}

variable "allowed_locations" {
  description = "List of allowed Azure locations for resource deployment"
  type        = list(string)
  default     = ["westus2", "eastus2", "centralus"]
}

variable "required_tags" {
  description = "List of tag names required on all resources"
  type        = list(string)
  default     = ["Environment", "ManagedBy", "Project"]
}

variable "policy_definitions" {
  description = "Map of custom policy definitions to create"
  type = map(object({
    mode                = optional(string, "All")
    display_name        = string
    description         = string
    management_group_id = optional(string)
    policy_rule         = string
    parameters          = optional(string)
    metadata            = optional(string)
  }))
  default = {}
}

variable "standalone_assignments" {
  description = "Map of standalone policy assignments at the management group level"
  type = map(object({
    display_name         = string
    policy_definition_id = string
    management_group_id  = optional(string)
    enforce              = optional(bool, true)
    requires_identity    = optional(bool, false)
  }))
  default = {}
}
