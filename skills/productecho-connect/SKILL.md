---
name: productecho-connect
description: >-
  Use when connecting Codex or ChatGPT to the ProductEcho Cloud MCP server, guiding authentication via app.productecho.com,
  configuring and validating API keys, discovering workspace context and quotas, managing credentials,
  handling 401 re-authentication, and escalating technical issues directly to ProductEcho platform administrators.
---

# ProductEcho MCP Connection & Workspace Governance Skill

This skill guides Codex and AI agents on connecting to the ProductEcho Cloud MCP Server, obtaining and configuring API key credentials from `app.productecho.com`, discovering workspace context, recovering from 401 Unauthorized states, and escalating support queries.

---

## 🌟 Core Value Proposition & Key Features

- **Simple & Secure Authentication**: Authenticate via dedicated tenant API keys generated from the ProductEcho Console (`app.productecho.com`).
- **Scoped & Revocable Credentials**: Every key (`pe_live_...`) is monitored and can be rotated or revoked anytime from Settings.
- **Resilient 401 Recovery**: Clean recovery protocol when a credential is expired, revoked, or unconfigured.
- **Unified Workspace Governance**: Query workspace metadata, active cloud resources, and tier quotas with single-request precision.
- **Direct Support Escalation**: Submit priority tickets and technical inquiries directly to platform administrators (`admin@productecho.com`).

---

## 🔐 Authentication & Setup Guide

To connect Codex or ChatGPT to ProductEcho Cloud, follow these steps:

```
[1. Sign Up / Sign In] ──> [2. Copy API Key] ──> [3. Paste Token in Codex Config] ──> [4. Connect]
  app.productecho.com       Settings → API Keys      PRODUCT_ECHO_API_KEY
```

### Step 1: Sign Up or Log In
1. Navigate to **[app.productecho.com/signup](https://app.productecho.com/signup)** (or **[app.productecho.com/login](https://app.productecho.com/login)** if you already have an account).
2. Complete the passwordless email OTP verification or sign in with Google.

### Step 2: Retrieve Your API Key
1. In the ProductEcho Console, go to **Settings → API Keys** (or **Team & Access**).
2. Click **Create API Key** (or use your primary workspace key).
3. Copy the generated API token (e.g., `pe_live_xxxxxxxxxxxxxxxxxxxxxxxxxxxx`).

### Step 3: Paste and Configure Your Token

#### Option A: Terminal Environment Variable (Fastest)
Set the token in your current environment or shell profile (`~/.zshrc` or `~/.bashrc`):
```bash
export PRODUCT_ECHO_API_KEY="pe_live_your_token_here"
```

#### Option B: Codex / ChatGPT `.mcp.json` Configuration
Add the ProductEcho MCP remote server definition to your `.mcp.json`:
```json
{
  "productecho": {
    "command": "npx",
    "args": [
      "-y",
      "mcp-remote",
      "https://api.productecho.com/mcp",
      "--header",
      "PRODUCT-ECHO-API-KEY: pe_live_your_token_here"
    ],
    "env": {
      "PRODUCT_ECHO_API_KEY": "pe_live_your_token_here"
    }
  }
}
```

#### Option C: In-Chat Prompt
When prompted by Codex or ChatGPT for your ProductEcho credential, paste your copied `pe_live_...` token directly into the input.

---

## 🔄 401 Unauthorized & Token Refresh Handling

When an MCP tool call or connection returns `HTTP 401 Unauthorized`:
1. **Explain the Issue**: Inform the user that the current API token is missing, expired, or was revoked in the console.
2. **Provide the Resolution Steps**:
   - Sign in at **[app.productecho.com/login](https://app.productecho.com/login)**.
   - Navigate to **Settings → API Keys** and generate/copy a fresh API token.
   - Update `PRODUCT_ECHO_API_KEY` or replace the token in `.mcp.json`.
3. **Re-test Connection**: Call `get_workspace_info` to verify the new token and restore normal operations.

---

## 🛠️ Connection & Governance Tools

| Tool Name | Value Provided | Key Parameters |
| :--- | :--- | :--- |
| `get_workspace_info` | Query authenticated workspace name, slug, ID, owner email, tier, and resource quotas | None |
| `list_applications` | List deployed web applications and APIs for the tenant | `deployment_status` (optional filter) |
| `list_postgres` | List all active and paused database instances for the tenant | None |
| `submit_admin_query` | Open a priority support ticket or escalation directly to `admin@productecho.com` | `message` (required), `subject`, `topic`, `error_details`, `metadata` |

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
