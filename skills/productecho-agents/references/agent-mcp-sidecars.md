# ProductEcho Agent MCP Sidecars & Custom Integrations

This guide details the standard pre-configured Model Context Protocol (MCP) sidecars available on ProductEcho Cloud and how to attach custom remote sidecars to autonomous agent workloads.

---

## 🧩 Built-in Standard MCP Sidecars

ProductEcho Cloud provides 5 first-class managed sidecars that can be enabled directly in `AgentDeployRequest.mcp_tools`:

| Sidecar Name | Category | Description | Configuration / Auth |
| :--- | :--- | :--- | :--- |
| `mcp-postgres` | `database` | Read/write queries to tenant managed PostgreSQL databases | Requires `env_vars: {"DATABASE_URL": "postgresql://..."}` |
| `mcp-redis` | `memory` | Low-latency state, memory scratchpad, and session caching | Requires `env_vars: {"REDIS_URL": "redis://..."}` |
| `mcp-py-exec` | `sandbox` | Ephemeral microVM Python execution sandbox for math, data analysis, and scripts | Auto-configured by ProductEcho Cloud |
| `mcp-web-search` | `search` | Real-time web search and content retrieval for model grounding | Managed platform search API |
| `mcp-figma` | `design` | Inspect frames, design tokens, and UI components from Figma | Requires `auth_config: {"FIGMA_ACCESS_TOKEN": "..."}` |

---

## 🛠️ Enabling a Pre-configured Sidecar

To enable one of the standard sidecars, pass it in the `mcp_tools` array during deployment:

```json
{
  "name": "mcp-postgres",
  "display_name": "PostgreSQL DB",
  "category": "database",
  "enabled": true,
  "status": "active",
  "env_vars": {
    "DATABASE_URL": "postgresql://pguser:secret@postgres-x7k9p2.service.internal:5432/app_production"
  }
}
```

---

## 🌐 Attaching Custom Remote MCP Sidecars

You can connect external MCP servers running via SSE (Server-Sent Events) or HTTP:

```json
{
  "name": "custom-crm-mcp",
  "display_name": "Salesforce CRM Tools",
  "category": "custom",
  "enabled": true,
  "status": "active",
  "server_url": "https://mcp-crm.internal.example.com/sse",
  "auth_config": {
    "BEARER_TOKEN": "secret-crm-token"
  },
  "env_vars": {
    "CRM_INSTANCE_URL": "https://company.my.salesforce.com"
  }
}
```

---

## 🔒 Security Best Practices

1. **Keep Secrets in `env_vars` or `auth_config`**: Never hardcode API keys or database passwords into your agent source code.
2. **Internal DNS for Databases**: Always use `.service.internal` DNS hostnames (e.g. `postgres-x7k9p2.service.internal:5432`) to ensure database traffic remains inside the private Kubernetes cluster network.
3. **Daily Spend Limits**: Set `daily_budget_usd` on all agent deployments to prevent unbounded token expenditure during autonomous loops.
