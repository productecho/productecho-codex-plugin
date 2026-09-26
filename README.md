# ProductEcho Plugin (`productecho-plugin`)

The **ProductEcho Plugin** (`productecho-plugin`) connects **Codex** and **ChatGPT** to ProductEcho, enabling instant provisioning of managed PostgreSQL databases and seamless deployment of production web applications and APIs.

---

## 🌟 Value Proposition & Key Capabilities

- **Instant Production Deployments**: Turn local codebases into live, secure public HTTPS applications in seconds.
- **Managed Relational Databases**: Provision dedicated PostgreSQL databases with automated user setup, secure credentials, and dynamic zero-downtime storage scaling.
- **Automated Source Inspection**: Automatically detect runtime environments, frameworks, ports, and environment variables prior to deployment.
- **Smart Cost Optimization**: Pause idle databases and web services with one-click hibernation to reduce cloud spend, and resume instantly without data loss.
- **Unified Workspace Governance**: Complete visibility into active cloud services, quotas, and health metrics.
- **Direct Support Escalation**: Priority support ticketing and technical inquiries dispatched directly to platform administrators (`admin@productecho.com`).

---

## 📦 Bundled Skills

1. **`productecho-deploy`**:
   - Automated source inspection and framework configuration.
   - Production readiness verification (dependency separation, port ingress, process declarations).
   - Clean source archiving and secure upload.
   - Live health monitoring, startup logs, and service lifecycle management.

2. **`productecho-postgres`**:
   - Instant managed PostgreSQL database provisioning.
   - Credential retrieval and connection string formatting (`DATABASE_URL`, CLI command).
   - Dynamic zero-downtime storage volume expansion.
   - Hibernation and resume for cost optimization.

3. **`productecho-connect`**:
   - Protocol connection and API token authentication.
   - Support query submission and issue escalation.

4. **`productecho-agents`**:
   - Autonomous AI agent workload packaging and rollout.
   - Built-in MCP sidecars (`mcp-postgres`, `mcp-redis`, `mcp-py-exec`, `mcp-web-search`).
   - Spend budgets, interactive sandbox invocation, and hibernation.

---

## 📦 Package Layout

```
productecho-plugin/
├── .claude-plugin/
│   ├── marketplace.json     # Claude Code Marketplace Catalog
│   └── plugin.json          # Claude Code Plugin Manifest
├── .codex-plugin/
│   └── plugin.json          # Codex Plugin Manifest
├── plugin.json              # Universal Root Manifest
├── .mcp.json                # Native MCP HTTP config (used by all three plugin.json manifests)
├── mcp_config.json          # Legacy stdio-bridge config (mcp-remote) for clients without native HTTP MCP support
├── .app.json                # Registered MCP application mapping
├── assets/
│   ├── icon.png             # Plugin composer icon
│   └── logo.png             # Plugin brand logo
├── rules/
│   └── AGENTS.md            # Multi-language deployment guardrails & rules
├── skills/
│   ├── productecho-deploy/  # Application deployment & packaging skill
│   ├── productecho-postgres/# Managed PostgreSQL database skill
│   ├── productecho-connect/ # Workspace connection & governance skill
│   └── productecho-agents/  # Autonomous agent & MCP sidecar skill
├── LICENSE                  # Apache-2.0 License
├── .gitignore               # Git ignore configuration
└── README.md
```

---

## 🚀 Quick Installation

### Claude Code
```bash
claude plugin marketplace add productecho/skills
claude plugin install productecho-plugin@productecho
```
Then run `/reload-plugins` inside Claude to activate.

### Universal Skills CLI (Cursor, Windsurf, OpenCode, Codex)
```bash
npx -y skills add productecho/skills --skill '*' --yes --global
```

### Codex MCP Registration
```bash
codex mcp add productecho --url https://api.productecho.com/mcp
codex mcp login productecho
```

---

## 🔐 Authentication & OAuth 2.1 Flow

### Standard OAuth 2.0 Flow (Codex / ChatGPT / Claude / mcp-remote)
The ProductEcho plugin supports standard OAuth 2.1 PKCE authorization.

When installing the plugin or connecting via `mcp-remote`, authentication is negotiated automatically:
1. `mcp-remote` connects to the MCP endpoint (`https://api.productecho.com/mcp`).
2. The server challenges with `HTTP 401` and provides discovery metadata (`/.well-known/oauth-protected-resource`).
3. Your browser automatically opens the consent screen (`/oauth/authorize`), where you click **Authorize**.
4. An OAuth access token (`pe_at_...`) is issued and cached locally—no manual key copy-pasting required!

The plugin requests `mcp:fullwrite` by default so one consent covers the complete full-stack workflow: workspace discovery, application deployment and management, PostgreSQL provisioning and management, and database credential access. `mcp:fullread` is available for read-only clients. Sending support requests uses the separate `mcp:support:write` scope.

#### `.mcp.json` Configuration (native HTTP — used by Claude Code, Codex, and other MCP-native clients)
```json
{
  "mcpServers": {
    "productecho": {
      "type": "http",
      "url": "https://api.productecho.com/mcp"
    }
  }
}
```

#### `mcp_config.json` Configuration (stdio bridge — for clients without native HTTP MCP support)
```json
{
  "mcpServers": {
    "productecho": {
      "command": "npx",
      "args": [
        "-y",
        "mcp-remote",
        "https://api.productecho.com/mcp"
      ]
    }
  }
}
```

### Static API Key Fallback (CLI / Scripts)
For automated pipelines or custom scripts, pass a static tenant API key via headers:
```bash
export PRODUCT_ECHO_API_KEY="pe_live_your_token_here"
```
Header format:
`PRODUCT-ECHO-API-KEY: pe_live_...` or `Authorization: Bearer pe_live_...`


---

## 💬 Sample Prompts

- *"Show my ProductEcho workspace overview and active services"*
- *"Provision a new managed PostgreSQL database and retrieve the connection URL"*
- *"Verify deployment readiness for this project and deploy to ProductEcho"*
- *"Expand my database storage capacity to 20GB"*
- *"Submit a priority support inquiry to admin@productecho.com"*
