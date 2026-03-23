# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |

## Reporting a Vulnerability

Report security issues via GitHub Issues or contact the owner directly.

## DevOps Pipeline Security

This pipeline implements security at every stage:

### Build Stage
- Dependency vulnerability scanning
- Container image scanning (Trivy/Grype)
- SAST (Static Application Security Testing)

### Test Stage
- DAST (Dynamic Application Security Testing)
- Integration tests with security validation

### Deploy Stage
- Secure credential handling
- Infrastructure as Code validation
- Policy enforcement (OPA, Conftest)

## Security Tools

- **SAST**: Semgrep, CodeQL
- **Dependency**: npm audit, pip-audit, Dependabot
- **Container**: Grype (RECOMMENDED), Trivy (⚠️ Compromised), Clair
- **Secrets**: Gitleaks, TruffleHog
- **IaC**: Checkov (RECOMMENDED), tfsec, Terrascan

## Compliance

- All images scanned before deployment
- No secrets in code or config files
- Regular dependency updates
- Audit logging enabled

---

## ⚠️ CVE-2026-28500 - ONNX Supply Chain Attack

**Fecha:** Marzo 2026 | **Severidad:** HIGH (CVSS 8.6)

### Descripción
Se descubrió una vulnerabilidad crítica en la biblioteca ONNX que permite ataques a la cadena de suministro (supply chain attack).

### Vulnerabilidad
- **Vector:** `onnx.hub.load()` con parámetro `silent=True`
- **Problema:** El parámetro silent=True salta las advertencias de seguridad, permitiendo que cargas maliciosas se ejecuten sin notificación
- **Impacto:** Exfiltración de archivos sensibles (SSH keys, credenciales cloud, tokens)

### Referencias
- NVD: https://nvd.nist.gov/vuln/detail/CVE-2026-28500
- Reddit r/pwnhub: Discusión original

### Acción Recomendada
Si tu proyecto usa ONNX, verifica la versión y considera actualizar cuando hay parche disponible. Evita usar `silent=True` en producción.
