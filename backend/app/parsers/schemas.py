from enum import Enum

from pydantic import BaseModel, Field
from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from datetime import datetime


class RoastingLevel(str, Enum):
    DARK = "dark"
    LIGHT = "light"
    MEDIUM = "medium"
    OMNI = "omni"
    MILK = "milk"
    ESPRESSO = "espresso"
    FILTER = "filter"


class RawCoffeeData(BaseModel):
    """
    Модель для данных, извлечённых непосредственно с веб-страницы.
    """

    title: Optional[str] = Field(
        init=None, description="coffee title as is in the text and on the text language"
    )
    description: Optional[str] = Field(
        init=None,
        description="taste and aroma notes description as is in the text and on the text language",
    )
    taste: Optional[str] = Field(
        init=None,
        description="Вкусовые характеристики, во вкусе, Вкусовые ноты, Вкусовые оттенки. Например: Ягоды, Цитрусы, Фрукты, темный виноград, манго, портвейн, нектарин, жёлтый киви, изюм, помело, гречишный мёд",
    )
    roasting_company: Optional[str] = Field(
        init=None,
        description="имя компании-обжарщика (roasting company name), который продаёт этот кофе. Имя обжарщика может быть: в заголовке страницы (<title>), в логотипе или названии сайта, в хлебных крошках (breadcrumbs), в разделе 'О нас' или в контактах, в ссылках на главную страницу, в подвале (footer) с копирайтом.",
    )
    # roasting_company_eng: Optional[str] = Field(
    #     init=None, description="roasting company name in English"
    # )
    price_text: Optional[str] = Field(init=None, description="price, e.g., '800'")
    currency_symbol: Optional[str] = Field(
        init=None, description="price currency symbol, e.g., 'руб', '₽', '€', '$', '£'"
    )
    weight_text: Optional[str] = Field(
        init=None, description="weight of the package, e.g., '250', '200'"
    )
    crop_year_text: Optional[str] = Field(
        init=None, description="crop year e.g., '2025',  '2026"
    )
    crop_month_text: Optional[str] = Field(
        init=None, description="crop month e.g., '01', 'Январь', 'янв','January', 'Jan'"
    )
    roasting_level_text: Optional[RoastingLevel] = Field(
        default=None, description="roasting level"
    )
    species: Optional[str] = Field(
        init=None, description="coffee species, e.g., 'Arabica', 'Robusta'"
    )
    variety_names: Optional[List[str]] = Field(
        default_factory=list,
        description="coffee variety, e.g., 'Typica',  'Bourbon',  'Caturra', 'Geisha', 'SL28'",
    )
    process_text: Optional[str] = None
    farm_name: Optional[str] = None
    farm_adress: Optional[str] = Field(
        default=None, description="farm adress (country, region and so on)"
    )
    height_min: Optional[str] = Field(
        default=None, description="the height of the coffee growth, minimum value"
    )
    height_max: Optional[str] = Field(
        default=None, description="the height of the coffee growth, maximum value"
    )
    exporter_name: Optional[str] = None
    importer_name: Optional[str] = None
    q_grade_text: Optional[str] = None
    pack_image_url: Optional[str] = Field(
        default=None,
        description="packaging image url adress .webp'",
    )


class CoffeeInfo(BaseModel):
    weight: str = Field(description="weight of the package, e.g., '250g', '200g'")
    price: str = Field(description="price, e.g., '800 руб'")
    country_of_origin: str = Field(description="country where coffee was grown")
    variety: str = Field(description="coffee variety, e.g., 'Arabica', 'Robusta'")
    farmer_name: str = Field(description="name of the farmer")
    farm_address: str = Field(description="address of the farm")
