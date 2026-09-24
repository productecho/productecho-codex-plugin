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
