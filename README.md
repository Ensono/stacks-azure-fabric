# Stacks Azure Fabric

This repo holds the infrastructure and code required for deploying Azure Fabric according to the Ensono Stacks framework.

## Code quality checks

This project uses [pre-commit](https://pre-commit.com/) to automate code quality checks and formatting.

The checks for the project are defined in [.pre-commit-config.yaml](/.pre-commit-config.yaml).

[Make commands](./Makefile) have been provided to simplify setup and usage.

### Pre-commit setup

To ensure pre-commit checks run automatically on every `git commit`, you must install the git hooks after cloning the repository:

1. Install the `pre-commit` CLI (if not already installed):

   ```sh
   pip install --user pre-commit
   ```

2. Install the Git hooks (from the root of the repo):

   ```sh
   make pre-commit-install
   ```

You only need to do this once. After that, pre-commit will run automatically on every commit.

### Run pre-commit checks manually

You can run pre-commit hooks manually at any time:

- **Run hooks only on staged files**:

  ```sh
  make pre-commit-run
  ```

- **Run all hooks on all files** (useful after updating hooks or dependencies):

  ```sh
  make pre-commit-all
  ```

### Updating Hook Versions

To update pre-commit hooks to their latest versions (defined in `.pre-commit-config.yaml`):

```sh
make pre-commit-update
```

Then commit any changes made to the config file.

### Notes

- Hooks like `black` and `end-of-file-fixer` will auto-fix issues.
- Linters like `flake8` and `yamllint` will only report issues for you to fix manually.
