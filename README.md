# 🔄 DevOps Pipeline 2026

Pipeline de CI/CD completo y automatizado para aplicaciones containerizadas con seguridad integrada.

## ⚠️ Aviso de Seguridad - Trivy Comprometido

**Marzo 2026:** Trivy sufrió un segundo ataque de supply chain. Este pipeline **ha migrado a Grype** como alternativa segura.

- **Grype**: Escaneo de vulnerabilidades principal
- **Checkov**: Escaneo de infraestructura como código (IaC)

## 📋 Descripción

Pipeline declarativo Jenkins que automatiza el ciclo de vida completo:
- **Build** → **Test** → **Security Scan** → **Deploy**

## 🚀 Características

- ✅ Multi-stage Pipeline con stages independientes
- ✅ Docker Integration - Build y push de imágenes
- ✅ Security Scanning con Grype (reemplazó Trivy)
- ✅ Kubernetes Deploy - Staging y Production
- ✅ Branch-based - Estrategias para develop y main
- ✅ Notifications - Alertas por Slack/Email
- ✅ Dependency Scanning - npm audit
- ✅ Container Scanning - Grype image scan
- ✅ IaC Scanning - Checkov para Kubernetes YAML

## 📁 Estructura del Proyecto

```
devops-pipeline-20260321/
├── Jenkinsfile              # Pipeline declarativo principal
├── docker-compose.yml       # Orquestación de servicios
├── Dockerfile               # Imagen de la aplicación
├── Makefile                 # Comandos útiles
├── setup.sh                 # Script de configuración
├── health_check.py         # Script de health check
├── k8s/                    # Manifiestos Kubernetes
│   ├── staging/           # Staging deployment
│   └── production/        # Production deployment
├── .github/                # GitHub Actions (backup)
│   └── workflows/
├── .grype.yaml            # Configuración de Grype
├── .dockerignore
├── .env.example
├── .gitignore
├── LICENSE
├── CODEOWNERS
├── CONTRIBUTING.md
├── DEPLOYMENT.md          # Guía de despliegue
├── SECURITY.md            # Política de seguridad
├── CHANGELOG.md
└── README.md
```

## 🚀 Inicio Rápido

### 1. Configuración Inicial

```bash
# Clonar y configurar
git clone https://github.com/alexkore12/devops-pipeline-20260321.git
cd devops-pipeline-20260321

# Ejecutar script de setup
chmod +x setup.sh
./setup.sh
```

### 2. Configurar Variables de Entorno

```bash
# Copiar ejemplo de configuración
cp .env.example .env

# Editar con tus valores
nano .env
```

### 3. Verificar Salud del Sistema

```bash
python3 health_check.py
```

## 📊 Pipeline Stages

```
┌─────────────┐    ┌──────────┐    ┌─────────┐    ┌──────────────┐
│  Checkout   │───▶│   Build   │───▶│  Test   │───▶│Security Scan │
└─────────────┘    └──────────┘    └─────────┘    └──────────────┘
                                                        │
                                                        ▼
┌─────────────┐    ┌─────────────┐    ┌────────────┐    ┌──────────────┐
│   Notify    │◀───│  Deploy     │◀───│  Approve   │◀───│    Scan     │
│             │    │  Prod       │    │            │    │  Container   │
└─────────────┘    └─────────────┘    └────────────┘    └──────────────┘
```

## 🐳 Docker

### Build Manual

```bash
docker build -t devops-pipeline .
```

### Docker Compose

```bash
# Iniciar servicios
docker-compose up -d

# Ver logs
docker-compose logs -f

# Detener
docker-compose down
```

### Variables de Entorno Docker

| Variable | Descripción | Valor por defecto |
|----------|-------------|-------------------|
| `APP_NAME` | Nombre de la aplicación | backend-api |
| `PORT` | Puerto de la app | 3000 |
| `NODE_ENV` | Entorno | development |
| `LOG_LEVEL` | Nivel de logging | info |

## ☸️ Kubernetes

### Requisitos

- Kubernetes cluster (minikube, kind, EKS, GKE, AKS)
- kubectl configurado
- Docker registry accesible

### Despliegue a Staging

```bash
kubectl apply -f k8s/staging/
```

### Despliegue a Production

```bash
kubectl apply -f k8s/production/
```

### Verificar Deployment

```bash
kubectl rollout status deployment/<APP_NAME>
```

## 🔐 Seguridad

### Escaneo con Grype

```bash
# Instalar Grype
curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh

# Escanear imagen
grype image tu-imagen:latest

# Escanear directorio local
grype fs ./path/to/code
```

### Escaneo con Checkov

```bash
# Instalar Checkov
pip install checkov

# Escanear archivos YAML
checkov -d k8s/

# Escanear archivo específico
checkov -f k8s/production/deployment.yaml
```

### Variables de Seguridad

| Variable | Descripción |
|----------|-------------|
| `TRIVY_VERSION` | Versión de Trivy (NO usar 0.69.4) |
| `GRYPE_VERSION` | Versión de Grype |
| `SCAN_SEVERITY` | Severidad mínima (MEDIUM, HIGH, CRITICAL) |

## 🔧 Comandos Útiles

### Makefile

```bash
make help              # Mostrar ayuda
make build            # Build Docker
make test             # Ejecutar tests
make scan             # Security scan
make deploy-staging   # Deploy a staging
make deploy-prod      # Deploy a production
make clean            # Limpiar contenedores
```

## 📈 Monitoreo

### Health Check

```bash
python3 health_check.py
```

Salida esperada:
```json
{
  "service": "devops-pipeline",
  "status": "healthy",
  "checks": {...}
}
```

## 📝 Changelog

### v2.0.0 (2026-03-23)
- ✅ Migrado de Trivy a Grype (supply chain security)
- ✅ Añadido Checkov para escaneo de IaC
- ✅ Mejorado README con documentación completa
- ✅ Añadido CODEOWNERS
- ✅ Añadido health_check.py
- ✅ Añadido setup.sh
- ✅ Añadido Makefile

### v1.0.0 (2026-03-21)
- ✅ Pipeline inicial con Jenkins
- ✅ Stages: Build, Test, Deploy
- ✅ Docker integration

## 🤝 Contributing

Ver [CONTRIBUTING.md](CONTRIBUTING.md) para guidelines.

## 📄 Licencia

MIT License - ver [LICENSE](LICENSE) para detalles.

## 👤 Autor

**alexkore12** - https://github.com/alexkore12

## 🤖 Actualizado por

OpenClaw AI Assistant - 2026-03-23
*Mejoras v2.0: Grype + Checkov + documentación completa*

## 🌐 Referencias

- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [Grype Vulnerability Scanner](https://github.com/anchore/grype)
- [Checkov](https://www.checkov.io/)
- [GitHub Actions](https://docs.github.com/en/actions)
