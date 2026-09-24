#!/usr/bin/env bash
# ProductEcho Multi-Language Packaging Guardrails Verifier Script
# Validates Node.js, Python, Golang, and Java projects against ProductEcho deployment guardrails.

set -euo pipefail

TARGET_DIR="${1:-.}"
PACKAGE_JSON="${TARGET_DIR}/package.json"
REQUIREMENTS_TXT="${TARGET_DIR}/requirements.txt"
PYPROJECT_TOML="${TARGET_DIR}/pyproject.toml"
GO_MOD="${TARGET_DIR}/go.mod"
POM_XML="${TARGET_DIR}/pom.xml"
BUILD_GRADLE="${TARGET_DIR}/build.gradle"
BUILD_GRADLE_KTS="${TARGET_DIR}/build.gradle.kts"
DOCKERFILE="${TARGET_DIR}/Dockerfile"
PROCFILE="${TARGET_DIR}/Procfile"

echo "=== Verifying ProductEcho Deployment Guardrails in: ${TARGET_DIR} ==="

ERRORS=0
WARNINGS=0

# Check 1: Build Strategy
if [[ -f "${DOCKERFILE}" ]]; then
  echo "✅ Dockerfile detected. Custom Dockerfile build strategy will be used."
else
  echo "ℹ️ No Dockerfile found. Source inspection will choose container or static_cdn."
fi

# Check 2: Node.js / JavaScript / TypeScript projects
if [[ -f "${PACKAGE_JSON}" ]]; then
  echo "📦 Detected Node.js / Web project."
  HAS_BUILD=$(node -e "
    try {
      const pkg = require('./${PACKAGE_JSON}');
      if (pkg.scripts && pkg.scripts.build) console.log('OK');
    } catch(e){}
  " 2>/dev/null || true)
  HAS_SERVER_RUNTIME=$(node -e "
    try {
      const pkg = require('./${PACKAGE_JSON}');
      const deps = Object.assign({}, pkg.dependencies || {}, pkg.devDependencies || {});
      const server = ['express', 'fastify', '@nestjs/core', 'koa'].some((name) => deps[name]);
      if (server || (pkg.scripts && pkg.scripts.start && !deps.vite && !deps['react-scripts'])) console.log('YES');
    } catch(e){}
  " 2>/dev/null || true)
  if [[ ! -f "${DOCKERFILE}" && "${HAS_BUILD}" == "OK" && "${HAS_SERVER_RUNTIME}" != "YES" ]]; then
    echo "ℹ️ Static SPA candidate detected. Confirm inspect_application_source recommends 'static_cdn' before selecting it."
  fi
  SERVER_PKGS=("next" "vinxi" "express" "fastify" "@nestjs/core" "koa" "remix" "astro" "@sveltejs/kit")
  for pkg in "${SERVER_PKGS[@]}"; do
    if grep -q "\"${pkg}\"" "${PACKAGE_JSON}"; then
      IN_DEV=$(node -e "
        try {
          const pkg = require('./${PACKAGE_JSON}');
          const inDev = pkg.devDependencies && pkg.devDependencies['${pkg}'];
          const inProd = pkg.dependencies && pkg.dependencies['${pkg}'];
          if (inDev && !inProd) console.log('DEV_ONLY');
        } catch(e){}
      " 2>/dev/null || true)

      if [[ "${IN_DEV}" == "DEV_ONLY" ]]; then
        echo "❌ [Guardrail Violation] Package '${pkg}' is listed under 'devDependencies' but is required for production server runtime. Move it to 'dependencies'."
        ERRORS=$((ERRORS + 1))
      fi
    fi
  done

  HAS_ENGINES=$(node -e "
    try {
      const pkg = require('./${PACKAGE_JSON}');
      if (pkg.engines && pkg.engines.node) console.log('OK');
    } catch(e){}
  " 2>/dev/null || true)

  if [[ "${HAS_ENGINES}" != "OK" ]]; then
    echo "⚠️ [Warning] No 'engines.node' specified in package.json. Recommended: \"engines\": { \"node\": \">=20.0.0\" }."
    WARNINGS=$((WARNINGS + 1))
  else
    echo "✅ 'engines.node' is defined in package.json."
  fi

  if grep -q "\"next\"" "${PACKAGE_JSON}" && [[ ! -f "${DOCKERFILE}" ]]; then
    NEXT_VER=$(node -e "
      try {
        const pkg = require('./${PACKAGE_JSON}');
        const v = (pkg.dependencies && pkg.dependencies.next) || (pkg.devDependencies && pkg.devDependencies.next) || '';
        console.log(v);
      } catch(e){}
    " 2>/dev/null || true)

    BUILD_CMD=$(node -e "
      try {
        const pkg = require('./${PACKAGE_JSON}');
        console.log((pkg.scripts && pkg.scripts.build) || '');
      } catch(e){}
    " 2>/dev/null || true)

    if [[ "${NEXT_VER}" =~ 16|17|latest ]] || [[ "${BUILD_CMD}" =~ --turbopack ]]; then
      if [[ ! "${BUILD_CMD}" =~ --webpack ]]; then
        echo "❌ [Guardrail Violation] Next.js 16+ requires '--webpack' in the 'build' script under buildpacks (e.g. \"build\": \"NODE_ENV=production next build --webpack\") or a custom Dockerfile."
        ERRORS=$((ERRORS + 1))
      fi
    fi

    if [[ ! "${BUILD_CMD}" =~ NODE_ENV=production ]]; then
      echo "⚠️ [Warning] Prepend 'NODE_ENV=production' to your build script (e.g. \"build\": \"NODE_ENV=production next build --webpack\")."
      WARNINGS=$((WARNINGS + 1))
    fi
  fi
fi

# Check 3: Python projects
if [[ -f "${REQUIREMENTS_TXT}" || -f "${PYPROJECT_TOML}" ]]; then
  echo "🐍 Detected Python project."
  if [[ -f "${REQUIREMENTS_TXT}" ]]; then
    if ! grep -Eq "uvicorn|gunicorn|granian|hypercorn|waitress" "${REQUIREMENTS_TXT}"; then
      echo "⚠️ [Warning] No production WSGI/ASGI server (uvicorn, gunicorn, granian) found in requirements.txt."
      WARNINGS=$((WARNINGS + 1))
    else
      echo "✅ Production ASGI/WSGI server found in requirements.txt."
    fi
  fi

  if [[ ! -f "${PROCFILE}" && ! -f "${DOCKERFILE}" ]]; then
    echo "ℹ️ [Tip] Consider adding a Procfile (e.g. 'web: uvicorn main:app --host 0.0.0.0 --port \${PORT:-8000}') for explicit startup process."
  fi
fi

# Check 4: Golang projects
if [[ -f "${GO_MOD}" ]]; then
  echo "🐹 Detected Golang project."
  if ! grep -q "^go " "${GO_MOD}"; then
    echo "⚠️ [Warning] No go version directive found in go.mod."
    WARNINGS=$((WARNINGS + 1))
  else
    echo "✅ go.mod has valid go version directive."
  fi
fi

# Check 5: Java / JVM projects
if [[ -f "${POM_XML}" || -f "${BUILD_GRADLE}" || -f "${BUILD_GRADLE_KTS}" ]]; then
  echo "☕ Detected Java / JVM project."
  if [[ -f "${POM_XML}" && ! -f "${TARGET_DIR}/mvnw" ]]; then
    echo "⚠️ [Warning] Maven Wrapper './mvnw' not found. Recommended to include wrapper for reproducible in-cluster builds."
    WARNINGS=$((WARNINGS + 1))
  fi
  if [[ (-f "${BUILD_GRADLE}" || -f "${BUILD_GRADLE_KTS}") && ! -f "${TARGET_DIR}/gradlew" ]]; then
    echo "⚠️ [Warning] Gradle Wrapper './gradlew' not found. Recommended to include wrapper for reproducible in-cluster builds."
    WARNINGS=$((WARNINGS + 1))
  fi
fi

# Check 6: ProductEcho State Linking & .gitignore
GITIGNORE="${TARGET_DIR}/.gitignore"
if [[ -d "${TARGET_DIR}/.productecho" ]]; then
  echo "🔗 Detected .productecho state directory."
  if [[ -f "${GITIGNORE}" ]]; then
    if grep -q "^\.productecho" "${GITIGNORE}" || grep -q "^/\.productecho" "${GITIGNORE}"; then
      echo "✅ .productecho/ is properly ignored in .gitignore."
    else
      echo "⚠️ [Warning] '.productecho/' should be added to .gitignore to prevent committing local state."
      WARNINGS=$((WARNINGS + 1))
    fi
  else
    echo "⚠️ [Warning] No .gitignore found. Create .gitignore and add '.productecho/'."
    WARNINGS=$((WARNINGS + 1))
  fi
fi

echo "--- Summary ---"
echo "Errors: ${ERRORS}, Warnings: ${WARNINGS}"

if [[ ${ERRORS} -gt 0 ]]; then
  echo "❌ Verification failed. Fix the violations above before deploying."
  exit 1
else
  echo "✅ Verification passed! Ready for packaging and deployment."
  exit 0
fi
