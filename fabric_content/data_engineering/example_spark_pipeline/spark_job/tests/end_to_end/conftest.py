import pytest

@pytest.fixture
def test_context():
    """Provides a mutable dictionary for sharing state between pytest-bdd steps in a scenario."""
    return {}
