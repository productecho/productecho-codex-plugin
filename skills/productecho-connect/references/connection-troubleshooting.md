# ProductEcho Authentication & Connection Troubleshooting Guide

This guide details how to authenticate with the ProductEcho Cloud MCP Server via automated OAuth 2.0 / 2.1 PKCE or static workspace API keys, configure connections in Codex, ChatGPT, and Cursor, and resolve 401 Unauthorized errors.

---

## 🔐 1. Authentication Methods

### Method A: Automated OAuth 2.0 / 2.1 PKCE (Standard)
1. **One-Click Authorization**:
   - In Codex or your MCP client, select or install the ProductEcho plugin.
   - The client connects to `https://api.productecho.com/mcp`.
   - A browser window opens to `https://api.productecho.com/oauth/authorize`.
   - Click **"Authorize Access"**.
2. **Access Token Saved**:
   - The client receives an OAuth access token (`pe_at_...`) and automatically caches it.

### Method B: Static Workspace API Key (Headless / Pipelines)
1. **Sign Up or Log In**:
   - Go to **[app.productecho.com/signup](https://app.productecho.com/signup)** (or **[app.productecho.com/login](https://app.productecho.com/login)**).
2. **Copy Your API Token**:
   - In the console, go to **Settings → API Keys**.
   - Copy an active MCP token (`pe_live_xxxxxxxxxxxxxxxxxxxxxxxxxxxx`).
3. **Configure Environment Variable**:
   ```bash
   export PRODUCT_ECHO_API_KEY="pe_live_your_token_here"
   ```

---

## 🛑 2. Resolving `401 Unauthorized` Errors

When a tool call or connection fails with `401 Unauthorized`:
1. **If using OAuth 2.0 Plugin**:
   - Re-open `https://api.productecho.com/oauth/authorize`and re-authorize the session.
   - If using `mcp-remote`, restart `npx -y mcp-remote https://api.productecho.com/mcp` to refresh the cached token.
2. **If using Static API Keys**:
   - Ensure `PRODUCT_ECHO_API_KEY` is not empty or malformed.
   - Check **Settings → API Keys** to verify if the key was revoked or rotated.
   - Update `export PRODUCT_ECHO_API_KEY="pe_live_..."`.
3. **Re-test Connection**:
   - Run `get_workspace_info` to verify active connection.

---

## 🔧 3. Configuration Reference (`.mcp.json`)

```json
{
  "productecho": {
    "command": "npx",
    "args": [
      "-y",
      "mcp-remote",
      "https://api.productecho.com/mcp"
    ]
  }
}
```
