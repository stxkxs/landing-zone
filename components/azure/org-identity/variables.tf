variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "tenant_id" {
  description = "Entra ID (Azure AD) tenant ID"
  type        = string
}

variable "team" {
  description = "Team name for resource tagging"
  type        = string
}

variable "management_groups" {
  description = "Map of management groups to create"
  type = map(object({
    display_name               = string
    parent_management_group_id = optional(string)
  }))
  default = {}
}

variable "custom_roles" {
  description = "Map of custom role definitions with optional assignments"
  type = map(object({
    description = string
    scope       = string
    permissions = object({
      actions          = list(string)
      not_actions      = optional(list(string), [])
      data_actions     = optional(list(string), [])
      not_data_actions = optional(list(string), [])
    })
    assignable_scopes = list(string)
    assignments = optional(list(object({
      principal_id = string
      scope        = string
    })), [])
  }))
  default = {}
}
