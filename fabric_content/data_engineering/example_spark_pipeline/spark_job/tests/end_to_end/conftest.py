import pytest
from typing import Any


def pytest_bdd_after_step(
    request: Any, feature: Any, scenario: Any, step: Any, step_func: Any, step_func_args: Any
) -> None:
    """Hook to print a message after the BDD step completes."""
    print(f"✅ {step.keyword} {step.name}")


def pytest_bdd_step_error(
    request: Any, feature: Any, scenario: Any, step: Any, step_func: Any, step_func_args: Any, exception: Exception
) -> None:
    """Hook to print a message if the BDD step fails."""
    print(f"❌ {step.keyword} {step.name}\n{exception}")


@pytest.fixture
def test_context() -> dict:
    """Provides a mutable dictionary for sharing state between pytest-bdd steps in a scenario."""
    return {}
