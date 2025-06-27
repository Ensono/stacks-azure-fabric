## -------------------------------
## Pre-commit Hooks
## -------------------------------

.PHONY: pre-commit-install pre-commit-run pre-commit-all pre-commit-update

pre-commit-install:
	@echo "Installing pre-commit hooks..."
	pre-commit install

pre-commit-run:
	@echo "Running pre-commit on staged files..."
	pre-commit run

pre-commit-all:
	@echo "Running all pre-commit hooks on all files..."
	pre-commit run --all-files

pre-commit-update:
	@echo "Updating pre-commit hook versions..."
	pre-commit autoupdate
