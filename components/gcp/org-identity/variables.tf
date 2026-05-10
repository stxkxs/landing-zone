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

variable "session_duration" {
  description = "The session duration for the workforce identity pool"
  type        = string
  default     = "3600s"
}

variable "oidc_issuer_uri" {
  description = "The OIDC issuer URI for the workforce identity pool provider"
  type        = string
  default     = ""
}

variable "oidc_client_id" {
  description = "The OIDC client ID for the workforce identity pool provider"
  type        = string
  default     = ""
}

variable "attribute_mapping" {
  description = "The attribute mapping for the workforce identity pool provider"
  type        = map(string)
  default = {
    "google.subject" = "assertion.sub"
    "google.groups"  = "assertion.groups"
  }
}

variable "attribute_condition" {
  description = "The attribute condition CEL expression for the workforce identity pool provider"
  type        = string
  default     = ""
}

variable "org_iam_bindings" {
  description = "Organization-level IAM bindings"
  type = map(object({
    role   = string
    member = string
  }))
  default = {}
}
