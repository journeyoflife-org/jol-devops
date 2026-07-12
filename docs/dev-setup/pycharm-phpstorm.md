# Developer Setup — PyCharm & PhpStorm Remote Development

> Configuration guide for JetBrains IDEs (PyCharm Professional, PhpStorm) with remote development support.

## Prerequisites

- JetBrains IDE (PyCharm Professional 2025.3+ or PhpStorm 2025.3+)
- JetBrains Gateway installed
- SSH access to the development server

## Remote Development Setup

### 1. Install JetBrains Gateway

Download from: https://www.jetbrains.com/remote-development/gateway/

### 2. Connect to Remote Server

1. Open JetBrains Gateway
2. Select **New Connection → SSH**
3. Enter host, username, and SSH key path
4. Click **Check Connection** → **Install IDE on Remote**

### 3. Open JOL-DevOps Project

1. In the remote IDE, **Open Project**
2. Navigate to `/opt/jol/repos/jol-devops`
3. Wait for indexing to complete

## Recommended Plugins

### PyCharm

| Plugin                          | Purpose                              |
|----------------------------------|--------------------------------------|
| Docker                           | Dockerfile editing, container mgmt   |
| Kubernetes                       | YAML editing, cluster browsing       |
| GitHub Actions                   | Workflow file editing, run triggers   |
| EnvFile                          | Load .env files into run configs     |
| Shellcheck                        | Shell script linting                 |
| Makefile Support                 | Makefile syntax highlighting         |

### PhpStorm

| Plugin                          | Purpose                              |
|----------------------------------|--------------------------------------|
| Docker                           | Dockerfile editing, container mgmt   |
| Kubernetes                       | YAML editing, cluster browsing       |
| GitHub Actions                   | Workflow file editing, run triggers   |
| PHP Annotations                  | PHPDoc support                       |
| Shellcheck                        | Shell script linting                 |
| Makefile Support                 | Makefile syntax highlighting         |

## IDE Settings

### File Watchers

No file watchers needed — pre-commit hooks handle formatting.

### Run Configurations

Create the following run configurations for local development:

| Name                    | Type    | Command                                               |
|-------------------------|---------|-------------------------------------------------------|
| Check Tools             | Shell   | `bash scripts/utils/check-tools.sh`                   |
| Lint YAML               | Shell   | `make lint-yaml`                                      |
| Lint Shell              | Shell   | `make lint-shell`                                     |
| Scan Secrets            | Shell   | `make scan-secrets`                                   |
| Validate Alerts         | Shell   | `make validate-alerts`                                |
| Collect SOC2 Evidence   | Shell   | `make collect-evidence`                               |

### Editor Settings

Import `.editorconfig` (automatic in JetBrains IDEs):
- Indent: 2 spaces (4 for Python)
- Line endings: LF
- UTF-8 encoding
- Trim trailing whitespace

### Terminal

Set the default terminal to bash:
- **Settings → Tools → Terminal → Shell path**: `/bin/bash`
- Enable **Shell Integration** for better prompt support
