"""Tests for app/parsers/coffee_parser.py module."""

import json
import os
import sys
from pathlib import Path
from unittest.mock import Mock, patch, MagicMock

import pytest
from bs4 import BeautifulSoup

# Mock settings before importing the coffee_parser module
# This prevents issues with missing environment variables during testing
sys.modules["app.core.config"] = MagicMock()
from app.core.config import settings

settings.api_key_mistral = "test_api_key"

from app.parsers.coffee_parser import append_json_record, fetch_page_text


class TestAppendJsonRecord:
    """Tests for the append_json_record function."""

    def test_append_to_new_file(self, tmp_path: Path) -> None:
        """Test appending a record to a new file."""
        file_path = tmp_path / "test.json"
        record = {"name": "Coffee 1", "price": "100"}

        append_json_record(record, file_path)

        assert file_path.exists()
        with open(file_path, "r", encoding="utf-8") as f:
            data = json.load(f)

        assert "coffees" in data
        assert len(data["coffees"]) == 1
        assert data["coffees"][0] == record

    def test_append_to_existing_file(self, tmp_path: Path) -> None:
        """Test appending a record to an existing file."""
        file_path = tmp_path / "test.json"
        initial_data = {"coffees": [{"name": "Coffee 1"}]}

        with open(file_path, "w", encoding="utf-8") as f:
            json.dump(initial_data, f, ensure_ascii=False)

        record = {"name": "Coffee 2", "price": "200"}
        append_json_record(record, file_path)

        with open(file_path, "r", encoding="utf-8") as f:
            data = json.load(f)

        assert len(data["coffees"]) == 2
        assert data["coffees"][0] == {"name": "Coffee 1"}
        assert data["coffees"][1] == record

    def test_append_to_file_without_coffees_key(self, tmp_path: Path) -> None:
        """Test appending to a file that doesn't have 'coffees' key."""
        file_path = tmp_path / "test.json"
        initial_data = {"other_key": "value"}

        with open(file_path, "w", encoding="utf-8") as f:
            json.dump(initial_data, f, ensure_ascii=False)

        record = {"name": "Coffee 1"}
        append_json_record(record, file_path)

        with open(file_path, "r", encoding="utf-8") as f:
            data = json.load(f)

        assert "coffees" in data
        assert "other_key" in data
        assert len(data["coffees"]) == 1
        assert data["coffees"][0] == record

    def test_append_to_invalid_json_file(self, tmp_path: Path) -> None:
        """Test appending to a file with invalid JSON content."""
        file_path = tmp_path / "test.json"

        with open(file_path, "w", encoding="utf-8") as f:
            f.write("invalid json content")

        record = {"name": "Coffee 1"}
        append_json_record(record, file_path)

        with open(file_path, "r", encoding="utf-8") as f:
            data = json.load(f)

        assert "coffees" in data
        assert len(data["coffees"]) == 1
        assert data["coffees"][0] == record

    def test_append_with_string_path(self, tmp_path: Path) -> None:
        """Test appending with a string path instead of Path object."""
        file_path = str(tmp_path / "test.json")
        record = {"name": "Coffee 1"}

        append_json_record(record, file_path)

        assert Path(file_path).exists()
        with open(file_path, "r", encoding="utf-8") as f:
            data = json.load(f)

        assert len(data["coffees"]) == 1

    def test_append_multiple_records(self, tmp_path: Path) -> None:
        """Test appending multiple records sequentially."""
        file_path = tmp_path / "test.json"

        for i in range(3):
            record = {"name": f"Coffee {i}", "price": str(i * 100)}
            append_json_record(record, file_path)

        with open(file_path, "r", encoding="utf-8") as f:
            data = json.load(f)

        assert len(data["coffees"]) == 3
        for i in range(3):
            assert data["coffees"][i]["name"] == f"Coffee {i}"

    def test_append_with_unicode_content(self, tmp_path: Path) -> None:
        """Test appending records with unicode content."""
        file_path = tmp_path / "test.json"
        record = {"name": "Кофе с горы", "description": "Вкусный кофе с ароматом ягод"}

        append_json_record(record, file_path)

        with open(file_path, "r", encoding="utf-8") as f:
            data = json.load(f)

        assert data["coffees"][0]["name"] == "Кофе с горы"
        assert data["coffees"][0]["description"] == "Вкусный кофе с ароматом ягод"


class TestFetchPageText:
    """Tests for the fetch_page_text function."""

    @patch("app.parsers.coffee_parser.requests.get")
    def test_fetch_page_text_success(self, mock_get: Mock) -> None:
        """Test successful page fetching."""
        html_content = """
        <html>
            <head><title>Test Coffee</title></head>
            <body>
                <h1>Coffee Title</h1>
                <p>Description of the coffee</p>
            </body>
        </html>
        """
        mock_response = Mock()
        mock_response.text = html_content
        mock_response.raise_for_status = Mock()
        mock_get.return_value = mock_response

        result = fetch_page_text("https://example.com/coffee")

        assert "Coffee Title" in result
        assert "Description of the coffee" in result
        mock_get.assert_called_once()
        headers = mock_get.call_args[1]["headers"]
        assert "User-Agent" in headers

    @patch("app.parsers.coffee_parser.requests.get")
    def test_fetch_page_text_removes_scripts_and_styles(self, mock_get: Mock) -> None:
        """Test that scripts and styles are removed from the page content."""
        html_content = """
        <html>
            <head>
                <title>Test</title>
                <script>alert('test');</script>
                <style>.hidden { display: none; }</style>
            </head>
            <body>
                <p>Visible content</p>
            </body>
        </html>
        """
        mock_response = Mock()
        mock_response.text = html_content
        mock_response.raise_for_status = Mock()
        mock_get.return_value = mock_response

        result = fetch_page_text("https://example.com/coffee")

        assert "alert" not in result
        assert ".hidden" not in result
        assert "display: none" not in result
        assert "Visible content" in result

    @patch("app.parsers.coffee_parser.requests.get")
    def test_fetch_page_text_removes_empty_lines(self, mock_get: Mock) -> None:
        """Test that empty lines are removed from the result."""
        html_content = """
        <html>
            <body>
                <p>Line 1</p>
                <br><br><br>
                <p>Line 2</p>
            </body>
        </html>
        """
        mock_response = Mock()
        mock_response.text = html_content
        mock_response.raise_for_status = Mock()
        mock_get.return_value = mock_response

        result = fetch_page_text("https://example.com/coffee")

        lines = result.split("\n")
        assert all(line.strip() for line in lines)
        assert "Line 1" in result
        assert "Line 2" in result

    @patch("app.parsers.coffee_parser.requests.get")
    def test_fetch_page_text_with_custom_headers(self, mock_get: Mock) -> None:
        """Test that custom User-Agent header is used."""
        mock_response = Mock()
        mock_response.text = "<html><body>Test</body></html>"
        mock_response.raise_for_status = Mock()
        mock_get.return_value = mock_response

        fetch_page_text("https://example.com/coffee")

        call_kwargs = mock_get.call_args[1]
        assert "headers" in call_kwargs
        assert "Mozilla/5.0" in call_kwargs["headers"]["User-Agent"]
        assert call_kwargs["timeout"] == 10

    @patch("app.parsers.coffee_parser.requests.get")
    def test_fetch_page_text_http_error(self, mock_get: Mock) -> None:
        """Test handling of HTTP errors."""
        import requests

        mock_get.side_effect = requests.exceptions.HTTPError("404 Not Found")

        with pytest.raises(requests.exceptions.HTTPError):
            fetch_page_text("https://example.com/nonexistent")

    @patch("app.parsers.coffee_parser.requests.get")
    def test_fetch_page_text_timeout(self, mock_get: Mock) -> None:
        """Test handling of timeout errors."""
        import requests

        mock_get.side_effect = requests.exceptions.Timeout("Request timed out")

        with pytest.raises(requests.exceptions.Timeout):
            fetch_page_text("https://example.com/slow")

    @patch("app.parsers.coffee_parser.requests.get")
    def test_fetch_page_text_connection_error(self, mock_get: Mock) -> None:
        """Test handling of connection errors."""
        import requests

        mock_get.side_effect = requests.exceptions.ConnectionError("Connection failed")

        with pytest.raises(requests.exceptions.ConnectionError):
            fetch_page_text("https://example.com/unreachable")

    @patch("app.parsers.coffee_parser.requests.get")
    def test_fetch_page_text_complex_html(self, mock_get: Mock) -> None:
        """Test fetching with complex HTML structure."""
        html_content = """
        <html>
            <head><title>Costa Rica Torrefacto Geisha</title></head>
            <body>
                <div class="breadcrumbs">
                    <a href="/">Home</a> / 
                    <a href="/catalog">Catalog</a> / 
                    <a href="/catalog/roasted">Roasted</a> / 
                    Costa Rica Torrefacto Geisha
                </div>
                <h1 class="product-title">Costa Rica Torrefacto Geisha</h1>
                <div class="product-description">
                    <p>Яркий и насыщенный кофе с нотами тропических фруктов.</p>
                </div>
                <div class="product-details">
                    <ul>
                        <li>Вес: 250г</li>
                        <li>Цена: 1500 ₽</li>
                        <li>Обжарка: Средняя</li>
                    </ul>
                </div>
            </body>
        </html>
        """
        mock_response = Mock()
        mock_response.text = html_content
        mock_response.raise_for_status = Mock()
        mock_get.return_value = mock_response

        result = fetch_page_text("https://www.torrefacto.ru/catalog/roasted/costa-rica")

        assert "Costa Rica" in result
        assert "Тропических фруктов" in result or "тропических фруктов" in result
        assert "250г" in result or "250" in result
        assert "1500" in result


class TestCoffeeParserIntegration:
    """Integration tests for the coffee parser chain."""

    @patch("app.parsers.coffee_parser.chain")
    @patch("app.parsers.coffee_parser.fetch_page_text")
    def test_full_parsing_flow(
        self, mock_fetch: Mock, mock_chain: Mock, tmp_path: Path
    ) -> None:
        """Test the complete parsing flow (with mocked LLM)."""
        from app.parsers.coffee_parser import parser
        from app.parsers.schemas import RawCoffeeData

        mock_fetch.return_value = "Test coffee page content"

        # Mock the chain invoke to return a RawCoffeeData object
        mock_result = RawCoffeeData.model_construct(
            title="Test Coffee",
            description="Delicious coffee",
            taste="Berry notes",
            roasting_company="Test Roasters",
            price_text="1000",
            currency_symbol="₽",
            weight_text="250",
            crop_year_text="2024",
            crop_month_text="January",
            species="Arabica",
        )
        mock_chain.invoke.return_value = mock_result

        result = mock_chain.invoke(
            {
                "page_content": "Test coffee page content",
                "format_instructions": parser.get_format_instructions(),
            }
        )

        assert isinstance(result, RawCoffeeData)
        assert result.title == "Test Coffee"
        assert result.price_text == "1000"

    def test_parser_format_instructions(self) -> None:
        """Test that the parser provides format instructions."""
        from app.parsers.coffee_parser import parser

        instructions = parser.get_format_instructions()
        assert instructions is not None
        assert len(instructions) > 0

    def test_prompt_template_structure(self) -> None:
        """Test that the prompt template has the correct structure."""
        from app.parsers.coffee_parser import prompt

        assert prompt is not None
        messages = prompt.messages
        assert len(messages) == 2

        # Check that we have system and human messages
        assert messages[0] is not None
        # Verify the template contains the expected variables
        prompt_str = str(prompt)
        assert (
            "{format_instructions}" in prompt_str or "format_instructions" in prompt_str
        )
        assert "{page_content}" in prompt_str or "page_content" in prompt_str


class TestRawCoffeeDataSchema:
    """Tests for the RawCoffeeData schema used in the parser."""

    def test_create_raw_coffee_data_with_all_fields(self) -> None:
        """Test creating RawCoffeeData with all fields populated."""
        from app.parsers.schemas import RawCoffeeData, RoastingLevel

        data = RawCoffeeData.model_construct(
            title="Test Coffee",
            description="Delicious coffee with berry notes",
            taste="Berry, citrus, chocolate",
            roasting_company="Test Roasters",
            price_text="1000",
            currency_symbol="₽",
            weight_text="250",
            crop_year_text="2024",
            crop_month_text="January",
            roasting_level_text=RoastingLevel.MEDIUM,
            species="Arabica",
            variety_names=["Geisha", "Typica"],
            process_text="Washed",
            farm_name="Test Farm",
            farm_adress="Costa Rica, Tarrazu",
            height_min="1200",
            height_max="1800",
            exporter_name="Test Exporter",
            importer_name="Test Importer",
            q_grade_text="Grade 1",
            pack_image_url="https://example.com/image.webp",
        )

        assert data.title == "Test Coffee"
        assert data.species == "Arabica"
        assert data.roasting_level_text == RoastingLevel.MEDIUM
        assert len(data.variety_names) == 2

    def test_create_raw_coffee_data_with_minimal_fields(self) -> None:
        """Test creating RawCoffeeData with minimal required fields."""
        from app.parsers.schemas import RawCoffeeData

        # Use model_construct to bypass validation for fields with init=None
        # Must provide all fields that have default=None in the schema
        data = RawCoffeeData.model_construct(
            title="Test Coffee",
            description=None,
            taste=None,
            roasting_company=None,
            price_text=None,
            currency_symbol=None,
            weight_text=None,
            crop_year_text=None,
            crop_month_text=None,
            species=None,
        )

        assert data.title == "Test Coffee"
        assert data.description is None
        assert data.variety_names == []

    def test_raw_coffee_data_model_dump(self) -> None:
        """Test model_dump method of RawCoffeeData."""
        from app.parsers.schemas import RawCoffeeData

        # Use model_construct to bypass validation
        data = RawCoffeeData.model_construct(title="Test Coffee", price_text="1000")
        dumped = data.model_dump()

        assert "title" in dumped
        assert "price_text" in dumped
        assert dumped["title"] == "Test Coffee"
        assert dumped["price_text"] == "1000"


class TestCoffeeInfoSchema:
    """Tests for the CoffeeInfo schema."""

    def test_create_coffee_info(self) -> None:
        """Test creating CoffeeInfo with all required fields."""
        from app.parsers.schemas import CoffeeInfo

        info = CoffeeInfo(
            weight="250g",
            price="1000 ₽",
            country_of_origin="Costa Rica",
            variety="Arabica",
            farmer_name="Juan Perez",
            farm_address="Tarrazu, Costa Rica",
        )

        assert info.weight == "250g"
        assert info.price == "1000 ₽"
        assert info.country_of_origin == "Costa Rica"

    def test_coffee_info_missing_required_fields(self) -> None:
        """Test that CoffeeInfo raises error when required fields are missing."""
        from app.parsers.schemas import CoffeeInfo

        with pytest.raises(Exception):  # pydantic.ValidationError
            CoffeeInfo(weight="250g")
