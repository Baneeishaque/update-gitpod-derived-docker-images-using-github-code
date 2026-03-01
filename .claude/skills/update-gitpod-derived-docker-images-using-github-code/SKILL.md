# update-gitpod-derived-docker-images-using-github-code Development Patterns

> Auto-generated skill from repository analysis

## Overview

This skill teaches development patterns for a TypeScript-based automation tool that updates Gitpod-derived Docker images using GitHub code. The project focuses on container image management and CI/CD pipeline automation, with an emphasis on iterative debugging and configuration management.

## Coding Conventions

### File Naming
- Use `snake_case` for file names
- Example: `update_gitpod_derived_docker_images_using_github_code.ts`

### Import/Export Style
- Mixed import styles accepted (both ES6 and CommonJS patterns)
- Export styles vary based on module requirements
- Prioritize consistency within individual files

### Commit Style
- Freeform commit messages (average 15 characters)
- Focus on brevity while maintaining clarity
- No enforced prefixes or conventional commit format

## Workflows

### Dependency Update
**Trigger:** When dependencies need to be updated or upgraded
**Command:** `/update-deps`

1. Open `pubspec.yaml` and update dependency versions to latest stable releases
2. Run dependency resolution to regenerate `pubspec.lock`
3. Update `.tool-versions` file with new tool versions if applicable
4. Test the application to ensure compatibility with new dependencies
5. Commit changes with a descriptive message about the updates

### CodeMagic Configuration Fix
**Trigger:** When CI/CD pipeline fails or needs configuration changes
**Command:** `/fix-ci`

1. Analyze the failing CI/CD pipeline logs
2. Identify configuration issues in `codemagic.yaml`
3. Apply necessary fixes to the YAML configuration:
   ```yaml
   # Example fix patterns
   workflows:
     build:
       environment:
         # Update environment variables
         # Fix build commands
         # Adjust dependency versions
   ```
4. Test the pipeline with the new configuration
5. Apply additional iterative fixes if the pipeline still fails
6. Document any breaking changes or new requirements

### Main Library Debugging
**Trigger:** When bugs are found or functionality needs improvement
**Command:** `/debug-main`

1. Identify the issue in the main library file
2. Add debug logging or console output to trace execution:
   ```typescript
   console.log('Debug: Processing Docker image update...');
   // Add relevant debug information
   ```
3. Apply the code fix to resolve the identified issue
4. Test changes locally to verify the fix works
5. Remove or reduce debug output for production
6. Commit the fix with a clear description of what was resolved

### IDE Integration Setup
**Trigger:** When setting up development environment or adding new IDE support
**Command:** `/setup-ide`

1. Create IDE-specific configuration directories:
   - `.idea/` for IntelliJ/WebStorm
   - `.vscode/` for Visual Studio Code
   - `.gitpod.*` for Gitpod integration
2. Set up run configurations for common development tasks
3. Configure project-specific settings (TypeScript, linting, formatting)
4. Add launch configurations for debugging
5. Test that the IDE integration works properly
6. Commit configuration files for team consistency

### Gitignore Cleanup
**Trigger:** When new files need to be ignored or repository cleanup is needed
**Command:** `/clean-gitignore`

1. Identify files and directories that should be ignored:
   ```gitignore
   # Build outputs
   dist/
   build/
   
   # Dependencies
   node_modules/
   
   # IDE files
   .idea/
   .vscode/
   
   # OS files
   .DS_Store
   Thumbs.db
   ```
2. Update `.gitignore` with new patterns
3. Remove any previously tracked files that should now be ignored:
   ```bash
   git rm --cached filename
   ```
4. Commit the updated `.gitignore`
5. Verify that unwanted files are no longer tracked

## Testing Patterns

- Test files follow the `*.test.*` pattern
- Testing framework is project-specific (not standardized)
- Focus on testing main functionality and Docker image update logic
- Include integration tests for GitHub API interactions

## Commands

| Command | Purpose |
|---------|---------|
| `/update-deps` | Update project dependencies and tool versions |
| `/fix-ci` | Debug and fix CodeMagic CI/CD pipeline issues |
| `/debug-main` | Troubleshoot main library functionality |
| `/setup-ide` | Configure development environment integrations |
| `/clean-gitignore` | Update .gitignore and clean repository |