# Release Process

This project uses GitHub Actions to automatically create GitHub Releases whenever a new semantic version tag is pushed.

## Overview

The release workflow is fully automated.

After a version tag is pushed to GitHub, the Release workflow will:

- Verify the Git tag exists
- Generate release notes automatically
- Create a GitHub Release

The workflow is located at:

```text
.github/workflows/release.yml
```

---

## Semantic Versioning

This project follows Semantic Versioning (SemVer).

Example versions:

```text
v0.5.0
v0.5.1
v0.6.0
v1.0.0
```

Version format:

```text
MAJOR.MINOR.PATCH
```

- **MAJOR** – Breaking changes
- **MINOR** – New features
- **PATCH** – Bug fixes

---

## Creating a Release

### 1. Merge into `main`

Ensure all changes have been reviewed and merged into the `main` branch.

---

### 2. Create a version tag

Example:

```bash
git tag v0.6.0
```

---

### 3. Push the tag

```bash
git push origin v0.6.0
```

---

### 4. GitHub Actions

Pushing the tag automatically triggers the Release workflow.

The workflow will:

- Check out the repository
- Verify the tag
- Generate release notes
- Publish a GitHub Release

No manual intervention is required.

---

## Rollback

If a release was created by mistake:

1. Delete the GitHub Release.
2. Delete the Git tag locally.
3. Delete the Git tag from the remote repository.

Example:

```bash
git tag -d v0.6.0
git push origin :refs/tags/v0.6.0
```

---

## References

- https://semver.org/
- https://docs.github.com/actions
- https://docs.github.com/repositories/releasing-projects-on-github