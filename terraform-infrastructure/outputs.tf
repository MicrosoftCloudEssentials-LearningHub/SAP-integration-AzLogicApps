output "logic_app_url" {
  description = "The URL of the deployed Logic App"
  value       = var.logic_app_platform == "consumption" ? azurerm_logic_app_trigger_http_request.health[0].callback_url : null
}

output "logic_app_id" {
  description = "The ID of the deployed Logic App"
  value       = var.logic_app_platform == "consumption" ? azurerm_logic_app_workflow.logic_app[0].id : azurerm_logic_app_standard.logic_app[0].id
}

output "logic_app_kind" {
  description = "The kind of Logic App that was deployed (Stateful or Stateless)"
  value       = var.logic_app_platform == "standard" ? var.logic_app_kind : null
}

output "resource_group_name" {
  description = "The name of the resource group containing the Logic App"
  value       = azurerm_resource_group.rg.name
}

output "app_insights_instrumentation_key" {
  description = "The instrumentation key for Application Insights"
  value       = azurerm_application_insights.appinsights.instrumentation_key
  sensitive   = true
}

