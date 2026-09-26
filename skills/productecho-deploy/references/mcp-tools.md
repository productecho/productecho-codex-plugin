# ProductEcho MCP Tool Quick Reference

This document provides a concise reference for all ProductEcho Model Context Protocol (MCP) tools.

---

## 1. Application Management Tools

| Tool | Purpose & Value | Primary Arguments |
| :--- | :--- | :--- |
| `inspect_application_source` | Inspect source tree and return `recommended_deployment_target` (`container` or `static_cdn`) with build facts. | `application_name`, `s3_key`, `upload_id`, `git_url`, `git_branch`, `root_directory`, `env_vars` |
| `deploy_application` | Build and deploy using `auto`, `container`, or an inspection-approved `static_cdn` target. Returns a presigned S3 upload URL if source is omitted. | `application_name`, `deployment_target`, `s3_key`, `upload_id`, `git_url`, `container_port`, `env_vars` |
| `list_applications` | List active application deployments for authenticated tenant. | `deployment_status` (optional filter) |
| `get_application_status` | Query live status, deployment logs, and public HTTPS domain endpoint. | `application_name` |
| `pause_application` | Scale a container to zero or remove a static app's CloudFront KVS route. | `application_name` |
| `resume_application` | Resume a container or restore and health-check a static app's active KVS route. | `application_name` |
| `delete_application` | Remove the public route first, then deprovision target-specific resources and artifacts. | `application_name` |
| `link_project` | Bind a local codebase/monorepo to a ProductEcho application and optional database identity. | `application_name`, `root_directory`, `db_identifier`, `remote_repo` |
| `get_project_link` | Retrieve cloud deployment state and project identity for an application or repository (use during Step 0 state discovery). | `application_name`, `remote_repo`, `root_directory` |
| `get_project_state` | Deprecated alias for `get_project_link` — retained for backward compatibility. | `application_name`, `remote_repo`, `root_directory` |
| `get_application_env` | Retrieve configured environment variables for a deployed application. | `application_name` |
| `update_application_env` | Update environment variables and optionally trigger a rolling restart without rebuilding. | `application_name`, `env_vars`, `redeploy` |

---

## 2. PostgreSQL Database Management Tools

| Tool | Purpose & Value | Primary Arguments |
| :--- | :--- | :--- |
| `launch_postgres` | Provision dedicated managed PostgreSQL instance with persistent storage. | `db_identifier`, `db_name`, `db_user`, `storage_gb` |
| `list_postgres` | List all provisioned PostgreSQL databases for tenant. | None |
| `get_postgres_status` | Check database status, operational health, endpoint, and port. | `db_identifier` |
| `get_postgres_credentials` | Retrieve secure database credentials, connection URL (`DATABASE_URL`), and CLI command. | `db_identifier` |
| `pause_postgres` | Hibernate database compute to reduce costs while keeping all storage safely preserved. | `db_identifier` |
| `resume_postgres` | Resume a hibernated database with all data intact. | `db_identifier` |
| `resize_postgres` | Dynamically expand storage volume capacity with zero downtime. | `db_identifier`, `storage_gb` |
| `delete_postgres` | Permanently deprovision database and release cloud storage. | `db_identifier` |

---

## 3. Workspace & Priority Support Tools

| Tool | Purpose & Value | Primary Arguments |
| :--- | :--- | :--- |
| `get_workspace_info` | Query workspace name, slug, tenant ID, quotas, and owner details. | None |
| `submit_admin_query` | Submit a priority ticket, technical inquiry, or quota request directly to `admin@productecho.com`. | `message`, `subject`, `topic`, `error_details`, `metadata` |

---

## 4. Custom Domains for Static CDN Applications

| Tool | Purpose & Value | Primary Arguments |
| :--- | :--- | :--- |
| `check_domain_availability` | Verify a subdomain prefix or verified custom domain is available before deploying or binding. | `domain_prefix`, `custom_domain`, `application_name`, `deployment_target` |
| `list_static_custom_domains` | List custom domain bindings for a static CDN application. | `application_name` |
| `add_static_custom_domain` | Bind a verified tenant custom domain to a static CDN application. | `application_name`, `tenant_domain_id` |
| `check_static_custom_domain_status` | Check DNS verification and TLS certificate issuance status for a binding. | `application_name`, `binding_id` |
| `remove_static_custom_domain` | Detach a custom domain binding and release its CDN route. | `application_name`, `binding_id` |
