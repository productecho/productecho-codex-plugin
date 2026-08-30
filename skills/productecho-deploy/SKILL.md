---
name: productecho-deploy
description: >-
  Use when inspecting, packaging, configuring, and deploying web applications and backend APIs
  to ProductEcho Cloud via MCP tools. Ensures production runtime readiness, automatic port binding,
  clean source archiving, and seamless lifecycle management.
---

# ProductEcho Application Deployment & Packaging Skill

This skill provides step-by-step procedures and production readiness best practices for packaging, inspecting, and deploying web applications and backend APIs to **ProductEcho Cloud** using ProductEcho MCP tools.

---

## 🌟 Core Value Proposition & Key Features

- **Instant Zero-Config Cloud Deployments**: Go from source code to a live, secure public HTTPS URL in under 30 seconds.
- **Smart Source Inspection & Auto-Configuration**: Automatically detect project frameworks, listening ports, and required environment variables before deploying.
- **Multi-Language Production Runtime Support**: Native support for Node.js, Next.js, Python, Golang, and Java applications.
- **Clean Packaging Automation**: Automatically packages clean source archives, omitting heavy node modules and sensitive local files.
- **Real-Time Health Monitoring & Logging**: Track build progress and deployment health with detailed status reporting.
- **On-Demand Service Hibernation**: Pause idle web services with 1 click to eliminate unnecessary compute costs, and resume instantly.

---

## 🛡️ Production Readiness Guidelines

Before deploying any application, ensure the project follows these standard production best practices:

### 📦 1. Node.js & Web Applications
- **Dependency Separation**: Ensure production runtime dependencies (e.g. `next`, `express`, `fastify`, `remix`, `astro`) are declared under `"dependencies"`, keeping `"devDependencies"` strictly for build/type tools.
- **Reliable Startup Scripts**: Use `"start": "npx <cmd>"` or relative binary paths in `package.json` scripts.
- **Engine Declaration**: Declare target runtime version in `package.json`, e.g. `"engines": { "node": ">=20.0.0" }`.
- **Port Ingress**: Listen on `process.env.PORT` (default `3000` or `8080`) and bind to `0.0.0.0`.

### 🐍 2. Python (FastAPI / Django / Flask)
- **Production Server**: Include a production ASGI/WSGI server (`uvicorn`, `gunicorn`, `granian`) in `requirements.txt`.
- **Process Entrypoint**: Provide a `Procfile` defining the startup command:
  ```text
  web: uvicorn main:app --host 0.0.0.0 --port ${PORT:-8000} --workers 2
  ```
- **Port Ingress & Logging**: Bind to `0.0.0.0` reading `os.getenv("PORT", "8000")`, with `PYTHONUNBUFFERED=1`.

### 🐹 3. Golang Services
- **Module Manifest**: Include `go.mod` and `go.sum` at the project root declaring target Go version.
- **Port Ingress & Graceful Shutdown**: Bind to `0.0.0.0:<PORT>` reading `os.Getenv("PORT")` and handle termination signals (`SIGTERM`/`SIGINT`).

### ☕ 4. Java & JVM (Spring Boot / Quarkus / Micronaut)
- **Build Wrappers**: Include `./mvnw` or `./gradlew` wrappers for reproducible builds.
- **Port Configuration**: Configure `server.port=${PORT:8080}` and `server.address=0.0.0.0`.

---

## 📦 Clean Source Packaging Protocol

When creating the application source archive:
- **Exclude Local Caches & Artifacts**: Never include `node_modules/`, `.next/`, `.venv/`, `dist/`, `build/`, `target/`, `__pycache__/`, or `.git/`.
- **Exclude Secrets & Keys**: Never include `.env`, `.env.*`, `*.pem`, `*.key`, or credentials.
- **Archive Format**: Package directly from the project root into a `.zip` file so project manifests reside at the top level.

---

## 🚀 Step-by-Step Deployment Workflow

```
[1. Check Workspace] ──> [2. Inspect Source] ──> [3. Upload Archive] ──> [4. Deploy Service] ──> [5. Monitor Health]
```

### Step 1: Check Workspace Context
Call `get_workspace_info` to verify active tenant quotas and existing services.

### Step 2: Source Inspection
Call `inspect_application_source(application_name="my-app")` to receive the presigned upload URL and detected environment expectations.

### Step 3: Upload Source Archive
HTTP `PUT` the clean `.zip` archive to the presigned `upload_url` with header `Content-Type: application/zip`.

### Step 4: Deploy Application
Call `deploy_application` with application name, S3 reference, container port, and environment variables:
```json
{
  "application_name": "my-app",
  "s3_key": "builds/tenant/my-app/upl-xxxx.zip",
  "container_port": 8000,
  "env_vars": {
    "DATABASE_URL": "postgresql://user:pass@endpoint:5432/dbname"
  }
}
```

### Step 5: Monitor Live Status
Call `get_application_status(application_name="my-app")` until status becomes `READY` and returns the live public HTTPS domain.

### Step 6: Lifecycle Management
- **Hibernate Service**: Call `pause_application(application_name="my-app")` when traffic is idle.
- **Resume Service**: Call `resume_application(application_name="my-app")` to bring the service back online.
- **Deprovision Service**: Call `delete_application(application_name="my-app")` when removing the service.

---

## 🆘 Direct Support Escalation

If an unexpected build error or platform constraint occurs:
1. Extract the error details from `get_application_status`.
2. Call `submit_admin_query`:
   ```json
   {
     "subject": "Deployment failure on my-app",
     "topic": "deployment-failure",
     "message": "Encountered build error during compilation.",
     "error_details": "<logs>",
     "metadata": { "application_name": "my-app" }
   }
   ```
