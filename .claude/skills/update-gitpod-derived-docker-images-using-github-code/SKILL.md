```markdown
# update-gitpod-derived-docker-images-using-github-code Development Patterns

> Auto-generated skill from repository analysis

## Overview
This skill teaches you the development patterns and conventions used in the `update-gitpod-derived-docker-images-using-github-code` repository. The codebase is written in TypeScript and focuses on updating Gitpod-derived Docker images using GitHub code. It emphasizes consistent file naming, import/export styles, and testing patterns to ensure maintainability and clarity.

## Coding Conventions

### File Naming
- Use **camelCase** for file names.
  - Example: `updateImages.ts`, `dockerUtils.ts`

### Import Style
- Use **relative imports** for internal modules.
  - Example:
    ```typescript
    import { updateDockerImage } from './dockerUtils';
    ```

### Export Style
- Use **named exports** for functions and constants.
  - Example:
    ```typescript
    // dockerUtils.ts
    export function updateDockerImage() { /* ... */ }
    ```

### Commit Message Patterns
- Commit messages are **freeform** (no enforced prefixes), with an average length of 28 characters.

## Workflows

_No automated workflows detected in this repository._

## Testing Patterns

- **Test Framework:** Unknown (not detected)
- **Test File Pattern:** Files containing `.test.` in their names.
  - Example: `updateImages.test.ts`
- **Test Structure:** Place tests alongside or near the code they test, following the `.test.` naming pattern.

## Commands

| Command | Purpose |
|---------|---------|
| /update-images | Run the process to update Gitpod-derived Docker images using the latest GitHub code. |
| /run-tests     | Execute all test files matching the `*.test.*` pattern. |

```