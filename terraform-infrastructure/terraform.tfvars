# Resource names for demo parameterization
log_analytics_workspace_name = "lawsapintegrationlogicappbrx18p"
app_insights_name           = "aisapintegrationlogicappbrx18p"

# Which platform to deploy:
# - "consumption" (default; works with restricted Storage policies)
# - "standard"    (requires a Storage Account with Shared Key enabled)
logic_app_platform = "consumption"

# Standard-only (set these ONLY when logic_app_platform = "standard")
# IMPORTANT: Do not point at an existing policy-locked Storage Account that has Shared Key disabled.
# service_plan_name    = "aspsapintegrationlogicappbrx18p"
# storage_account_name = "<newunique_storage_account_name>"
# Logic App configuration for SAP integration
subscription_id        = "407f4106-0fd3-42e0-9348-3686dd1e7347" # "<your_subscription_id>"

# Logic App Kind Configuration
# -------------------------------------
# STATEFUL (DEFAULT FOR SAP INTEGRATION)
# Maintains state between requests, supports long-running workflows (up to 1 year)
# Retains full run history, good for SAP integration that requires session persistence
logic_app_kind = "Stateful"

# STATELESS (UNCOMMENT BELOW AND COMMENT ABOVE TO USE)
# For simpler integrations without session requirements (max 5 min execution)
# Lower cost as no run history is stored
# -------------------------------------
# logic_app_kind = "Stateless"

# Common settings
logic_app_name        = "saplappbrx18p-linux-unique"
resource_group_name   = "RG-sap-integrationx18p-linux"
location              = "westus"
tags = {
  Environment = "Development"
  Project     = "SAP Integration"
}

# STATEFUL MODE SETTINGS (currently active)
# Retention days for workflow run history
stateful_retention_days = 30

# STATELESS MODE SETTINGS (uncomment if switching to Stateless mode)
# Uncomment the below line and comment out stateful_retention_days above when using Stateless
# stateless_concurrency = 10

