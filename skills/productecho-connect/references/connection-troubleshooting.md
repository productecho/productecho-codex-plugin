# ProductEcho Authentication & Connection Troubleshooting Guide

This guide details how to obtain your API token from `app.productecho.com`, configure credentials in Codex / ChatGPT, and resolve 401 Unauthorized errors.

---

## 🔐 1. How to Obtain and Configure Your Token

1. **Sign Up or Log In**:
   - Go to **[app.productecho.com/signup](https://app.productecho.com/signup)** (or **[app.productecho.com/login](https://app.productecho.com/login)**).
   - Sign in with your work email or Google account.

2. **Copy Your API Token**:
   - In the ProductEcho Console, navigate to **Settings → API Keys**.
   - Create or copy an active MCP API token (`pe_live_xxxxxxxxxxxxxxxxxxxxxxxxxxxx`).

3. **Paste & Configure in Your Environment**:
   - **Environment Variable**:
     ```bash
     export PRODUCT_ECHO_API_KEY="pe_live_your_token_here"
     ```
   - **Codex / ChatGPT `.mcp.json`**:
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

## 🛑 2. Resolving `401 Unauthorized` Errors

When a tool call or connection fails with `401 Unauthorized`:
1. **Verify Token Existence**: Ensure `PRODUCT_ECHO_API_KEY` is not empty or malformed.
2. **Check Token Status**:
   - Log in at **[app.productecho.com/login](https://app.productecho.com/login)**.
   - Go to **Settings → API Keys** to verify if the key is active or has expired.
3. **Generate a Fresh Key**:
   - If revoked, click **Create API Key** to issue a new token.
   - Update your environment variable or `.mcp.json` with the new token.
4. **Re-test Connection**:
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
      "https://api.productecho.com/mcp",
      "--header",
      "PRODUCT-ECHO-API-KEY: ${PRODUCT_ECHO_API_KEY}"
    ],
    "env": {
      "PRODUCT_ECHO_API_KEY": "${PRODUCT_ECHO_API_KEY}"
    }
  }
}
```
