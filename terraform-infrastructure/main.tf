################################################
# SAP Integration with Azure Logic Apps
# Terraform Infrastructure Configuration
#
# This configuration can deploy either:
# - Logic App Consumption (multi-tenant), or
# - Logic App Standard (single-tenant / Workflow Standard)
#
# NOTE: Logic App Standard requires a Storage Account with Shared Key enabled
# for its Azure Files content share. If Azure Policy enforces Shared Key off,
# Standard deployments will fail unless that policy is changed/excepted.
#################################################

locals {
  deploy_consumption = var.logic_app_platform == "consumption"
  deploy_standard    = var.logic_app_platform == "standard"
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Application Insights for Logic App monitoring
resource "azurerm_log_analytics_workspace" "loganalytics" {
  name                = var.log_analytics_workspace_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags

  depends_on = [azurerm_resource_group.rg]
}

resource "azurerm_application_insights" "appinsights" {
  name                = var.app_insights_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  workspace_id        = azurerm_log_analytics_workspace.loganalytics.id
  application_type    = "web"
  tags                = var.tags

  depends_on = [azurerm_log_analytics_workspace.loganalytics]
}

# Logic App (Consumption / multi-tenant)
resource "azurerm_logic_app_workflow" "logic_app" {
  count               = local.deploy_consumption ? 1 : 0
  name                = var.logic_app_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags

  identity {
    type = "SystemAssigned"
  }
}

# Simple HTTP-triggered health check (Consumption)
resource "azurerm_logic_app_trigger_http_request" "health" {
  count        = local.deploy_consumption ? 1 : 0
  name         = "request"
  logic_app_id = azurerm_logic_app_workflow.logic_app[0].id
  method       = "GET"
  relative_path = "/"

  schema = <<SCHEMA
{}
SCHEMA
}

resource "azurerm_logic_app_action_custom" "health_response" {
  count        = local.deploy_consumption ? 1 : 0
  name         = "Response"
  logic_app_id = azurerm_logic_app_workflow.logic_app[0].id

  body = <<BODY
{
  "inputs": {
    "statusCode": 200,
    "body": {
      "status": "healthy",
      "message": "Logic App health check is responding",
      "timestamp": "@utcNow()",
      "mode": "Consumption"
    }
  },
  "kind": "Http",
  "runAfter": {},
  "type": "Response"
}
BODY

  depends_on = [azurerm_logic_app_trigger_http_request.health]
}

# Logic App Standard (single-tenant / Workflow Standard)
resource "azurerm_service_plan" "logic_app_plan" {
  count               = local.deploy_standard ? 1 : 0
  name                = coalesce(var.service_plan_name, "${var.logic_app_name}-plan")
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "WS1"
  tags                = var.tags
}

resource "azurerm_storage_account" "logic_app" {
  count                    = local.deploy_standard ? 1 : 0
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Required for Logic App Standard's Azure Files content share.
  # If Azure Policy enforces this to false, Standard deployments will fail.
  shared_access_key_enabled = true

  # Keep defaults conservative.
  min_tls_version                 = "TLS1_2"
  public_network_access_enabled   = true
  allow_nested_items_to_be_public = false

  tags = var.tags

  lifecycle {
    precondition {
      condition     = var.storage_account_name != null && can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
      error_message = "For Logic App Standard, set storage_account_name to a new Storage Account name (3-24 chars, lowercase letters/numbers only)."
    }
  }
}

resource "azurerm_logic_app_standard" "logic_app" {
  count               = local.deploy_standard ? 1 : 0
  name                = var.logic_app_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  app_service_plan_id      = azurerm_service_plan.logic_app_plan[0].id
  storage_account_name     = azurerm_storage_account.logic_app[0].name
  storage_account_access_key = azurerm_storage_account.logic_app[0].primary_access_key

  version = "~4"

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

resource "null_resource" "standard_zip_deploy" {
  count = local.deploy_standard ? 1 : 0

  triggers = {
    logic_app_kind = var.logic_app_kind
  }

  provisioner "local-exec" {
    command = "powershell -NoProfile -ExecutionPolicy Bypass -Command \"$ErrorActionPreference='Stop'; $root='${path.module}\\..'; $src=Join-Path $root 'temp-deployment-files'; $dst=Join-Path '${path.module}' '.standard-package'; $zip=Join-Path '${path.module}' '.standard-package.zip'; if(Test-Path $dst){Remove-Item $dst -Recurse -Force}; Copy-Item $src $dst -Recurse -Force; $wf=Join-Path $dst 'workflows\\health-check.json'; $json=Get-Content $wf -Raw | ConvertFrom-Json; $json.kind='${var.logic_app_kind}'; $json.definition.actions.Response.inputs.body.mode='${var.logic_app_kind}'; $json | ConvertTo-Json -Depth 64 | Set-Content -Path $wf -Encoding UTF8; if(Test-Path $zip){Remove-Item $zip -Force}; Compress-Archive -Path (Join-Path $dst '*') -DestinationPath $zip -Force; az webapp deployment source config-zip -g ${azurerm_resource_group.rg.name} -n ${azurerm_logic_app_standard.logic_app[0].name} --src $zip --only-show-errors\""
  }

  depends_on = [azurerm_logic_app_standard.logic_app]
}






