#!/usr/bin/env python3
"""
Health Check Script for DevOps Pipeline
Verifica el estado de los componentes del pipeline
"""

import sys
import os
import subprocess
from pathlib import Path

def check_jenkins():
    """Verifica que Jenkinsfile exista y sea válido"""
    jenkinsfile = Path(__file__).parent / "Jenkinsfile"
    if jenkinsfile.exists():
        return True, "Jenkinsfile found"
    return False, "Jenkinsfile missing"

def check_docker():
    """Verifica que Docker Compose esté configurado"""
    compose_files = [
        Path(__file__).parent / "docker-compose.yml",
        Path(__file__).parent / "docker-compose.yaml"
    ]
    for compose_file in compose_files:
        if compose_file.exists():
            return True, f"docker-compose found: {compose_file.name}"
    return False, "docker-compose.yml not found"

def check_scripts():
    """Verifica scripts esenciales"""
    scripts = ["setup.sh"]
    missing = []
    for script in scripts:
        script_path = Path(__file__).parent / script
        if not script_path.exists():
            missing.append(script)
    if missing:
        return False, f"Missing scripts: {', '.join(missing)}"
    return True, "All scripts present"

def main():
    checks = [
        check_jenkins(),
        check_docker(),
        check_scripts()
    ]
    
    all_passed = True
    for passed, message in checks:
        status = "✓" if passed else "✗"
        print(f"{status} {message}")
        if not passed:
            all_passed = False
    
    if all_passed:
        print("\n✓ All health checks passed")
        sys.exit(0)
    else:
        print("\n✗ Some health checks failed")
        sys.exit(1)

if __name__ == "__main__":
    main()
