# ProductEcho Application Packaging & Zip Archive Guide

This guide details how to bundle an application into a clean zip archive suitable for ProductEcho S3 presigned upload.

---

## 1. Archive Structure Rules

1. **Root-Level Manifests**:
   The root of the archive must contain the project entry files:
   - For Node: `package.json`, `package-lock.json` or `pnpm-lock.yaml`, `src/`
   - For Python: `requirements.txt` or `pyproject.toml`, application source code
   - For Docker: `Dockerfile`, `.dockerignore`

2. **No Double-Nesting**:
   When creating the zip archive, do not include an unnecessary outer folder if possible, or ensure the archive root contains only the single application folder (which ProductEcho's source inspector automatically unwraps).

---

## 2. Exclusion Checklist

Always exclude the following patterns from the archive:

| Category | Patterns to Exclude |
| :--- | :--- |
| **Secrets & Keys** | `.env`, `.env.*`, `*.pem`, `*.key`, `credentials.json`, `secrets.yaml` |
| **Dependencies** | `node_modules/`, `vendor/`, `.venv/`, `venv/`, `__pycache__/`, `*.pyc` |
| **Build Outputs** | `.next/`, `dist/`, `build/`, `out/`, `target/`, `.turbo/`, `coverage/` |
| **VCS & IDE** | `.git/`, `.github/`, `.idea/`, `.vscode/`, `.DS_Store` |

---

## 3. Creating the Zip Archive

### Via Terminal Command (macOS / Linux):
```bash
zip -r app-source.zip . \
  -x "*.git*" \
  -x "*node_modules*" \
  -x "*.next*" \
  -x "*.venv*" \
  -x "*venv*" \
  -x "*dist*" \
  -x "*build*" \
  -x "*coverage*" \
  -x "*.env*" \
  -x "*.DS_Store"
```

### Via Python Script:
```python
import zipfile
import os

EXCLUDE_DIRS = {".git", "node_modules", ".next", ".venv", "venv", "dist", "build", "__pycache__"}
EXCLUDE_FILES = {".DS_Store"}

def package_app(source_dir: str, output_zip: str):
    with zipfile.ZipFile(output_zip, "w", zipfile.ZIP_DEFLATED) as zip_file:
        for root, dirs, files in os.walk(source_dir):
            dirs[:] = [d for d in dirs if d not in EXCLUDE_DIRS]
            for file in files:
                if file in EXCLUDE_FILES or file.startswith(".env"):
                    continue
                file_path = os.path.join(root, file)
                arcname = os.path.relpath(file_path, source_dir)
                zip_file.write(file_path, arcname)
```

---

## 4. Uploading to Presigned S3 URL

Once the presigned URL is acquired from `inspect_application_source` or `deploy_application`:
```bash
curl -X PUT \
  -H "Content-Type: application/zip" \
  --data-binary "@app-source.zip" \
  "<PRESIGNED_UPLOAD_URL>"
```
