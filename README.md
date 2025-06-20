# Stacks Azure Fabric

This repo holds the infrastructure and code required for deploying Azure Fabric according to the Ensono Stacks framework.

## Code quality checks

This project uses [pre-commit](https://pre-commit.com/) to automate code quality checks and formatting.

### Pre-commit hook installation

To ensure pre-commit checks run automatically on every `git commit`, you must install the git hooks after cloning the repository:

```sh
poetry run pre-commit install
```

You only need to do this once per clone. After that, pre-commit will run automatically on every commit.

### How to run pre-commit checks

- **Run all checks on all files:**
  ```sh
  poetry run pre-commit run --all-files
  ```
- **Run checks only on staged files (default on commit):**
  ```sh
  poetry run pre-commit run
  ```
- **Run a specific hook:**
  ```sh
  poetry run pre-commit run <hook-id> --all-files
  ```
  Replace `<hook-id>` with the name of the hook (e.g., `black`, `flake8`).

### Common parameters

- `--all-files` : Run the hook(s) on all files, not just changed ones.
- `-v` or `--verbose` : Show detailed output.
- `--show-diff-on-failure` : Show a diff when a hook fails and can fix the file.
- `--hook-stage <stage>` : Run hooks for a specific git stage (e.g., `commit`, `push`).

### Notes
- Hooks like `black` and `end-of-file-fixer` will auto-fix issues.
- Linters like `flake8` and `yamllint` will only report issues for you to fix manually.
- You can update hooks to their latest versions with:
  ```sh
  poetry run pre-commit autoupdate
  ```
