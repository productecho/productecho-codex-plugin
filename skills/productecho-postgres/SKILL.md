---
name: productecho-postgres
description: >-
  Use when provisioning, configuring, inspecting, scaling, or managing high-performance managed PostgreSQL databases
  on ProductEcho Cloud via MCP tools. Handles database creation, credentials retrieval, zero-downtime storage volume
  resizing, pause/resume hibernation, and application wiring.
---

# ProductEcho Managed PostgreSQL Database Management Skill

This skill provides step-by-step procedures, tool calling workflows, and best practices for provisioning, scaling, managing, and connecting **production-grade managed PostgreSQL databases** on ProductEcho Cloud using ProductEcho MCP tools.

> **Prerequisite**: tool calls in this skill refer to the ProductEcho MCP server configured by this plugin (`.mcp.json` / `mcp_config.json`). Connect first via the `productecho-connect` skill or your client's MCP-add flow (e.g. `codex mcp add productecho --url https://api.productecho.com/mcp && codex mcp login productecho`) if these tools aren't yet available.

---

## 🌟 Core Value Proposition & Key Features

- **Instant Database Provisioning**: Provision dedicated, production-ready PostgreSQL databases in seconds with automated user creation and credential generation.
- **Zero-Downtime Storage Scaling**: Dynamically expand database storage capacity on demand with zero connection interruption or query downtime.
- **Smart Cost Hibernation**: Pause idle databases to reduce compute costs to zero while safely retaining all persistent data, and resume instantly.
- **Seamless Application Wiring**: Retrieve formatted `DATABASE_URL` connection strings and CLI connection commands ready for instant injection into backend services.
- **Dedicated Isolation & Persistence**: Full data persistence across restarts, isolated tenant environments, and secure credential storage.

---

## 🗄️ Available Database Management MCP Tools

| Tool Name | Feature & Value Provided | Key Parameters |
| :--- | :--- | :--- |
| `launch_postgres` | Provision a new dedicated managed PostgreSQL database instance | `db_identifier` (optional 6-char str), `db_name`, `db_user`, `storage_gb` (min 1) |
| `get_postgres_credentials` | Retrieve secure database credentials, connection URL, and psql CLI command | `db_identifier` (required, 6-char str) |
| `get_postgres_status` | Query instance status, operational health, connection host, and port | `db_identifier` (required, 6-char str) |
| `list_postgres` | List all active and paused database instances for the tenant | None |
| `resize_postgres` | Dynamically expand allocated storage capacity with zero downtime | `db_identifier` (required), `storage_gb` (target size in GB) |
| `pause_postgres` | Hibernate database compute to reduce costs while preserving all storage | `db_identifier` (required) |
| `resume_postgres` | Resume a hibernated database instance with all data immediately available | `db_identifier` (required) |
| `delete_postgres` | Deprovision database instance and release associated cloud storage | `db_identifier` (required) |

---

## 🚀 Standard Database Management Workflows

### 1. Provisioning a New Managed Database
1. Call `launch_postgres`:
   ```json
   {
     "db_identifier": "x7k9p2",
     "db_name": "app_production",
     "db_user": "pguser",
     "storage_gb": 10
   }
   ```
2. Call `get_postgres_status(db_identifier="x7k9p2")` to confirm status is `Running`.
3. Call `get_postgres_credentials(db_identifier="x7k9p2")` to retrieve the generated password and `connection_url`.

### 2. Wiring Database to Application Deployments
See the `productecho-deploy` skill for the full `deploy_application` workflow.
1. Retrieve connection details:
   ```json
   {
     "connection_url": "postgresql://pguser:secret@postgres-x7k9p2.service.internal:5432/app_production",
     "psql_command": "PGPASSWORD='secret' psql -h postgres-x7k9p2.service.internal -U pguser -d app_production"
   }
   ```
2. Pass `DATABASE_URL` directly into `deploy_application`:
   ```json
   {
     "application_name": "my-backend-api",
     "s3_key": "builds/tenant/my-backend-api/upl-123.zip",
     "container_port": 8000,
     "env_vars": {
       "DATABASE_URL": "postgresql://pguser:secret@postgres-x7k9p2.service.internal:5432/app_production"
     }
   }
   ```

### 3. Dynamic Zero-Downtime Storage Scaling
When disk usage grows, dynamically expand storage without restarting the database:
```json
{
  "db_identifier": "x7k9p2",
  "storage_gb": 25
}
```

### 4. Smart Cost Hibernation
- **Hibernate (Save Costs)**: Call `pause_postgres(db_identifier="x7k9p2")` when the database is idle (e.g. staging or dev environments). Compute costs drop to zero while storage is safely preserved.
- **Resume (Instant Access)**: Call `resume_postgres(db_identifier="x7k9p2")` to bring the database back online with all data intact.

### 5. Safe Deprovisioning
When a database is retired:
1. Call `delete_postgres(db_identifier="x7k9p2")` to cleanly release all allocated cloud resources.
