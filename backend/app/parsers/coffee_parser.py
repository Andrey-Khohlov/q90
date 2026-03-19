import os
import requests
from bs4 import BeautifulSoup
from langchain_mistralai import ChatMistralAI
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import PydanticOutputParser
from pydantic import BaseModel, Field

from app.core.config import settings


# Определяем схему данных с помощью Pydantic
class CoffeeInfo(BaseModel):
    weight: str = Field(description="weight of the package, e.g., '250g', '1lb'")
    price: str = Field(description="price, e.g., '$15.99'")
    country_of_origin: str = Field(description="country where coffee was grown")
    variety: str = Field(description="coffee variety, e.g., 'Arabica', 'Robusta'")
    farmer_name: str = Field(description="name of the farmer or farm")
    farm_address: str = Field(description="address of the farm")


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
parser = PydanticOutputParser(pydantic_object=CoffeeInfo)

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

# Инициализация модели Mistral
# Можно указать конкретную модель, например "mistral-large-latest"
model = ChatMistralAI(
    name="mistral-large-latest",
    temperature=0,  # для детерминированного вывода
    api_key=settings.api_key_mistral,  # или передать напрямую
)

# Строим цепочку
chain = prompt | model | parser

# URL целевой страницы
url = "https://shop.tastycoffee.ru/coffee/rwanda-rugali-anaerobic"

if __name__ == "__main__":

    # Получаем текст страницы
    try:
        page_text = fetch_page_text(url)
        print("Страница загружена, длина текста:", len(page_text))
    except Exception as e:
        print(f"Ошибка при загрузке страницы: {e}")
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
        print("\nИзвлечённые данные:")
        print(result.model_dump_json(indent=2))  # или result.dict()
    except Exception as e:
        print(f"Ошибка при обработке моделью: {e}")
