# 🐳 Update Gitpod Derived Docker Images Using GitHub Code

<p align="center">
  <a href="https://dart.dev"><img src="https://img.shields.io/badge/Dart-2.11+-00B4AB?style=for-the-badge&logo=dart&logoColor=white" alt="Dart"></a>
  <a href="https://gitpod.io"><img src="https://img.shields.io/badge/Gitpod-Ready--to--Code-908a85?style=for-the-badge&logo=gitpod&logoColor=white" alt="Gitpod Ready-to-Code"></a>
  <a href="https://www.docker.com"><img src="https://img.shields.io/badge/Docker-Enabled-2496ED?style=for-the-badge&logo=docker&logoColor=white" alt="Docker"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge" alt="License: MIT"></a>
</p>

<p align="center">
  <strong>A powerful Dart CLI tool that automatically discovers and rebuilds Docker images derived from Gitpod workspaces using the GitHub API.</strong>
</p>

---

## 📖 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Architecture](#-architecture)
- [Prerequisites](#-prerequisites)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Usage](#-usage)
- [API Reference](#-api-reference)
- [Development](#-development)
- [CI/CD Integration](#-cicd-integration)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🌟 Overview

This tool automates the process of discovering and rebuilding Docker images that are derived from Gitpod workspace configurations. It leverages the GitHub Search Code API to find `.gitpod.Dockerfile` files that reference a base image, then recursively builds, pushes, and manages the entire dependency tree of derived images to Docker Hub.

### Problem It Solves

When you have a hierarchy of Gitpod Docker images (where one image is based on another), updating the base image requires manually rebuilding all derived images. This tool automates that entire workflow by:

1. **Discovering** all repositories that use a specific base image via GitHub Code Search
2. **Building** Docker images in the correct dependency order
3. **Pushing** rebuilt images to Docker Hub
4. **Managing** disk space by intelligently cleaning up images when needed

---

## ✨ Features

- 🔍 **Automatic Discovery** - Uses GitHub Search Code API to find all derived Dockerfiles
- 🔄 **Recursive Processing** - Handles multi-level image inheritance hierarchies
- 📦 **Smart Caching** - Tracks built and pushed images to avoid redundant work
- 💾 **Disk Management** - Monitors disk usage and cleans up images when necessary
- 🚀 **Dry Run Mode** - Preview what would be built without making changes
- ⏱️ **Rate Limit Handling** - Respects GitHub API rate limits with automatic delays
- 🔐 **Secure Auth** - Uses environment variables for sensitive credentials

---

## 🏗️ Architecture

### Project Structure

```
.
├── bin/
│   └── update_gitpod_derived_docker_images_using_github_code.dart  # CLI entry point
├── lib/
│   ├── update_gitpod_derived_docker_images_using_github_code.dart  # Core logic
│   └── GithubApiSearchCodeRequestResponse.dart                     # API response models
├── .gitpod.Dockerfile          # Gitpod workspace Docker configuration
├── .gitpod.yml                 # Gitpod workspace settings
├── pubspec.yaml                # Dart dependencies
├── analysis_options.yaml       # Dart linter configuration
├── azure-pipelines.yml         # Azure DevOps CI configuration
├── codemagic.yaml              # Codemagic CI configuration
├── docker_cleanup.bash         # Docker cleanup utility script
├── githubApiRequestRateLimitChecker.bash  # Rate limit checker script
└── .env_sample                 # Environment variables template
```

### Core Components

#### 1. GitHub API Integration

The tool uses the GitHub Search Code API to find Dockerfiles containing references to base images:

```dart
// Search query format
'$imageName in:file user:$gitHubUsername path:/ language:Dockerfile filename:.gitpod fork:true'
```

#### 2. Docker Operations

- **Build**: Builds images directly from GitHub repository URLs
- **Push**: Pushes built images to Docker Hub
- **Cleanup**: Manages image removal based on disk usage

#### 3. Dependency Tracking

Maintains persistent state files:
- `builtImages.txt` - List of successfully built images
- `pushedImages.txt` - List of successfully pushed images

### Data Flow

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│   Base Image    │────▶│  GitHub Search   │────▶│ Derived Images  │
│   Name Input    │     │   Code API       │     │   Discovery     │
└─────────────────┘     └──────────────────┘     └─────────────────┘
                                                          │
                                                          ▼
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│   Docker Hub    │◀────│  Docker Build    │◀────│  Process Each   │
│   Registry      │     │   & Push         │     │   Derived Image │
└─────────────────┘     └──────────────────┘     └─────────────────┘
```

---

## 📋 Prerequisites

### Required Software

| Software | Version | Purpose |
|----------|---------|---------|
| [Dart SDK](https://dart.dev/get-dart) | >= 2.11.0, < 3.0.0 | Runtime environment |
| [Docker](https://docs.docker.com/get-docker/) | Latest | Building and pushing images |
| [Git](https://git-scm.com/) | Latest | Repository operations |

### Required Accounts

- **GitHub Account** with a [Personal Access Token](https://github.com/settings/tokens) (needs `repo` scope)
- **Docker Hub Account** with credentials for pushing images

---

## 🚀 Installation

### Option 1: Clone and Run Locally

```bash
# Clone the repository
git clone https://github.com/Baneeishaque/update-gitpod-derived-docker-images-using-github-code.git
cd update-gitpod-derived-docker-images-using-github-code

# Install Dart dependencies
dart pub get

# Set up environment variables
cp .env_sample .env
# Edit .env with your credentials
```

### Option 2: Gitpod (Recommended for Development)

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/Baneeishaque/update-gitpod-derived-docker-images-using-github-code)

The repository includes a pre-configured Gitpod workspace with:
- Full VNC desktop environment
- Pre-installed development tools
- Android Studio, IntelliJ IDEA, and other JetBrains IDEs
- Docker support

### Option 3: Using asdf Version Manager

```bash
# Install Dart using asdf (version specified in .tool-versions)
asdf install
dart pub get
```

---

## ⚙️ Configuration

### Environment Variables

Create a `.env` file in the project root (use `.env_sample` as template):

```bash
# GitHub Personal Access Token (required)
# Needs 'repo' scope for Search Code API
GITHUB_PERSONAL_ACCESS_TOKEN=ghp_your_token_here

# Maximum disk usage percentage before cleanup triggers (required)
# Recommended: 60-80
MAXIMUM_DISK_USAGE_PERCENTAGE=60

# Docker Hub credentials (required for pushing images)
DOCKER_HUB_USERNAME=your_username
DOCKER_HUB_PASSWORD=your_password_or_token
```

### Security Notes

⚠️ **Important Security Practices:**
- Never commit `.env` file to version control (it's in `.gitignore`)
- Use Docker Hub access tokens instead of passwords when possible
- Rotate tokens periodically
- Use minimum required scopes for GitHub tokens

---

## 🎯 Usage

### Basic Usage

```bash
# Run with a base image name
dart run update_gitpod_derived_docker_images_using_github_code <base_image_name>

# Example
dart run update_gitpod_derived_docker_images_using_github_code 'baneeishaque/gitpod-workspace-full-vnc'
```

### Dry Run Mode

Preview what would be built without making actual changes:

```bash
dart run update_gitpod_derived_docker_images_using_github_code <base_image_name> --dry-run
```

### CLI Arguments

| Argument | Description | Required |
|----------|-------------|----------|
| `<base_image_name>` | Docker image name to search for (e.g., `baneeishaque/gitpod-workspace-full`) | Yes |
| `--dry-run` | Execute without building/pushing images | No |

### Example Workflow

```bash
# 1. Set up environment
cp .env_sample .env
vim .env  # Add your credentials

# 2. Install dependencies
dart pub get

# 3. Preview changes (dry run)
dart run update_gitpod_derived_docker_images_using_github_code 'baneeishaque/gitpod-workspace-full-vnc' --dry-run

# 4. Execute full rebuild
dart run update_gitpod_derived_docker_images_using_github_code 'baneeishaque/gitpod-workspace-full-vnc'
```

---

## 📚 API Reference

### Core Functions

#### `searchForGitpodDerivedImages`

Main entry point that orchestrates the entire rebuild process.

```dart
Future<void> searchForGitpodDerivedImages(
  String baseImageName,
  {bool isDryRun = false}
)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `baseImageName` | `String` | The Docker image name to search for in Dockerfiles |
| `isDryRun` | `bool` | If true, skips actual build/push operations |

#### `searchForGitHubCode`

Queries the GitHub Search Code API.

```dart
Future<GitHubApiSearchCodeRequestResponse> searchForGitHubCode(
  String searchQuery
)
```

#### `repositoryCloneBuildPushAndRemoveImage`

Handles the complete lifecycle of building a single image.

```dart
Future<void> repositoryCloneBuildPushAndRemoveImage(
  String imageName,
  {bool afterCleanUp = false, bool isDryRun = false}
)
```

### Data Models

#### `GitHubApiSearchCodeRequestResponse`

Represents the GitHub Search Code API response.

```dart
class GitHubApiSearchCodeRequestResponse {
  int totalCount;
  bool incompleteResults;
  List<Items> items;
}
```

#### `Items`

Represents a single search result item.

```dart
class Items {
  String name;
  String path;
  String sha;
  String url;
  Repository repository;
  double score;
}
```

---

## 💻 Development

### Development Setup

```bash
# Clone repository
git clone https://github.com/Baneeishaque/update-gitpod-derived-docker-images-using-github-code.git
cd update-gitpod-derived-docker-images-using-github-code

# Install dependencies
dart pub get

# Configure environment
cp .env_sample .env
# Edit .env with your credentials
```

### Running Tests

```bash
dart test
```

### Code Analysis

```bash
# Run Dart analyzer
dart analyze

# Format code
dart format .
```

### IDE Support

#### VS Code

Pre-configured tasks are available in `.vscode/tasks.json`:
- **Build Gitpod Docker Image** - Builds the workspace image
- **Run Gitpod Docker Image** - Runs the built image interactively
- **Login to Docker Hub** - Authenticates with Docker Hub

#### JetBrains IDEs (IntelliJ IDEA, WebStorm, etc.)

Run configurations are provided in `.idea/runConfigurations/`:
- `update_gitpod_derived_docker_images_using_github_code_dart.xml` - Standard run
- `update_gitpod_derived_docker_images_using_github_code_dart___dry_run.xml` - Dry run mode

### Utility Scripts

#### Docker Cleanup

```bash
# Remove all Docker containers and images
bash docker_cleanup.bash
```

#### Check GitHub API Rate Limits

```bash
# Replace GITHUB_PERSONAL_ACCESS_TOKEN with your token
curl -H "Accept: application/vnd.github+json" \
     -H "Authorization: token YOUR_TOKEN" \
     https://api.github.com/rate_limit
```

---

## 🔄 CI/CD Integration

### Azure Pipelines

Configuration file: `azure-pipelines.yml`

Triggers on `master` branch and builds the Gitpod Docker image.

```yaml
trigger:
  - master

stages:
  - stage: Build_Image
    jobs:
      - job: Build_Image
        pool:
          vmImage: ubuntu-latest
        steps:
          - task: Docker@2
            inputs:
              command: 'build'
              Dockerfile: '.gitpod.Dockerfile'
```

### Codemagic

Configuration file: `codemagic.yaml`

Full CI workflow with:
- Dart installation on macOS (Mac Mini M1)
- Dependency caching
- Automatic triggering on push, PR, and tags
- Email notifications

### Gitpod

Configuration file: `.gitpod.yml`

Features:
- Custom Docker image with pre-installed tools
- VNC desktop support (port 6080)
- Prebuild configuration for faster startup
- VS Code extensions pre-installed

---

## 🔧 Troubleshooting

### Common Issues

#### 1. GitHub API Rate Limit Exceeded

**Symptom:** Error messages about rate limiting

**Solution:** The tool automatically waits when approaching rate limits. You can check your current rate limit status:

```bash
curl -H "Authorization: token YOUR_TOKEN" https://api.github.com/rate_limit
```

#### 2. Docker Hub Authentication Failed

**Symptom:** Login errors when pushing images

**Solution:**
- Verify `DOCKER_HUB_USERNAME` and `DOCKER_HUB_PASSWORD` in `.env`
- Consider using a Docker Hub access token instead of password
- Run `docker login` manually to test credentials

#### 3. Disk Space Issues

**Symptom:** Build failures or automatic cleanup not working

**Solution:**
- Adjust `MAXIMUM_DISK_USAGE_PERCENTAGE` in `.env`
- Run manual cleanup: `bash docker_cleanup.bash`
- Check disk usage: `df -h`

#### 4. Missing Dependencies

**Symptom:** Dart compilation errors

**Solution:**
```bash
dart pub get
dart pub upgrade
```

### Debug Mode

For detailed logging, examine the output during execution. The tool prints:
- API request counts
- Build progress
- Disk usage percentages
- Image lists (built and pushed)

---

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

### Getting Started

1. **Fork** the repository
2. **Clone** your fork locally
3. **Create** a feature branch: `git checkout -b feature/amazing-feature`
4. **Make** your changes
5. **Test** your changes thoroughly
6. **Commit** with clear messages: `git commit -m 'Add amazing feature'`
7. **Push** to your fork: `git push origin feature/amazing-feature`
8. **Open** a Pull Request

### Development Guidelines

#### Code Style

- Follow [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use `dart format` before committing
- Ensure `dart analyze` passes without errors

#### Commit Messages

Use clear, descriptive commit messages:
- `feat: Add support for multiple GitHub users`
- `fix: Handle API rate limit correctly`
- `docs: Update installation instructions`
- `refactor: Simplify image cleanup logic`

#### Pull Request Process

1. Update documentation if needed
2. Add tests for new functionality
3. Ensure all tests pass
4. Update CHANGELOG.md with your changes
5. Request review from maintainers

### Reporting Issues

When opening an issue, please include:
- Dart version (`dart --version`)
- Docker version (`docker --version`)
- Operating system
- Steps to reproduce
- Expected vs actual behavior
- Relevant log output

### Feature Requests

Feature requests are welcome! Please:
- Check existing issues first
- Describe the use case
- Explain why it would be beneficial
- Consider if you can help implement it

---

## 📊 Dependencies

### Runtime Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| [docker2](https://pub.dev/packages/docker2) | ^2.2.8 | Docker CLI wrapper |
| [dotenv](https://pub.dev/packages/dotenv) | ^3.0.0 | Environment variable management |
| [http](https://pub.dev/packages/http) | ^0.13.4 | HTTP client for API requests |
| [intl](https://pub.dev/packages/intl) | 0.18.1 | String formatting utilities |

### Dev Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| [test](https://pub.dev/packages/test) | ^1.21.4 | Testing framework |

---

## 🔐 Security

### Responsible Disclosure

If you discover a security vulnerability, please:
1. **Do not** open a public issue
2. Email the maintainer directly
3. Allow time for a fix before public disclosure

### Security Best Practices for Users

- Store credentials in `.env` file (never commit to git)
- Use environment-specific tokens
- Rotate access tokens regularly
- Use least-privilege access tokens
- Enable 2FA on GitHub and Docker Hub accounts

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- [Gitpod](https://gitpod.io) for cloud development environments
- [GitHub API](https://docs.github.com/en/rest) for code search capabilities
- [Docker](https://www.docker.com) for containerization platform
- [Dart](https://dart.dev) for the programming language

---

## 📬 Contact

- **Author:** [Baneeishaque](https://github.com/Baneeishaque)
- **Repository:** [update-gitpod-derived-docker-images-using-github-code](https://github.com/Baneeishaque/update-gitpod-derived-docker-images-using-github-code)

---

<p align="center">
  Made with ❤️ for the Gitpod community
</p>