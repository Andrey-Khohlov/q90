import json
import os
from pathlib import Path
import requests
from bs4 import BeautifulSoup
from langchain_mistralai import ChatMistralAI
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import PydanticOutputParser
import logging

from app.parsers.schemas import CoffeeInfo, RawCoffeeData
from app.core.config import settings
from app.core import logging_config

logger = logging.getLogger(__name__)


def append_json_record(record: dict, file_path: Path | str) -> None:
    file_path = Path(file_path)
    if file_path.exists():
        with open(file_path, "r", encoding="utf-8") as f:
            try:
                data = json.load(f)
            except json.JSONDecodeError:
                data = {}
    else:
        data = {}

    if "coffees" not in data:
        data["coffees"] = []
    data["coffees"].append(record)

    with open(file_path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)


# Функция для загрузки и очистки HTML страницы
def fetch_page_text(url: str) -> str:
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
    }
    response = requests.get(url, headers=headers, timeout=10)
    response.raise_for_status()
    soup = BeautifulSoup(response.text, "lxml")

    # Удаляем скрипты и стили, чтобы уменьшить шум
    for script in soup(["script", "style"]):
        script.decompose()

    text = soup.get_text(separator="\n", strip=True)
    # Можно дополнительно очистить пустые строки
    lines = [line.strip() for line in text.splitlines() if line.strip()]
    return "\n".join(lines)


# Создаём парсер Pydantic
parser = PydanticOutputParser(pydantic_object=RawCoffeeData)

# Промпт для модели
prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "You are an expert at extracting structured information from web page text. "
            "Extract the following details about a coffee product from the provided text.\n"
            "{format_instructions}",
        ),
        ("human", "Here is the page content:\n\n{page_content}"),
    ]
)


model = ChatMistralAI(
    name="mistral-large-latest",
    temperature=0,
    api_key=settings.api_key_mistral,
)

# Строим цепочку
chain = prompt | model | parser

# URL целевой страницы
url = "https://www.torrefacto.ru/catalog/roasted/costa-rica-torrefacto-geisha/"

if __name__ == "__main__":

    # Получаем текст страницы
    try:
        page_text = fetch_page_text(url)
        logger.debug(f"Страница загружена, длина текста: {len(page_text)}")
    except Exception as e:
        logger.error(f"Ошибка при загрузке страницы: {e}")
        exit(1)

    # Вызываем цепочку
    try:
        result = chain.invoke(
            {
                "page_content": page_text,
                "format_instructions": parser.get_format_instructions(),
            }
        )
        # result — это объект CoffeeInfo
        data = result.model_dump()
        data["coffee_url"] = url
        json_str = json.dumps(data, indent=2, default=str, ensure_ascii=False)
        print("\nИзвлечённые данные:")
        print(json_str)
        append_json_record(data, Path("app/parsers/parsed_coffees.json"))

    except Exception as e:
        logger.exception(f"Ошибка при обработке моделью: {e}")
