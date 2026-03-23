pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = 'docker.io'
        APP_NAME = 'backend-api'
        // Trivy version - CRITICAL: Avoid compromised versions
        TRIVY_VERSION = '0.69.3'  // NOT 0.69.4 (compromised)
    }
    
    options {
        timeout(time: 30, unit: 'MINUTES')
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build') {
            steps {
                sh 'npm install'
                sh 'npm run build'
            }
        }
        
        stage('Test') {
            steps {
                sh 'npm test'
            }
        }
        
        // ==========================================
        // SECURITY SCANNING - Enhanced
        // ==========================================
        
        stage('Dependency Scan') {
            steps {
                script {
                    // npm audit with JSON output
                    def auditResult = sh(
                        script: 'npm audit --json 2>/dev/null || true',
                        returnStdout: true
                    ).trim()
                    
                    // Parse and fail on critical vulnerabilities
                    def parsed = readJSON(text: auditResult)
                    
                    if (parsed.metadata?.vulnerabilities?.critical > 0) {
                        error("CRITICAL vulnerabilities found in dependencies!")
                    }
                }
            }
        }
        
        stage('Trivy Security Scan') {
            steps {
                script {
                    // Install specific Trivy version (NOT 0.69.4)
                    sh '''
                        # Install Trivy (avoid compromised version)
                        if ! command -v trivy &> /dev/null; then
                            echo "Installing Trivy..."
                            curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -v ${TRIVY_VERSION}
                        fi
                        
                        # Check Trivy version
                        trivy version
                        
                        # Check for compromised version
                        TRIVY_VER=$(trivy version 2>/dev/null | grep -oP "\\d+\\.\\d+\\.\\d+" || echo "unknown")
                        if [ "$TRIVY_VER" = "0.69.4" ]; then
                            echo "ERROR: Trivy 0.69.4 is COMPROMISED!"
                            exit 1
                        fi
                    '''
                }
            }
        }
        
        stage('Container Scan') {
            steps {
                script {
                    // Build temporary image for scanning
                    sh """
                        docker build -t \${APP_NAME}:scan-\${BUILD_NUMBER} .
                        
                        # Scan with Trivy
                        trivy image \
                            --severity HIGH,CRITICAL \
                            --exit-code 1 \
                            --ignore-unfixed \
                            \${APP_NAME}:scan-\${BUILD_NUMBER} || true
                        
                        # Clean up scan image
                        docker rmi \${APP_NAME}:scan-\${BUILD_NUMBER} || true
                    """
                }
            }
        }
        
        // ==========================================
        // DOCKER BUILD
        // ==========================================
        
        stage('Docker Build') {
            steps {
                sh "docker build -t ${APP_NAME}:${BUILD_NUMBER} ."
                sh "docker tag ${APP_NAME}:${BUILD_NUMBER} ${APP_NAME}:latest"
            }
        }
        
        stage('Deploy to Staging') {
            steps {
                sh 'kubectl apply -f k8s/staging/'
            }
        }
        
        stage('Integration Tests') {
            steps {
                sh 'npm run test:integration'
            }
        }
        
        stage('Deploy to Production') {
            when {
                branch 'main'
            }
            steps {
                sh 'kubectl apply -f k8s/production/'
                sh 'kubectl rollout status deployment/${APP_NAME}'
            }
        }
    }
    
    post {
        always {
            // Archive security reports
            archiveArtifacts artifacts: 'reports/**', allowEmptyArchive: true
            
            cleanWs()
        }
        
        success {
            slackSend color: 'good', message: "✅ Build ${BUILD_NUMBER} succeeded - Security scans passed"
        }
        
        failure {
            slackSend color: 'danger', message: "❌ Build ${BUILD_NUMBER} failed - Check security scans"
        }
    }
}
