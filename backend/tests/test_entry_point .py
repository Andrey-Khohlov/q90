"""
Main test entry point for the backend project.
"""

import sys

from typing import Any


class TestBasicFunctionality:
    """Test basic application functionality and configuration."""

    def test_executable_path(self) -> None:
        """Должен показать путь к backend/.venv/bin/python"""
        assert "/home/xgb/projects/q90/backend/.venv/bin/python" in sys.executable

    def test_imports_successful(self) -> None:
        """Verify that core modules can be imported without errors."""
        from app import database
        from app import main

        assert database is not None
        assert main is not None

    def test_environment_configuration(self) -> None:
        """Test that environment configuration is properly loaded."""
        from pathlib import Path

        env_file = Path(__file__).parent.parent / ".env"
        assert env_file.exists(), ".env file should exist"

    def test_python_version(self) -> None:
        """Verify Python version meets minimum requirements."""
        import sys

        assert sys.version_info >= (3, 13), "Python 3.13+ is required"
