# SAP OData Integration with Azure Logic Apps - Overview

Costa Rica

[![GitHub](https://badgen.net/badge/icon/github?icon=github&label)](https://github.com)
[![GitHub](https://img.shields.io/badge/--181717?logo=github&logoColor=ffffff)](https://github.com/)
[brown9804](https://github.com/brown9804)

Last updated: 2025-08-27

-----------------------------

> [!NOTE]
> When implementing SAP integration with Azure Logic Apps, understanding the difference between stateful and stateless modes is crucial, particularly for handling session cookies and maintaining state between requests.

<details>
<summary><b>Stateful mode</b> (Click to expand)</summary>

> In stateful Logic Apps, the workflow engine maintains the state of each action execution, which can help with long-running operations but doesn't solve the cookie handling challenge with SAP.

- **Configuration**: When selecting a Standard type Logic App, you can configure your resource to use stateful mode.
- **Requirements**: For stateful mode with SAP connectivity, you often need to enable virtual network integration and configure private ports.
- **Persistence**: While the workflow state is persisted, individual HTTP connectors still don't maintain cookie state between actions.
- **Documentation**: For detailed configuration, see [Enable stateful mode for stateless built-in connectors in Azure Logic Apps](https://learn.microsoft.com/en-us/azure/connectors/enable-stateful-affinity-built-in-connectors)

</details>

<details>
<summary><b>Stateless mode</b> (Click to expand)</summary>

> Stateless Logic Apps execute each action independently, which is the default behavior for HTTP actions regardless of the overall workflow type.

- **Cookie Handling Challenges**: Each HTTP action operates independently with no shared cookie jar or session manager.
- **Header Modifications**: Logic Apps may alter cookie headers before sending:
  - Changing delimiters or the order of cookies
  - Adding attributes like Path, Secure, or HttpOnly (which should not appear in the Cookie header)
  - Treating the cookie string as plain text rather than as a proper cookie object
- **Performance**: Stateless workflows generally have better performance and scalability but require manual session management.
- **Documentation**: For more details, see [Call External HTTPS Endpoints from Workflows](https://learn.microsoft.com/en-us/azure/logic-apps/workflow-definition-language-functions-reference).

</details>

> Logic Apps `doesn't maintain a cookie jar or session state between HTTP actions`. When extracting cookies from SAP responses, `Logic Apps may modify the format` in ways that cause authentication failures (403 Forbidden) in subsequent requests to SAP systems, which are `very particular about cookie formats`.


> [!TIP]
> SAP OData (Open Data Protocol) is a standardized REST-based protocol that SAP systems use to expose their business data and functionality. Key aspects include:
> - **REST API Standard**: OData follows REST principles and enables CRUD operations on SAP data
> - **Business Data Access**: Provides a standardized way to access SAP business objects, transactions, and reports

<details>
<summary><b>List of References</b> (Click to expand)</summary>

- [Enable stateful mode for stateless built-in connectors in Azure Logic Apps](https://learn.microsoft.com/en-us/azure/connectors/enable-stateful-affinity-built-in-connectors)
- [Connect to SAP from workflows in Azure Logic Apps](https://learn.microsoft.com/en-us/azure/logic-apps/connectors/sap?tabs=consumption)
- [Call external HTTP or HTTPS endpoints from workflows in Azure Logic Apps](https://learn.microsoft.com/en-us/azure///connectors/connectors-native-http?tabs=standard#known-issues)

</details>

<details>
<summary><b>Table of Contents</b> (Click to expand)</summary>

</details>

## Integration Approaches

<img width="4217" height="2630" alt="image" src="https://github.com/user-attachments/assets/e4cb0eb8-5eff-4052-9e92-284870d08bab" />

### Manual Cookie Parsing in Logic

### Custom Inline JavaScript

<img width="600" alt="image" src="https://github.com/user-attachments/assets/f724c1c0-d804-4938-9b84-c9f3ebe47eae" />


### Azure API Management Gateway

### Azure Fuction App 

<!-- START BADGE -->
<div align="center">
  <img src="https://img.shields.io/badge/Total%20views-1304-limegreen" alt="Total views">
  <p>Refresh Date: 2025-08-27</p>
</div>
<!-- END BADGE -->
