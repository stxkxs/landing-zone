variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "team" {
  description = "The team owning this infrastructure"
  type        = string
}

variable "org_id" {
  description = "The GCP organization ID"
  type        = string
}

variable "boolean_constraints" {
  description = "Additional boolean organization policy constraints to enforce"
  type        = map(bool)
  default     = {}
}

variable "list_constraints" {
  description = "List-type organization policy constraints with allowed or denied values"
  type = map(object({
    allowed_values = list(string)
    denied_values  = list(string)
  }))
  default = {}
}
