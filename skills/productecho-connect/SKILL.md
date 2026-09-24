---
name: productecho-connect
description: >-
  Use when connecting Codex or ChatGPT to the ProductEcho Cloud MCP server, guiding automated OAuth 2.0 / 2.1
  browser authorization, validating connection status and discovery metadata, discovering workspace context
  and quotas, managing credentials, handling 401 re-authentication, and escalating issues to platform administrators.
---

# ProductEcho MCP Connection & Workspace Governance Skill

This skill guides Codex and AI agents on connecting to the ProductEcho Cloud MCP Server via automated OAuth 2.0 / 2.1 PKCE or static workspace API keys, discovering workspace context, recovering from unauthenticated states, and managing cloud resources.

---

## 🌟 Core Value Proposition & Key Features

- **Automated OAuth 2.0 / 2.1 PKCE Flow**: One-click browser authorization without manual credential copying.
- **Dynamic Standards Discovery**: Automatic configuration via RFC 8414 and RFC 9728 discovery metadata (`/.well-known/oauth-protected-resource`).
- **Resilient 401 Recovery**: Gracefully triggers OAuth2 consent or instructs the user on reconnecting.
- **Unified Workspace Governance**: Query workspace metadata, active cloud resources, and tier quotas with single-request precision.
- **Direct Support Escalation**: Submit priority tickets and technical inquiries directly to platform administrators (`admin@productecho.com`).

---

## 🔐 Authentication & Setup Guide

### Method 1: Automated OAuth 2.0 / 2.1 (Recommended for Codex, ChatGPT, & Claude)

The ProductEcho MCP integration natively negotiates OAuth 2.1 with PKCE (`S256`):

1. **Install or Enable Plugin**: In Codex or your MCP client, select the ProductEcho plugin.
2. **One-Click Authorization**:
   - The client connects to `https://api.productecho.com/mcp`.
   - A browser window opens to the authorization consent screen (`/oauth/authorize`).
   - Click **"Authorize Access"** to grant permissions for your workspace.
3. **Session Established**:
   - The client receives an OAuth Bearer token (`pe_at_...`) and automatically caches it.
   - Access tokens last 15 minutes by default. A refresh token renews them silently and rotates to a new 30-day token on use, so normal expiry does not reopen browser authorization.
   - MCP tools (`get_workspace_info`, `list_postgres`, `list_applications`, etc.) become active immediately.

#### OAuth Permission Bundles

- `mcp:fullwrite` is the default for full-stack work. One consent grants workspace reads, application deployment and management, PostgreSQL provisioning and management, and database credential access.
- `mcp:fullread` grants read-only access to workspace details, applications, and PostgreSQL resources.
- `mcp:support:write` is separate and is requested only when the user wants to send a support request.
- Granular `mcp:apps:*`, `mcp:postgres:*`, and `mcp:workspace:*` scopes remain available to clients that need least-privilege access.

#### `.mcp.json` Configuration

```json
{
  "productecho": {
    "command": "npx",
    "args": ["-y", "mcp-remote", "https://api.productecho.com/mcp"]
  }
}
```


## 🔄 401 Unauthorized & Session Recovery Handling

When an MCP tool call fails or tools are unavailable in the current session:

1. **Explain the Status**: Inform the user that the ProductEcho MCP session needs authorization.
2. **Provide the Resolution Steps**:
   - If using the **OAuth2 Plugin / `mcp-remote`**: Trigger authorization to open `https://api.productecho.com/oauth/authorize` and click **Authorize Access**.
   - If using **Static API Keys**: Set `export PRODUCT_ECHO_API_KEY="pe_live_..."` from **Settings → API Keys**.
3. **Verify Connection**: Invoke `get_workspace_info` to confirm active workspace access and proceed with resource management.

---

## 🛠️ Connection & Governance Tools

| Tool Name            | Value Provided                                                                       | Key Parameters                                                        |
| :------------------- | :----------------------------------------------------------------------------------- | :-------------------------------------------------------------------- |
| `get_workspace_info` | Query authenticated workspace name, slug, ID, owner email, tier, and resource quotas | None                                                                  |
| `list_applications`  | List deployed web applications and APIs for the tenant                               | `deployment_status` (optional filter)                                 |
| `list_postgres`      | List all active and paused database instances for the tenant                         | None                                                                  |
| `submit_admin_query` | Open a priority support ticket or escalation directly to `admin@productecho.com`     | `message` (required), `subject`, `topic`, `error_details`, `metadata` |

---

## 📋 Recommended Workflows

### 1. Workspace Discovery on Session Start

Always invoke `get_workspace_info` at the beginning of a cloud management session to inspect:

- Workspace slug and environment details
- Tier quotas (maximum concurrent applications, database storage allocation)
- Owner contact details

### 2. Infrastructure Health & Resource Audit

To get a full snapshot of active cloud infrastructure:

1. Call `list_applications` to view deployed web services, domain endpoints, and live status.
2. Call `list_postgres` to audit databases, storage allocation, and status.

### 3. Priority Support & Issue Escalation

If a service encounters unexpected runtime constraints or requires quota expansion:

1. Gather the relevant error details or context.
2. Call `submit_admin_query`:
   ```json
   {
     "subject": "Deployment quota expansion request",
     "topic": "quota-inquiry",
     "message": "Requesting quota upgrade for additional concurrent services.",
     "metadata": {
       "workspace_slug": "team-production"
     }
   }
   ```
3. The platform control plane routes the inquiry directly to `admin@productecho.com` with authenticated workspace context.
