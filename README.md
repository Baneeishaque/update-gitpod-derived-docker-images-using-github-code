# update-gitpod-derived-docker-images-using-github-code

A Dart command-line application that automatically searches for and updates Gitpod-derived Docker images by traversing the dependency tree of Docker images using the GitHub Code Search API.

## Features

- **GitHub Code Search Integration**: Uses GitHub API to find repositories with Dockerfiles that depend on a base image
- **Automated Docker Image Building**: Automatically builds derived Docker images from discovered repositories
- **Docker Hub Integration**: Pushes built images to Docker Hub
- **Disk Space Management**: Monitors disk usage and cleans up images when storage limits are reached
- **CI/CD Integration**: Supports Azure Pipelines and Codemagic for automated builds

## Usage

```bash
# Get dependencies
dart pub get

# Set up environment variables
cp .env_sample .env
# Edit .env with your credentials

# Run the application
dart run update_gitpod_derived_docker_images_using_github_code '<base-image-name>'

# Run in dry-run mode (no actual builds)
dart run update_gitpod_derived_docker_images_using_github_code '<base-image-name>' --dry-run
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `GITHUB_PERSONAL_ACCESS_TOKEN` | GitHub personal access token for API requests |
| `MAXIMUM_DISK_USAGE_PERCENTAGE` | Threshold for disk cleanup (e.g., 60) |
| `DOCKER_HUB_USERNAME` | Docker Hub username for pushing images |
| `DOCKER_HUB_PASSWORD` | Docker Hub password/token |

## GitHub Repository Topics

This repository uses the following topics for discoverability:

### Suggested Topics

| Topic | Description |
|-------|-------------|
| `dart` | Main programming language |
| `docker` | Docker image management |
| `gitpod` | Gitpod workspace configuration |
| `github-api` | GitHub API integration |
| `dockerfile` | Dockerfile processing |
| `azure-pipelines` | Azure DevOps CI/CD integration |
| `codemagic` | Codemagic CI/CD integration |
| `ci-cd` | Continuous integration/deployment |
| `automation` | Automated image updates |
| `docker-hub` | Docker Hub registry integration |
| `command-line-tool` | CLI application |
| `devops` | DevOps automation practices |

### How to Add GitHub Topics

#### Method 1: GitHub CLI (Recommended)

```bash
# Install GitHub CLI if not already installed
# macOS: brew install gh
# Ubuntu: sudo apt install gh
# Windows: winget install GitHub.cli

# Authenticate with GitHub
gh auth login

# Add topics one by one
gh repo edit Baneeishaque/update-gitpod-derived-docker-images-using-github-code --add-topic dart
gh repo edit Baneeishaque/update-gitpod-derived-docker-images-using-github-code --add-topic docker
gh repo edit Baneeishaque/update-gitpod-derived-docker-images-using-github-code --add-topic gitpod
gh repo edit Baneeishaque/update-gitpod-derived-docker-images-using-github-code --add-topic github-api
gh repo edit Baneeishaque/update-gitpod-derived-docker-images-using-github-code --add-topic dockerfile
gh repo edit Baneeishaque/update-gitpod-derived-docker-images-using-github-code --add-topic azure-pipelines
gh repo edit Baneeishaque/update-gitpod-derived-docker-images-using-github-code --add-topic codemagic
gh repo edit Baneeishaque/update-gitpod-derived-docker-images-using-github-code --add-topic ci-cd
gh repo edit Baneeishaque/update-gitpod-derived-docker-images-using-github-code --add-topic automation
gh repo edit Baneeishaque/update-gitpod-derived-docker-images-using-github-code --add-topic docker-hub
gh repo edit Baneeishaque/update-gitpod-derived-docker-images-using-github-code --add-topic command-line-tool
gh repo edit Baneeishaque/update-gitpod-derived-docker-images-using-github-code --add-topic devops

# Or add all topics at once (comma-separated, no spaces)
gh repo edit Baneeishaque/update-gitpod-derived-docker-images-using-github-code --add-topic dart,docker,gitpod,github-api,dockerfile,azure-pipelines,codemagic,ci-cd,automation,docker-hub,command-line-tool,devops
```

#### Method 2: GitHub Web Interface

1. Navigate to the repository: https://github.com/Baneeishaque/update-gitpod-derived-docker-images-using-github-code
2. Click on the ⚙️ gear icon next to "About" in the right sidebar
3. In the "Topics" field, add the topics listed above
4. Click "Save changes"

#### Method 3: GitHub REST API

```bash
# Using curl with a Personal Access Token
curl -X PUT \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer YOUR_GITHUB_TOKEN" \
  https://api.github.com/repos/Baneeishaque/update-gitpod-derived-docker-images-using-github-code/topics \
  -d '{"names":["dart","docker","gitpod","github-api","dockerfile","azure-pipelines","codemagic","ci-cd","automation","docker-hub","command-line-tool","devops"]}'
```

#### Method 4: GraphQL API

```graphql
mutation {
  updateRepository(input: {
    repositoryId: "REPOSITORY_NODE_ID",
    topics: ["dart", "docker", "gitpod", "github-api", "dockerfile", "azure-pipelines", "codemagic", "ci-cd", "automation", "docker-hub", "command-line-tool", "devops"]
  }) {
    repository {
      repositoryTopics(first: 20) {
        nodes {
          topic {
            name
          }
        }
      }
    }
  }
}
```

### Viewing Current Topics

```bash
# Using GitHub CLI
gh repo view Baneeishaque/update-gitpod-derived-docker-images-using-github-code --json topics

# Using REST API
curl -H "Accept: application/vnd.github+json" \
  https://api.github.com/repos/Baneeishaque/update-gitpod-derived-docker-images-using-github-code/topics
```

## License

This project is available under the terms specified in the repository