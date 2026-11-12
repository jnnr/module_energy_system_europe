"""Shared pytest fixtures."""

from pathlib import Path

import pytest


@pytest.fixture(scope="session")
def user_path() -> Path:
    """Download and unzip test files."""
    user_dir = Path("resources/user/")

    return user_dir


@pytest.fixture(scope="session")
def module_path():
    """Parent directory of the project."""
    # If your module needs files in resources/user/, place automated downloads here.
    return Path(__file__).parent.parent
