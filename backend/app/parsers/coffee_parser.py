import json
import asyncio
from pathlib import Path
import httpx
from bs4 import BeautifulSoup
from langchain_mistralai import ChatMistralAI
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import PydanticOutputParser
import logging

from app.parsers.schemas import CoffeeInfo, RawCoffeeData
from app.core.config import settings
from app.core import logging_config

logger = logging.getLogger(__name__)


async def append_json_record_async(record: dict, file_path: Path | str) -> None:
    """Async version of append_json_record using aiofiles pattern."""
    file_path = Path(file_path)
    data = {"coffees": []}

    if file_path.exists():
        loop = asyncio.get_event_loop()
        content = await loop.run_in_executor(
            None, lambda: file_path.read_text(encoding="utf-8")
        )
        try:
            data = json.loads(content)
            if "coffees" not in data:
                data["coffees"] = []
        except json.JSONDecodeError:
            data = {"coffees": []}
    else:
        data = {"coffees": []}

    data["coffees"].append(record)

    loop = asyncio.get_event_loop()
    await loop.run_in_executor(
        None,
        lambda: file_path.write_text(
            json.dumps(data, indent=2, ensure_ascii=False), encoding="utf-8"
        ),
    )


async def fetch_page_text_async(url: str) -> str:
    """Async function to fetch and clean HTML page content."""
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
    }
    async with httpx.AsyncClient() as client:
        response = await client.get(url, headers=headers, timeout=10.0)
        response.raise_for_status()
        soup = BeautifulSoup(response.text, "lxml")

        # Удаляем скрипты и стили, чтобы уменьшить шум
        for script in soup(["script", "style"]):
            script.decompose()

        text = soup.get_text(separator="\n", strip=True)
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


async def parse_coffee(url: str) -> dict:
    """Main async function to parse coffee data from a URL."""
    # Получаем текст страницы
    page_text = await fetch_page_text_async(url)
    logger.debug(f"Страница загружена, длина текста: {len(page_text)}")

    # Вызываем цепочку асинхронно
    result = await chain.ainvoke(
        {
            "page_content": page_text,
            "format_instructions": parser.get_format_instructions(),
        }
    )
    # result — это объект RawCoffeeData
    data = result.model_dump()
    data["coffee_url"] = url
    return data


async def main() -> None:
    """Main entry point for async coffee parsing."""
    try:
        data = await parse_coffee(url)
        json_str = json.dumps(data, indent=2, default=str, ensure_ascii=False)
        print("\nИзвлечённые данные:")
        print(json_str)
        await append_json_record_async(data, Path("app/parsers/parsed_coffees.json"))
        logger.info("Данные успешно сохранены")
    except httpx.HTTPError as e:
        logger.error(f"Ошибка при загрузке страницы: {e}")
    except Exception as e:
        logger.exception(f"Ошибка при обработке моделью: {e}")


if __name__ == "__main__":
    asyncio.run(main())
