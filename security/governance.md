# Governance & Control

GKS uses a **Policy-as-Code** governance model to restrict AI agency.

## Policy Decision Point (PDP)
**Component**: **Bifrost**
*   **Role**: Determines *if* an action is allowed.
*   **Mechanism**:
    *   Evaluates `UserChatRequest` against `SystemPolicies`.
    *   Checks explicit allowlists for Tools.
    *   Checks "Confirmation Required" flags for high-risk actions.
    *   **Output**: A `RoutingDecision` that is cryptographically signed (planned) or passed via trusted internal network.

## Policy Enforcement Point (PEP)
**Component**: **Einbroch**
*   **Role**: Enforces the decision.
*   **Mechanism**:
    *   Receives the `RoutingDecision`.
    *   **Fail-Closed**: If a tool is requested by the generated Plan but *not* in `decision.tools.allowed`, Einbroch rejects execution immediately.
    *   **Sandboxing**: Tools run in isolated functions/containers.

## Human-in-the-Loop
For high-risk actions (e.g., "Rotate Production Keys"), Bifrost can emit a `confirmation_required: true` signal. Einbroch will pause and wait for a separate human-approval API call (Future Phase).
