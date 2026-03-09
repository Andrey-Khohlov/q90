# Локализация 
### ДО локализации
Гео, фермы, сорта: храните в оригинальном/английском написании. 
FlavourWeel и гео надо сразу локализовать
Блок Community и Roaster на русском
### Отдельные таблицы переводов 
Используйте отдельные таблицы *_translations для каждой сущности с переводимыми полями. Это масштабируемо и эффективно.

Для серьёзного проекта с множеством языков и необходимостью фильтрации/поиска по переведённым полям — однозначно таблицы переводов.

Самый гибкий способ — создать для каждой переводимой сущности отдельную таблицу переводов.

**Пример для таблицы coffees:**

```sql
-- Основная таблица содержит только неизменяемые поля и поля, не требующие перевода
CREATE TABLE coffees (
    coffee_id BIGSERIAL PRIMARY KEY,
    roaster_id BIGINT REFERENCES roasters(roaster_id),
    green_bean_id BIGINT REFERENCES green_beans(beans_id),
    price DECIMAL(10,2),
    currency_code CHAR(3) REFERENCES currencies(currency_code),
    -- технические поля
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    -- поля, не требующие перевода: рейтинги, год урожая и т.п.
    crop_year SMALLINT,
    -- ... остальные поля, кроме переводимых
);

-- Таблица переводов для кофе
CREATE TABLE coffee_translations (
    coffee_id BIGINT REFERENCES coffees(coffee_id) ON DELETE CASCADE,
    locale CHAR(2) NOT NULL,  -- 'ru', 'en', 'es' и т.д.
    title VARCHAR(300) NOT NULL,
    description TEXT,
    -- можно добавить другие переводимые поля
    taste_notes TEXT,
    PRIMARY KEY (coffee_id, locale)
);
```
Аналогично для других сущностей:

variety_translations (variety_id, locale, name, taste_description, history)

farm_translations (farm_id, locale, name, story)

roaster_translations (roaster_id, locale, name, about)

и т.д.

### Преимущества:

Чистая нормализация

Легко добавлять новые языки

Можно делать поиск по переведённым полям с учётом языка

Эффективные индексы

### Недостатки:

Увеличивается количество таблиц

Для получения полной сущности нужен JOIN