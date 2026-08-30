# Golang Deployment Guidelines & Packaging Reference

This guide details packaging rules, build requirements, and runtime specifications for deploying Go applications to **ProductEcho**.

---

## 1. Project Structure & Manifests

### Required Files:
- **`go.mod`**: Must be located at the root of the project.
- **`go.sum`**: Checked in alongside `go.mod` to ensure deterministic dependency resolution.
- **Go Version**: Ensure `go.mod` specifies a modern Go version (e.g. `go 1.22` or `go 1.23`).

### Entrypoint & Package Structure:
- The Go build engine automatically locates the `main` package at the root or within subdirectories (`cmd/<app>/main.go`).

---

## 2. Port Ingress & Host Binding

- **Dynamic `PORT` Injected by Control Plane**:
  The application **must** read the `PORT` environment variable injected by the control plane (defaulting to `8080` or `8000`).
- **Bind to `0.0.0.0`**:
  Do **not** bind only to internal loopback (`127.0.0.1`). Always bind to `0.0.0.0:<PORT>` or `:<PORT>`.

### Code Example (Standard `net/http`):
```go
package main

import (
    "fmt"
    "log"
    "net/http"
    "os"
)

func main() {
    port := os.Getenv("PORT")
    if port == "" {
        port = "8080"
    }

    mux := http.NewServeMux()
    mux.HandleFunc("/healthz", func(w http.ResponseWriter, r *http.Request) {
        w.WriteHeader(http.StatusOK)
        w.Write([]byte("OK"))
    })
    mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        fmt.Fprintf(w, "Hello from ProductEcho Golang service!")
    })

    addr := ":" + port
    log.Printf("Server listening on %s", addr)
    if err := http.ListenAndServe(addr, mux); err != nil {
        log.Fatalf("Server failed: %v", err)
    }
}
```

---

## 3. Graceful Shutdown & Signal Handling

To ensure zero-downtime rolling updates and prevent dropping in-flight requests during lifecycle events:

```go
quit := make(chan os.Signal, 1)
signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
<-quit

ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
defer cancel()
if err := server.Shutdown(ctx); err != nil {
    log.Fatalf("Server forced to shutdown: %v", err)
}
```

---

## 4. Zip Packaging & Exclusions

When bundling your Go source into a `.zip` archive for upload:

### Exclude:
- Compiled binaries: `bin/`, `*.exe`, `main`
- VCS & IDE: `.git/`, `.idea/`, `.vscode/`, `.DS_Store`
- Environment & Secret files: `.env`, `.env.*`, `*.pem`, `*.key`
- Temporary files: `tmp/`, `coverage.out`, `*.test`
