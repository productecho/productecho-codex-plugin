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
   - Workspace metadata and resource quota discovery.
   - Support query submission and issue escalation.

---

## 📦 Package Layout

```
productecho-plugin/
├── .codex-plugin/
│   └── plugin.json          # Codex Plugin Manifest
├── plugin.json              # Root Manifest (dual-compatibility)
├── .mcp.json                # MCP Server connection configuration
├── mcp_config.json          # Universal MCP Server configuration
├── .app.json                # Registered MCP application mapping
├── assets/
│   ├── icon.png             # Plugin composer icon
│   └── logo.png             # Plugin brand logo
├── rules/
│   └── AGENTS.md            # Multi-language deployment guardrails & rules
├── skills/
│   ├── productecho-deploy/  # Application deployment & packaging skill
│   ├── productecho-postgres/# Managed PostgreSQL database skill
│   └── productecho-connect/ # Workspace connection & governance skill
├── LICENSE                  # Apache-2.0 License
├── .gitignore               # Git ignore configuration
└── README.md
```

---

## 🚀 Authentication & Quick Start

### Step 1: Sign Up / Sign In
1. Visit **[app.productecho.com/signup](https://app.productecho.com/signup)** (or **[app.productecho.com/login](https://app.productecho.com/login)**).
2. Complete signup or sign in to your team workspace.

### Step 2: Copy Your API Token
1. In the console, go to **Settings → API Keys**.
2. Generate or copy your active MCP API token (`pe_live_...`).

### Step 3: Configure Token in Codex / ChatGPT

#### Option A: Set Environment Variable
```bash
export PRODUCT_ECHO_API_KEY="pe_live_your_token_here"
```

#### Option B: Configure in `.mcp.json`
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

---

## 💬 Sample Prompts

- *"Show my ProductEcho workspace overview and active services"*
- *"Provision a new managed PostgreSQL database and retrieve the connection URL"*
- *"Verify deployment readiness for this project and deploy to ProductEcho"*
- *"Expand my database storage capacity to 20GB"*
- *"Submit a priority support inquiry to admin@productecho.com"*
