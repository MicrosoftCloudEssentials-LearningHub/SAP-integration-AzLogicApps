# SAP OData Integration with Azure Logic Apps - Overview

Costa Rica

[![GitHub](https://badgen.net/badge/icon/github?icon=github&label)](https://github.com)
[![GitHub](https://img.shields.io/badge/--181717?logo=github&logoColor=ffffff)](https://github.com/)
[brown9804](https://github.com/brown9804)

Last updated: 2025-08-27

-----------------------------

> [!NOTE]
> When implementing SAP integration with Azure Logic Apps, understanding the difference between stateful and stateless modes is crucial, particularly for handling session cookies and maintaining state between requests.

> Logic Apps `doesn't maintain a cookie jar or session state between HTTP actions`. When extracting cookies from SAP responses, `Logic Apps may modify the format` in ways that cause authentication failures (403 Forbidden) in subsequent requests to SAP systems, which are `very particular about cookie formats`.

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

> Uses built-in Logic Apps actions to manually extract, parse, and format cookie values through string manipulation. This approach relies on Logic Apps' native actions like "Parse JSON," "Compose," "For Each," and string functions to process the Set-Cookie headers returned from SAP systems and format them correctly for subsequent requests.

<details>
<summary><b>How It Works</b> (Click to expand)</summary>

1. Send an initial GET request to SAP with the X-CSRF-Token: Fetch header
2. Use `Parse JSON` action to extract the Set-Cookie header values from the response
3. Implement a `For Each` loop to iterate through multiple cookies if present
4. Use `substring` and `indexOf` expressions to isolate the name=value portion of each cookie
5. Use `Compose` or `Variables` actions to build the properly formatted cookie string
6. Include the formatted cookie string in the Cookie header of subsequent POST requests

</details>

<details>
<summary><b>Pros:</b> (Click to expand)</summary>
  
- No additional services required, keeping the architecture simple and contained within Logic Apps
- Uses native Logic Apps actions without requiring custom code or scripts
- Simple to implement for basic scenarios with predictable cookie formats
- No extra costs beyond the standard Logic Apps execution pricing
- Familiar workflow designer interface for those already comfortable with Logic Apps
- Maintains all logic in a single service, simplifying monitoring and troubleshooting

</details>

<details>
<summary><b>Considerations:</b> (Click to expand)</summary>
  
- Limited string manipulation capabilities compared to full programming languages
- Complex expressions can become unwieldy and difficult to maintain
- Can't handle complex cookie formats with special characters or multiple cookie attributes
- Difficult to debug header issues since Logic Apps doesn't provide detailed HTTP header logging
- Often fails with SAP's strict requirements for exact cookie formatting
- Risk of unexpected failures if SAP changes its cookie format or adds new cookies
- May require complex workarounds for edge cases like URL-encoded values in cookies
- Performance impact from multiple string manipulation actions in complex workflows
- No built-in session management or cookie jar functionality in Logic Apps
- Workflow becomes less readable as cookie parsing logic grows more complex

</details>

### Custom Inline JavaScript

> Uses inline JavaScript code in Logic Apps to correctly parse and format cookies, providing more flexibility and control. This approach leverages the Logic Apps "Inline Code" action to execute JavaScript that can handle complex string manipulation and cookie formatting with the precision required for SAP integration.

<img width="600" alt="image" src="https://github.com/user-attachments/assets/f724c1c0-d804-4938-9b84-c9f3ebe47eae" />

<details>
<summary><b>How It Works</b> (Click to expand)</summary>

1. Send an initial GET request to SAP with the X-CSRF-Token: Fetch header
2. Extract the Set-Cookie and X-CSRF-Token headers from the response
3. Use the `Inline Code` action to execute JavaScript that:
   - Converts the cookie header to an array if it's not already
   - Parses each cookie string to extract just the name=value portion
   - Joins the cookies with the correct delimiter (semicolon+space)
   - Formats everything exactly as SAP expects
4. Store the CSRF token in a variable or directly in the next action
5. Use the formatted cookie string in the Cookie header of the subsequent POST request
6. Include the CSRF token in the X-CSRF-Token header of the POST request

</details>

<details>
<summary><b>Pros:</b> (Click to expand)</summary>

- Greater control over cookie parsing with full JavaScript capabilities
- More flexible string manipulation using array methods, regex, and other JS features
- Can handle complex header formatting requirements and edge cases
- Works with current Logic App structure without architectural changes
- No additional Azure services needed, keeping everything in one workflow
- Better handling of special characters and different cookie formats
- Can implement conditional logic for different cookie scenarios
- More concise and readable than complex Logic Apps expressions
- Easily adaptable if SAP changes cookie formats in the future
- Can be extended to handle other complex integration requirements

</details>

<details>
<summary><b>Considerations:</b> (Click to expand)</summary>

- Requires JavaScript knowledge to implement and maintain
- Limited debugging capabilities compared to full development environments
- Code must be maintained within the Logic App rather than in source control
- Security considerations for inline code in enterprise environments
- Some organizations have policies restricting custom code in Logic Apps
- Performance impact for very large code blocks (though cookie parsing is lightweight)
- No step-through debugging or breakpoints available
- Error handling must be implemented within the JavaScript code
- Changes require modifying the Logic App workflow
- May require approval from security teams in some organizations

</details>

### Azure API Management Gateway

> Deploys Azure API Management (APIM) as a gateway between Logic Apps and SAP to maintain session state and properly format headers. This approach leverages APIM's powerful policy engine to handle complex header manipulation, authentication, and session management requirements for SAP integration.

<details>
<summary><b>How It Works</b> (Click to expand)</summary>

1. Create an API in Azure API Management that proxies your SAP OData endpoints
2. Configure policies in APIM to:
   - Extract and store CSRF tokens from SAP responses
   - Properly format and manage cookies across requests
   - Handle authentication headers and session persistence
   - Apply consistent header formatting rules
3. Logic App calls the APIM endpoint instead of calling SAP directly
4. APIM handles all cookie and token management behind the scenes
5. APIM forwards properly formatted requests to SAP
6. APIM returns SAP responses to the Logic App, handling any required transformations

</details>

<details>
<summary><b>Pros:</b> (Click to expand)</summary>

- Proper session management with built-in cookie handling capabilities
- Consistent header formatting using APIM's policy expressions
- Can add security policies for authentication, throttling, and IP filtering
- Reusable for multiple Logic Apps, providing a centralized integration point
- Better performance monitoring with detailed metrics and logging
- Can implement complex request/response transformations using policies
- Supports caching to reduce load on SAP systems
- Provides a facade that shields Logic Apps from SAP API changes
- Enables more advanced error handling and retry mechanisms
- Supports mocking and testing without calling actual SAP endpoints

</details>

<details>
<summary><b>Considerations:</b> (Click to expand)</summary>

- Additional Azure service to deploy, configure, and manage
- Added cost for APIM service (though consumption tier may be cost-effective)
- More complex architecture with an additional component
- Additional network hop that could impact performance
- Requires knowledge of APIM policy expressions and configuration
- Debugging can be more complex with distributed components
- Initial setup requires more time and planning
- May be overkill for simple integration scenarios
- Adds another potential point of failure in the architecture
- Requires ongoing maintenance of both Logic Apps and APIM components

</details>

### Azure Function Intermediary

> Creates a custom Azure Function to handle communication with SAP, managing cookies, CSRF tokens, and header formatting. This approach uses code in a language like C# or JavaScript to handle HTTP requests with full control over headers, authentication, and session state.

<details>
<summary><b>How It Works</b> (Click to expand)</summary>

1. Create an Azure Function with an HTTP trigger
2. Implement the function with code that:
   - Receives requests from Logic Apps
   - Handles SAP authentication and session persistence
   - Manages cookies and CSRF tokens correctly
   - Makes properly formatted HTTP requests to SAP
   - Returns SAP responses to Logic Apps with any required transformations
3. Logic App calls the Azure Function instead of SAP directly
4. Function maintains session context and handles all cookie formatting
5. Function implements proper error handling and retries as needed
6. Function returns processed results to Logic App

</details>

<details>
<summary><b>Pros:</b> (Click to expand)</summary>

- Full control over HTTP requests using HttpClient or similar libraries
- Proper cookie and session handling with programmatic control
- Can implement complex logic in a full programming language (C#, JavaScript, etc.)
- Better error handling capabilities with try/catch blocks and custom logic
- Reusable component that can be called from multiple Logic Apps
- Can leverage full debugging capabilities in development environments
- Supports automated testing with unit and integration tests
- Code can be maintained in source control with proper CI/CD processes
- Can implement advanced authentication and security patterns
- Provides complete flexibility for complex integration requirements

</details>

<details>
<summary><b>Considerations:</b> (Click to expand)</summary>

- Additional Azure service to deploy, configure, and manage
- Added development effort to create and maintain custom code
- More complex architecture with an additional component
- Additional network hop that could impact performance
- Requires software development skills beyond Logic Apps configuration
- Cold start delays possible with consumption plan Functions
- Must handle scaling and performance considerations
- Additional cost for Azure Functions execution and storage
- Debugging across components can be more challenging
- Requires proper error handling to avoid failed states

</details>

## Implementation workflow

<img width="1222" height="1561" alt="image" src="https://github.com/user-attachments/assets/8c87803d-81e0-40f1-9032-072bd008d61a" />


<!-- START BADGE -->
<div align="center">
  <img src="https://img.shields.io/badge/Total%20views-1304-limegreen" alt="Total views">
  <p>Refresh Date: 2025-08-27</p>
</div>
<!-- END BADGE -->
