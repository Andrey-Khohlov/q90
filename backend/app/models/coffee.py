from datetime import datetime
from decimal import Decimal
from typing import Optional, List
from pydantic import BaseModel, ConfigDict, Field, field_validator

# ------------------------------------------------------------------
# Базовые модели с общими аудит-полями
# ------------------------------------------------------------------


class AuditFields(BaseModel):
    """Общие поля аудита для всех таблиц."""

    created_at: datetime
    created_by: int
    updated_at: Optional[datetime] = None
    updated_by: Optional[int] = None
    deleted_at: Optional[datetime] = None
    deleted_by: Optional[int] = None


class AuditFieldsCreate(BaseModel):
    """Поля, которые можно не передавать при создании (устанавливаются БД или сервером)."""

    created_by: int
    updated_by: Optional[int] = None
    deleted_by: Optional[int] = None


# ------------------------------------------------------------------
# Модели для таблицы varieties
# ------------------------------------------------------------------


class VarietyBase(BaseModel):
    variety: str = Field(..., max_length=100, description="Название сорта")
    species: str = Field(
        ..., max_length=100, description="Вид (arabica, robusta и т.д.)"
    )
    taste_description: Optional[str] = Field(None, description="Описание вкуса")
    history: Optional[str] = Field(None, description="История сорта")
    origin_type: str = Field(
        ..., max_length=20, description="Тип происхождения (natural, hybrid и т.п.)"
    )


class VarietyCreate(VarietyBase, AuditFieldsCreate):
    pass


class VarietyUpdate(BaseModel):
    variety: Optional[str] = Field(None, max_length=100)
    species: Optional[str] = Field(None, max_length=100)
    taste_description: Optional[str] = None
    history: Optional[str] = None
    origin_type: Optional[str] = Field(None, max_length=20)
    updated_by: Optional[int] = None


class VarietyResponse(VarietyBase, AuditFields):
    variety_id: int

    model_config = ConfigDict(from_attributes=True)


# ------------------------------------------------------------------
# Модели для таблицы variety_parents (связь сортов с предками)
# ------------------------------------------------------------------


class VarietyParentBase(BaseModel):
    variety_id: int
    parent_id: int
    parent_role: str = Field(
        ..., max_length=20, description="Роль родителя (parent, hybrid, etc.)"
    )
    notes: Optional[str] = None


class VarietyParentCreate(VarietyParentBase, AuditFieldsCreate):
    pass


class VarietyParentUpdate(BaseModel):
    parent_role: Optional[str] = Field(None, max_length=20)
    notes: Optional[str] = None
    updated_by: Optional[int] = None


class VarietyParentResponse(VarietyParentBase, AuditFields):
    model_config = ConfigDict(from_attributes=True)


# ------------------------------------------------------------------
# Модели для таблицы green_beans (партии зеленого зерна)
# ------------------------------------------------------------------


class GreenBeansBase(BaseModel):
    farm_id: Optional[int] = Field(None, description="ID фермы (организации)")
    variety_id: Optional[int] = Field(None, description="ID сорта")
    mix: bool = Field(False, description="Микс разных сортов?")
    process: str = Field(..., max_length=100, description="Процесс обработки")
    height_min: Optional[int] = Field(
        None, ge=0, le=10000, description="Минимальная высота произрастания"
    )
    height_max: Optional[int] = Field(
        None, ge=0, le=10000, description="Максимальная высота"
    )
    description: Optional[str] = None
    followers: int = Field(0, description="Количество подписчиков")


class GreenBeansCreate(GreenBeansBase, AuditFieldsCreate):
    pass


class GreenBeansUpdate(BaseModel):
    farm_id: Optional[int] = None
    variety_id: Optional[int] = None
    mix: Optional[bool] = None
    process: Optional[str] = Field(None, max_length=100)
    height_min: Optional[int] = Field(None, ge=0, le=10000)
    height_max: Optional[int] = Field(None, ge=0, le=10000)
    description: Optional[str] = None
    followers: Optional[int] = None
    updated_by: Optional[int] = None


class GreenBeansResponse(GreenBeansBase, AuditFields):
    beans_id: int

    model_config = ConfigDict(from_attributes=True)


# ------------------------------------------------------------------
# Модели для таблицы coffees (обжаренный кофе)
# ------------------------------------------------------------------


class CoffeeBase(BaseModel):
    green_bean_id: int
    crop_year: int = Field(..., ge=1900, le=2100, description="Год урожая")
    crop_month: int = Field(..., ge=1, le=12, description="Месяц урожая")
    exporter_id: Optional[int] = None
    importer_id: Optional[int] = None
    roaster_id: int
    roasting_level: str = Field(..., max_length=100, description="Степень обжарки")
    price: Optional[int] = Field(
        None, ge=0, description="Цена (в минимальных единицах валюты)"
    )
    weight: Optional[int] = Field(None, ge=0, description="Вес упаковки (граммы?)")
    currency: str = Field(
        ..., min_length=3, max_length=3, description="Код валюты (ISO 4217)"
    )
    title: str = Field(..., max_length=300)
    description: Optional[str] = None
    q_grade: Optional[Decimal] = Field(
        None, ge=0, le=100, decimal_places=1, description="Q-оценка"
    )
    pack_image: Optional[bytes] = Field(
        None, description="Изображение упаковки (бинарные данные)"
    )
    pack_url: Optional[str] = Field(None, max_length=500)
    url: Optional[str] = Field(None, max_length=500)

    # Валидация для q_grade: ограничение на один знак после запятой
    @field_validator("q_grade")
    def validate_q_grade(cls, v):
        if v is not None and v.as_tuple().exponent < -1:
            raise ValueError("q_grade must have at most one decimal place")
        return v


class CoffeeCreate(CoffeeBase, AuditFieldsCreate):
    avg_rating: Optional[Decimal] = Field(None, ge=0, le=5, decimal_places=2)
    ratings_count: int = 0
    reviews_count: int = 0
    comments_count: int = 0

    @field_validator("avg_rating")
    def validate_avg_rating(cls, v):
        if v is not None and v.as_tuple().exponent < -2:
            raise ValueError("avg_rating must have at most two decimal places")
        return v


class CoffeeUpdate(BaseModel):
    green_bean_id: Optional[int] = None
    crop_year: Optional[int] = Field(None, ge=1900, le=2100)
    crop_month: Optional[int] = Field(None, ge=1, le=12)
    exporter_id: Optional[int] = None
    importer_id: Optional[int] = None
    roaster_id: Optional[int] = None
    roasting_level: Optional[str] = Field(None, max_length=100)
    price: Optional[int] = Field(None, ge=0)
    weight: Optional[int] = Field(None, ge=0)
    currency: Optional[str] = Field(None, min_length=3, max_length=3)
    title: Optional[str] = Field(None, max_length=300)
    description: Optional[str] = None
    q_grade: Optional[Decimal] = Field(None, ge=0, le=100)
    pack_image: Optional[bytes] = None
    pack_url: Optional[str] = Field(None, max_length=500)
    url: Optional[str] = Field(None, max_length=500)
    avg_rating: Optional[Decimal] = Field(None, ge=0, le=5)
    ratings_count: Optional[int] = Field(None, ge=0)
    reviews_count: Optional[int] = Field(None, ge=0)
    comments_count: Optional[int] = Field(None, ge=0)
    updated_by: Optional[int] = None

    @field_validator("q_grade")
    def validate_q_grade(cls, v):
        if v is not None and v.as_tuple().exponent < -1:
            raise ValueError("q_grade must have at most one decimal place")
        return v

    @field_validator("avg_rating")
    def validate_avg_rating(cls, v):
        if v is not None and v.as_tuple().exponent < -2:
            raise ValueError("avg_rating must have at most two decimal places")
        return v


class CoffeeResponse(CoffeeBase, AuditFields):
    coffee_id: int
    avg_rating: Optional[Decimal] = Field(None, ge=0, le=5)
    ratings_count: int
    reviews_count: int
    comments_count: int

    model_config = ConfigDict(from_attributes=True)


# ------------------------------------------------------------------
# При необходимости можно добавить модели для списков (например, для пагинации)
# ------------------------------------------------------------------


class VarietyListResponse(BaseModel):
    items: List[VarietyResponse]
    total: int


class GreenBeansListResponse(BaseModel):
    items: List[GreenBeansResponse]
    total: int


class CoffeeListResponse(BaseModel):
    items: List[CoffeeResponse]
    total: int
