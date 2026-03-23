# Deployment Guide

## DevOps Pipeline - Complete Deployment Guide

This guide covers deploying the Jenkins pipeline with security scanning to various environments.

## 📋 Prerequisites

### System Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| Jenkins | 2.401+ | 2.450+ |
| Docker | 20.10+ | 24.0+ |
| Kubernetes | 1.24+ | 1.28+ |
| Node.js | 18.0+ | 20.0+ |
| Trivy | 0.49+ | 0.50+ |

### Required Plugins (Jenkins)

- Docker Pipeline
- Pipeline: Stage View
- Credentials Binding
- Git
- Workspace Cleanup
- Ansible

## 🔧 Initial Setup

### 1. Configure Credentials

In Jenkins → Manage Jenkins → Credentials:

| ID | Type | Description |
|----|------|-------------|
| `docker-registry` | Username/Password | Docker Hub or registry |
| `kubeconfig` | Kubernetes Configuration | Cluster access |
| `slack-webhook` | Secret Text | Slack notifications |
| `dockerhub-token` | Username/Password | Docker Hub |

### 2. Configure Tools

Manage Jenkins → Global Tool Configuration:

```
Docker: docker
  Install from docker.com
  Version: latest

NodeJS: node-20
  Install from nodejs.org
  Version: 20.10.0

Trivy: trivy
  Install from github.com/aquasecurity/trivy
  Version: 0.50.0 (NOT 0.69.4!)
```

## 📦 Build Pipeline

### Jenkinsfile Structure

```groovy
pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = 'docker.io'
        APP_NAME = 'backend-api'
        TRIVY_VERSION = '0.50.0'  // Safe version
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build') {
            steps {
                sh 'npm ci'
                sh 'npm run build'
            }
        }
        
        stage('Test') {
            steps {
                sh 'npm test'
            }
        }
        
        stage('Security Scan') {
            steps {
                script {
                    sh '''
                        docker run --rm \
                            -v $WORKSPACE:/workspace \
                            aquasec/trivy:${TRIVY_VERSION} \
                            fs --security-checks vuln /workspace
                    '''
                }
            }
        }
        
        stage('Build Image') {
            steps {
                sh """
                    docker build -t ${APP_NAME}:${BUILD_NUMBER} .
                    docker tag ${APP_NAME}:${BUILD_NUMBER} ${DOCKER_REGISTRY}/${APP_NAME}:latest
                """
            }
        }
        
        stage('Deploy to Staging') {
            when { branch 'main' }
            steps {
                sh 'kubectl apply -f k8s/staging/'
            }
        }
    }
}
```

## 🔒 Security Scanning

### Trivy Configuration

```yaml
# .trivy.yaml
format: json
exit-code: 1
severity:
  - CRITICAL
  - HIGH
security-checks:
  - vuln
  - config
ignorefile: .trivy-ignore
```

### Dockerfile Security

```dockerfile
# Build stage
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Production stage
FROM node:20-alpine
WORKDIR /app

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

COPY --from=builder --chown=nodejs:nodejs /app/dist ./dist
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nodejs:nodejs /app/package*.json ./

USER nodejs

EXPOSE 3000
CMD ["node", "dist/main.js"]
```

## ☸️ Kubernetes Deployment

### Deployment Manifest

```yaml
# k8s/production/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-api
  labels:
    app: backend-api
spec:
  replicas: 3
  selector:
    matchLabels:
      app: backend-api
  template:
    metadata:
      labels:
        app: backend-api
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 10000
        fsGroup: 10000
      containers:
        - name: backend-api
          image: backend-api:latest
          ports:
            - containerPort: 3000
          securityContext:
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
            capabilities:
              drop:
                - ALL
          resources:
            requests:
              memory: "256Mi"
              cpu: "250m"
            limits:
              memory: "512Mi"
              cpu: "500m"
          livenessProbe:
            httpGet:
              path: /api/health
              port: 3000
            initialDelaySeconds: 30
            periodSeconds: 10
          readinessProbe:
            httpGet:
              path: /api/health
              port: 3000
            initialDelaySeconds: 5
            periodSeconds: 5
```

### Service & Ingress

```yaml
# k8s/production/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: backend-api
spec:
  selector:
    app: backend-api
  ports:
    - protocol: TCP
      port: 80
      targetPort: 3000
  type: ClusterIP
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: backend-api
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  tls:
    - hosts:
        - api.yourdomain.com
      secretName: backend-api-tls
  rules:
    - host: api.yourdomain.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: backend-api
                port:
                  number: 80
```

## 🔔 Notifications

### Slack Notification

```groovy
post {
    success {
        slackSend(
            color: 'good',
            message: "✅ Build succeeded: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
            channel: '#deployments'
        )
    }
    failure {
        slackSend(
            color: 'danger',
            message: "❌ Build failed: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
            channel: '#deployments'
        )
    }
}
```

## 🧪 Environment Configuration

### Staging

```bash
# Environment variables
NODE_ENV=staging
DB_HOST=staging-db.example.com
REDIS_URL=redis://staging-redis:6379
LOG_LEVEL=debug
```

### Production

```bash
# Environment variables
NODE_ENV=production
DB_HOST=prod-db.example.com
REDIS_URL=redis://prod-redis:6379
LOG_LEVEL=warn
ALLOWED_ORIGINS=https://yourdomain.com
JWT_SECRET=<generated-secret>
```

## 📊 Monitoring

### Prometheus Metrics

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: backend-api
spec:
  selector:
    matchLabels:
      app: backend-api
  endpoints:
    - port: metrics
      path: /metrics
```

### Grafana Dashboard

Import the Node.js dashboard from Grafana Labs for:
- Request rate
- Error rate
- Response time
- Memory usage
- CPU usage

## 🔄 Rollback Procedure

### Automatic Rollback

```groovy
stage('Deploy') {
    steps {
        sh '''
            kubectl set image deployment/backend-api \
                backend-api=${IMAGE}:${VERSION}
            
            # Wait for rollout
            kubectl rollout status deployment/backend-api --timeout=5m
            
            # Verify
            kubectl rollout status deployment/backend-api
        '''
    }
    post {
        failure {
            sh '''
                kubectl rollout undo deployment/backend-api
            '''
        }
    }
}
```

### Manual Rollback

```bash
# Check rollout history
kubectl rollout history deployment/backend-api

# Rollback to previous
kubectl rollout undo deployment/backend-api

# Rollback to specific revision
kubectl rollout undo deployment/backend-api --to-revision=3
```

## 🔒 Security Checklist

- [ ] All secrets stored in Jenkins credentials
- [ ] Trivy scanning enabled (NOT version 0.69.4!)
- [ ] Non-root user in Docker
- [ ] Read-only root filesystem
- [ ] Resource limits set
- [ ] Health probes configured
- [ ] TLS enabled
- [ ] Network policies applied
- [ ] Log monitoring active

## 🚨 Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| Trivy 0.69.4 detected | Update TRIVY_VERSION to 0.50.0 or higher |
| OutOfMemoryError | Increase Docker memory limit |
| ImagePullBackOff | Check image tag and registry credentials |
| CrashLoopBackOff | Check logs: `kubectl logs <pod>` |

### Debug Commands

```bash
# View pod logs
kubectl logs -f deployment/backend-api

# Execute in pod
kubectl exec -it <pod> -- /bin/sh

# Check events
kubectl get events --sort-by='.lastTimestamp'

# Port forward
kubectl port-forward svc/backend-api 3000:80
```

---

**Last Updated:** March 2026
**Version:** 2.0
