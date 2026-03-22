"""
Main test entry point for the backend project.

This module demonstrates proper pytest conventions:
- Descriptive test module docstrings
- Test classes with clear naming (Test* prefix)
- Test methods with descriptive names (test_*_prefix)
- Type hints for better IDE support
- Proper use of fixtures and mocks
- AAA pattern (Arrange-Act-Assert) in test structure
"""

import sys

import pytest
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


class TestDataStructures:
    """Test data structures and type definitions."""

    def test_dictionary_operations(self) -> None:
        """Test basic dictionary operations with proper assertions."""
        # Arrange
        data: dict[str, int] = {"a": 1, "b": 2, "c": 3, "d": 4}

        # Act
        result = data.get("a")

        # Assert
        assert result == 1
        assert "a" in data
        assert len(data) == 4

    def test_class_initialization(self) -> None:
        """Test class initialization with proper parameter validation."""
        # Arrange & Act
        test_obj = SampleDataClass(a=1, b=2)

        # Assert
        assert test_obj.a == 1
        assert test_obj.b == 2
        assert isinstance(test_obj.aa, dict)

    def test_class_nested_data_access(self) -> None:
        """Test accessing nested data structures within class instances."""
        # Arrange
        test_obj = SampleDataClass(a=1, b=2)

        # Act
        value = test_obj.aa.get("a")

        # Assert
        assert value == "apple"
        assert len(test_obj.aa) == 5

    def test_class_with_invalid_parameters(self) -> None:
        """Test that class handles invalid parameters appropriately."""
        # Arrange & Act
        test_obj = SampleDataClass(a="string", b=["list"])

        # Assert - should handle any type as per current implementation
        assert test_obj.a == "string"
        assert test_obj.b == ["list"]


class TestEdgeCases:
    """Test edge cases and boundary conditions."""

    def test_empty_dictionary(self) -> None:
        """Test behavior with empty dictionary."""
        # Arrange
        empty: dict[str, Any] = {}

        # Assert
        assert len(empty) == 0
        assert empty.get("nonexistent") is None

    def test_none_values(self) -> None:
        """Test handling of None values."""
        # Arrange
        data: dict[str, Any] = {"key": None}

        # Assert
        assert "key" in data
        assert data["key"] is None

    def test_special_characters_in_strings(self) -> None:
        """Test handling of special characters in string values."""
        # Arrange
        test_string = "asdf;ljsdf;lkajsfd;lasdjf;asldkfja;sdlfk"

        # Assert
        assert len(test_string) > 0
        assert isinstance(test_string, str)


class TestIntegration:
    """Integration tests for verifying component interactions."""

    def test_test_class_integration(self) -> None:
        """Test that SampleDataClass integrates properly with test framework."""
        # Arrange
        expected_keys = {"a", "b", "c", "d", "e"}

        # Act
        test_obj = SampleDataClass(a=1, b=2)
        actual_keys = set(test_obj.aa.keys())

        # Assert
        assert actual_keys == expected_keys

    def test_multiple_instances_independence(self) -> None:
        """Test that multiple instances are independent."""
        # Arrange
        obj1 = SampleDataClass(a=1, b=2)
        obj2 = SampleDataClass(a=10, b=20)

        # Assert
        assert obj1.a != obj2.a
        assert obj1.b != obj2.b


class SampleDataClass:
    """Sample class for testing purposes."""

    def __init__(self, a: Any, b: Any) -> None:
        """Initialize SampleDataClass with parameters.

        Args:
            a: First parameter (any type)
            b: Second parameter (any type)
        """
        self.a = a
        self.b = b
        self.aa: dict[str, Any] = {
            "a": "apple",
            "b": "bottom",
            "c": "current",
            "d": "drop out",
            "e": "asdf;ljsdf;lkajsfd;lasdjf;asldkfja;sdlfk",
        }


# Pytest hooks and configuration
def pytest_configure(config: pytest.Config) -> None:
    """Configure pytest with custom markers.

    Args:
        config: Pytest configuration object
    """
    # Register custom markers
    config.addinivalue_line(
        "markers", "slow: marks tests as slow (deselect with '-m \"not slow\"')"
    )
    config.addinivalue_line("markers", "integration: marks tests as integration tests")
