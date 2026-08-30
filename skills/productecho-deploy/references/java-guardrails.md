# Java & JVM Deployment Guidelines & Packaging Reference

This guide details packaging rules, build requirements, and runtime memory optimization for deploying Java (Spring Boot, Quarkus, Micronaut, Dropwizard) applications to **ProductEcho**.

---

## 1. Build Tools & Wrapper Scripts

### Maven or Gradle Support:
To ensure reproducible builds:

- **Maven Projects**: Include `pom.xml`, the Maven Wrapper `./mvnw`, and the `.mvn/wrapper/` directory.
- **Gradle Projects**: Include `build.gradle` (or `build.gradle.kts`), the Gradle Wrapper `./gradlew`, and the `gradle/wrapper/` directory.
- **Make Wrappers Executable**: Ensure wrappers have execution permissions.

---

## 2. JDK Version Declaration

Explicitly declare your Java version in the build manifest (Java 17 and Java 21 LTS are recommended):

### Maven (`pom.xml`):
```xml
<properties>
    <java.version>21</java.version>
    <maven.compiler.source>21</maven.compiler.source>
    <maven.compiler.target>21</maven.compiler.target>
</properties>
```

### Gradle (`build.gradle`):
```groovy
java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(21)
    }
}
```

---

## 3. Server Port & Environment Variable Binding

The control plane dynamically injects the `PORT` environment variable (default `8080`). Your framework must bind its HTTP server to this port:

### Spring Boot (`src/main/resources/application.properties` or `application.yml`):
```properties
# Binds to injected PORT environment variable with fallback to 8080
server.port=${PORT:8080}
server.address=0.0.0.0
```
or in YAML:
```yaml
server:
  port: ${PORT:8080}
  address: 0.0.0.0
```

### Quarkus (`src/main/resources/application.properties`):
```properties
quarkus.http.port=${PORT:8080}
quarkus.http.host=0.0.0.0
```

### Micronaut (`src/main/resources/application.yml`):
```yaml
micronaut:
  server:
    port: ${PORT:8080}
    host: 0.0.0.0
```

---

## 4. Runtime JVM Memory & Container Optimization

- **Automatic Memory Optimization**:
  The runtime automatically calculates optimal heap (`-Xmx`), stack (`-Xss`), and metaspace dimensions based on allocated container limits.
- **Avoid Hardcoded `-Xmx`**:
  Do not hardcode static JVM memory arguments like `-Xmx4g` that exceed allocated limits.

---

## 5. PostgreSQL Database Connectivity

When connecting to ProductEcho PostgreSQL instances:
- Include the PostgreSQL JDBC driver dependency (`org.postgresql:postgresql`).
- Configure Spring Boot Data JPA / R2DBC to read from environment variables:
  ```properties
  spring.datasource.url=${DATABASE_URL}
  spring.datasource.username=${DB_USER}
  spring.datasource.password=${DB_PASSWORD}
  ```

---

## 6. Zip Packaging & Exclusions

When bundling your Java source into a `.zip` archive for upload:

### Exclude:
- Pre-compiled binaries & build output: `target/`, `build/`, `out/`, `bin/`, `*.jar`, `*.war`, `*.class`
- Local caches: `.gradle/`, `.m2/repository/`
- VCS & IDE: `.git/`, `.idea/`, `*.iml`, `.vscode/`, `.DS_Store`
- Environment & Secret files: `.env`, `.env.*`, `*.pem`, `*.key`
- Ensure `./mvnw` or `./gradlew` and wrapper directories ARE included in the zip.
