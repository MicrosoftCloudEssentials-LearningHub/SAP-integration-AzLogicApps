# Resource names for demo parameterization
variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics Workspace"
  type        = string
}

variable "app_insights_name" {
  description = "Name of the Application Insights instance"
  type        = string
}

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "logic_app_platform" {
  description = "Which Logic Apps platform to deploy: 'consumption' (multi-tenant) or 'standard' (single-tenant)."
  type        = string
  default     = "consumption"
  validation {
    condition     = contains(["consumption", "standard"], var.logic_app_platform)
    error_message = "logic_app_platform must be either 'consumption' or 'standard'."
  }
}

variable "logic_app_kind" {
  description = "For Logic App Standard workflows, controls whether deployed workflow(s) are 'Stateful' or 'Stateless'. (Consumption does not support this toggle.)"
  type        = string
  default     = "Stateful"
  validation {
    condition     = contains(["Stateful", "Stateless"], var.logic_app_kind)
    error_message = "The logic_app_kind must be either 'Stateful' or 'Stateless'."
  }
}

variable "logic_app_name" {
  description = "The name of the Logic App"
  type        = string
}

variable "service_plan_name" {
  description = "(Standard only) Name of the App Service Plan (Workflow Standard)."
  type        = string
  default     = null
}

variable "storage_account_name" {
  description = "(Standard only) Name of the Storage Account used by Logic App Standard for its content share. Shared Key must be enabled for Standard to work."
  type        = string
  default     = null
}

variable "stateful_retention_days" {
  description = "(Optional) Retention days for workflow run history. Note: applies to Logic App Standard/Consumption differently and may be ignored by this template."
  type        = number
  default     = 30
}

variable "stateless_concurrency" {
  description = "(Optional) Max concurrent workflow executions for stateless scenarios. Note: may be ignored by this template."
  type        = number
  default     = 10
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region to deploy resources to"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

