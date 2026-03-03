## 📋 Полный справочник типов данных для схемы БД

### 🌍 География и локации

**`world_parts`** (части света)
| Атрибут | Тип | Ограничения | Описание |
|---------|-----|-------------|----------|
| `world_part_id` | `SMALLINT` | `PRIMARY KEY` | ID части света |
| `name` | `VARCHAR(50)` | `NOT NULL UNIQUE` | Название (Европа, Африка...) |

**`countries`**
| Атрибут | Тип | Ограничения | Описание |
|---------|-----|-------------|----------|
| `country_code` | `CHAR(2)` | `PRIMARY KEY` | ISO 3166-1 alpha-2 (RU, BR) |
| `country` | `VARCHAR(100)` | `NOT NULL` | Полное название страны |
| `world_part_id` | `SMALLINT` | `FOREIGN KEY REFERENCES world_parts(world_part_id)` | Часть света |
| `is_coffee_growing` | `BOOLEAN` | `DEFAULT FALSE` | Производит ли кофе |

**`regions`** (регионы/штаты)
| Атрибут | Тип | Ограничения | Описание |
|---------|-----|-------------|----------|
| `region_id` | `SMALLINT` | `PRIMARY KEY` | ID региона |
| `region` | `VARCHAR(100)` | `NOT NULL` | Название региона |
| `country_code` | `CHAR(2)` | `FOREIGN KEY REFERENCES countries(country_code)` | Страна |

**`localities`** (районы/местности)
| Атрибут | Тип | Ограничения | Описание |
|---------|-----|-------------|----------|
| `locality_id` | `INTEGER` | `PRIMARY KEY` | ID местности |
| `locality` | `VARCHAR(100)` | `NOT NULL` | Название местности |
| `region_id` | `SMALLINT` | `FOREIGN KEY REFERENCES regions(region_id)` | Регион |

**`cities`**
| Атрибут | Тип | Ограничения | Описание |
|---------|-----|-------------|----------|
| `city_id` | `INTEGER` | `PRIMARY KEY` | ID города |
| `city` | `VARCHAR(100)` | `NOT NULL` | Название города |
| `locality_id` | `INTEGER` | `FOREIGN KEY REFERENCES localities(locality_id)` | Местность |
| `country_code` | `CHAR(2)` | `FOREIGN KEY REFERENCES countries(country_code)` | Страна (дублирование для быстрых запросов) |

### 🏭 Производители и поставщики

**`farms`** (фермы)
| Атрибут | Тип | Ограничения | Описание |
|---------|-----|-------------|----------|
| `farm_id` | `BIGSERIAL` | `PRIMARY KEY` | ID фермы |
| `farm` | `VARCHAR(200)` | `NOT NULL` | Название фермы |
| `locality_id` | `INTEGER` | `FOREIGN KEY REFERENCES localities(locality_id)` | Местоположение |
| `mill` | `VARCHAR(200)` | | Мельница/станция обработки |
| `cooperative` | `VARCHAR(200)` | | Кооператив |
| `owner` | `VARCHAR(200)` | | Владелец |
| `coordinates` | `POINT` | | Геокоординаты |
| `story` | `TEXT` | | История фермы |
| `internet_site` | `VARCHAR(500)` | | Сайт |
| `phone` | `VARCHAR(30)` | | Телефон |
| `followers` | `INTEGER` | `DEFAULT 0` | Количество подписчиков (денормализовано) |

**`exporters`**
| Атрибут | Тип | Ограничения | Описание |
|---------|-----|-------------|----------|
| `exporter_id` | `BIGSERIAL` | `PRIMARY KEY` | ID экспортёра |
| `exporter` | `VARCHAR(200)` | `NOT NULL` | Название компании |
| `internet_site` | `VARCHAR(500)` | | Сайт |
| `about` | `TEXT` | | Описание |

**`importers`**
| Атрибут | Тип | Ограничения | Описание |
|---------|-----|-------------|----------|
| `importer_id` | `BIGSERIAL` | `PRIMARY KEY` | ID импортёра |
| `importer` | `VARCHAR(200)` | `NOT NULL` | Название компании |
| `internet_site` | `VARCHAR(500)` | | Сайт |
| `about` | `TEXT` | | Описание |

**`roasters`** (обжарщики)
| Атрибут | Тип | Ограничения | Описание |
|---------|-----|-------------|----------|
| `roaster_id` | `BIGSERIAL` | `PRIMARY KEY` | ID обжарщика |
| `roaster` | `VARCHAR(200)` | `NOT NULL` | Название |
| `city_id` | `INTEGER` | `FOREIGN KEY REFERENCES cities(city_id)` | Город |
| `internet_site` | `VARCHAR(500)` | | Сайт |
| `rating_spro` | `DECIMAL(3,2)` | | Рейтинг за эспрессо |
| `rating_filter` | `DECIMAL(3,2)` | | Рейтинг за фильтр |
| `about` | `TEXT` | | Описание |
| `market_vol` | `SMALLINT` | | Объем рынка (тонн) |
| `avrg_self_Q` | `DECIMAL(3,2)` | | Средняя самооценка Q |
| `followers` | `INTEGER` | `DEFAULT 0` | Количество подписчиков |

### 🌱 Сорта и виды кофе

**`varieties`** (сорта)
| Атрибут | Тип | Ограничения | Описание |
|---------|-----|-------------|----------|
| `variety_id` | `INTEGER` | `PRIMARY KEY` | ID сорта |
| `variety` | `VARCHAR(100)` | `NOT NULL UNIQUE` | Название сорта |
| `species` | `VARCHAR(100)` | `NOT NULL` | Вид (arabica, robusta, liberica) |
| `taste_description` | `TEXT` | | Описание вкуса |
| `history` | `TEXT` | | История сорта |
| `parent_1_id` | `INTEGER` | `FOREIGN KEY REFERENCES varieties(variety_id)` | Первый родительский сорт |
| `parent_2_id` | `INTEGER` | `FOREIGN KEY REFERENCES varieties(variety_id)` | Второй родительский сорт |

**`green_beans`** (партии зеленого зерна)
| Атрибут | Тип | Ограничения | Описание |
|---------|-----|-------------|----------|
| `beans_id` | `BIGSERIAL` | `PRIMARY KEY` | ID партии |
| `farm_id` | `BIGINT` | `FOREIGN KEY REFERENCES farms(farm_id)` | Ферма |
| `variety_id` | `INTEGER` | `FOREIGN KEY REFERENCES varieties(variety_id)` | Сорт |
| `mix` | `BOOLEAN` | `DEFAULT FALSE` | Микс сортов? |
| `process` | `VARCHAR(100)` | | Метод обработки (washed, natural...) |
| `height_min` | `SMALLINT` | | Мин. высота (м) |
| `height_max` | `SMALLINT` | | Макс. высота (м) |
| `description` | `TEXT` | | Описание партии |
| `followers` | `INTEGER` | `DEFAULT 0` | Подписчики на партию |

### ☕ Готовая продукция

**`coffees`** (обжаренный кофе)
| Атрибут | Тип | Ограничения | Описание |
|---------|-----|-------------|----------|
| `coffee_id` | `BIGSERIAL` | `PRIMARY KEY` | ID кофе |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL DEFAULT NOW()` | Дата создания |
| `created_by` | `BIGINT` | `FOREIGN KEY REFERENCES users(user_id)` | Кто создал |
| `green_bean_id` | `BIGINT` | `FOREIGN KEY REFERENCES green_beans(beans_id)` | Партия зеленого зерна |
| `crop_year` | `SMALLINT` | | Год урожая |
| `crop_month` | `SMALLINT` | `CHECK (crop_month BETWEEN 1 AND 12)` | Месяц сбора |
| `exporter_id` | `BIGINT` | `FOREIGN KEY REFERENCES exporters(exporter_id)` | Экспортёр |
| `importer_id` | `BIGINT` | `FOREIGN KEY REFERENCES importers(importer_id)` | Импортёр |
| `roaster_id` | `BIGINT` | `FOREIGN KEY REFERENCES roasters(roaster_id)` | Обжарщик |
| `roasting_level` | `VARCHAR(100)` | | Степень обжарки enum|
| `price` | `DECIMAL(10,2)` | | Цена за кг |
| `weight` | `INTEGER` | | Вес упаковки (г) |
| `price_250g` | `DECIMAL(10,2)` | | Цена за 250г |
| `price_1Kg` | `DECIMAL(10,2)` | | Цена за 1кг |
| `currency` | `CHAR(3)` | | валюта ISO 4217 |
| `title` | `VARCHAR(300)` | `NOT NULL` | Название |
| `description` | `TEXT` | | Описание |
| `q_grade` | `DECIMAL(3,1)` | | Q-оценка |
| `pack_image` | `BYTEA` | | Изображение упаковки (бинарные данные) |
| `pack_url` | `VARCHAR(500)` | | Ссылка на изображение |
| `url` | `VARCHAR(500)` | | Ссылка на страницу кофе |
| `updated_at` | `TIMESTAMPTZ` | | Дата обновления |
| `updated_by` | `BIGINT` | `FOREIGN KEY REFERENCES users(user_id)` | Кто обновил |
| `avg_rating` | `DECIMAL(3,2)` | | Средняя оценка |
| `ratings_count` | `INTEGER` | `DEFAULT 0` | Количество оценок |
| `reviews_count` | `INTEGER` | `DEFAULT 0` | Количество отзывов |
| `comments_count` | `INTEGER` | `DEFAULT 0` | Количество комментариев |
| `weighted_rate` | `DECIMAL(5,2)` | | Взвешенный рейтинг |

### 👤 Пользователи и социальное

**`users`**
| Атрибут | Тип | Ограничения | Описание |
|---------|-----|-------------|----------|
| `user_id` | `BIGSERIAL` | `PRIMARY KEY` | ID пользователя |
| `city_id` | `INTEGER` | `FOREIGN KEY REFERENCES cities(city_id)` | Город |
| `username` | `VARCHAR(50)` | `NOT NULL UNIQUE` | Имя пользователя |
| `email` | `VARCHAR(255)` | `NOT NULL UNIQUE` | Email |
| `password` | `VARCHAR(255)` | | Хеш пароля (NULL для OAuth) |
| `provider` | `VARCHAR(50)` | | OAuth провайдер |
| `provider_id` | `VARCHAR(255)` | | ID у провайдера |
| `avatar_url` | `VARCHAR(500)` | | Ссылка на аватар |
| `avatar_img` | `BYTEA` | | Изображение аватара |
| `is_verified` | `BOOLEAN` | `DEFAULT FALSE` | Подтверждён ли email |
| `language` | `VARCHAR(10)` | `DEFAULT 'ru'` | Язык интерфейса |
| `is_active` | `BOOLEAN` | `DEFAULT TRUE` | Активен ли |
| `roles` | `TEXT[]` | `DEFAULT ARRAY['user']` | Роли |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL DEFAULT NOW()` | Дата регистрации |
| `updated_at` | `TIMESTAMPTZ` | | Дата обновления |
| `following_count` | `INTEGER` | `DEFAULT 0` | Количество подписок |
| `followers_count` | `INTEGER` | `DEFAULT 0` | Количество подписчиков |

### ⭐ Оценки и отзывы

**`ratings`** (оценки)
| Атрибут | Тип | Ограничения | Описание |
|---------|-----|-------------|----------|
| `user_id` | `BIGINT` | `FOREIGN KEY REFERENCES users(user_id)` | Пользователь |
| `coffee_id` | `BIGINT` | `FOREIGN KEY REFERENCES coffees(coffee_id)` | Кофе |
| `mark_scale` | `SMALLINT` | | Шкала (5, 10, 100) |
| `mark` | `SMALLINT` | `NOT NULL` | Оценка |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL DEFAULT NOW()` | Дата |
| `updated_at` | `TIMESTAMPTZ` | | Дата обновления |
| `PRIMARY KEY` | `(user_id, coffee_id)` | | Составной ключ |

**`reviews`** (отзывы)
| Атрибут | Тип | Ограничения | Описание |
|---------|-----|-------------|----------|
| `review_id` | `BIGSERIAL` | `PRIMARY KEY` | ID отзыва |
| `user_id` | `BIGINT` | `FOREIGN KEY REFERENCES users(user_id)` | Автор |
| `coffee_id` | `BIGINT` | `FOREIGN KEY REFERENCES coffees(coffee_id)` | Кофе |
| `review` | `TEXT` | `NOT NULL` | Текст отзыва |
| `method` | `VARCHAR(100)` | | Метод заваривания enum|
| `grinder_id` | `INTEGER` | `FOREIGN KEY REFERENCES grinders(grinder_id)` | Кофемолка |
| `brewer_id` | `INTEGER` | `FOREIGN KEY REFERENCES brewers(brewer_id)` | Заварник |
| `water_id` | `BIGINT` | `FOREIGN KEY REFERENCES waters(water_id)` | Вода |
| `brew_ratio` | `VARCHAR(20)` | | Соотношение (1:15) |
| `tds` | `DECIMAL(4,2)` | | TDS в % |
| `extraction` | `DECIMAL(4,1)` | | Экстракция в % |
| `brewing_recipe` | `TEXT` | | Рецепт |
| `taste_notes` | `TEXT` | | Вкусовые заметки |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL DEFAULT NOW()` | Дата создания |
| `updated_at` | `TIMESTAMPTZ` | | Дата обновления |


### 💧 Вода

**`waters`**
| Атрибут | Тип | Ограничения | Описание |
|---------|-----|-------------|----------|
| `water_id` | `BIGSERIAL` | `PRIMARY KEY` | ID воды |
| `user_id` | `BIGINT` | `FOREIGN KEY REFERENCES users(user_id)` | Создатель |
| `name` | `VARCHAR(100)` | `NOT NULL` | Название |
| `ppm` | `DECIMAL(6,1)` | | Общая минерализация |
| `ph` | `DECIMAL(3,1)` | | pH |
| `kg` | `DECIMAL(5,1)` | | Карбонатная жёсткость (KH) |
| `kh` | `DECIMAL(5,1)` | | Общая жёсткость (GH) |
| `recipe` | `TEXT` | | Рецепт |
| `is_public` | `BOOLEAN` | `DEFAULT FALSE` | Публичный профиль |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL DEFAULT NOW()` | Дата создания |

### 🛠️ Оборудование

**`grinders`** (кофемолки)
| Атрибут | Тип | Ограничения | Описание |
|---------|-----|-------------|----------|
| `grinder_id` | `INTEGER` | `PRIMARY KEY` | ID |
| `grinder` | `VARCHAR(200)` | `NOT NULL UNIQUE` | Название |
| `diam` | `SMALLINT` | | Диаметр жерновов (мм) |
| `type` | `VARCHAR(100)` | | Тип (ручная/электрическая) enum |
| `scale_min` | `INTEGER` | | min значение шкалы |
| `scale_max` | `INTEGER` | | макс значение шкалы |
| `scale_div` | `DECIMAL(3,2)` | | одно деление шкалы |
| `url` | `VARCHAR(500)` | | Ссылка |
| `description` | `TEXT` | | Описание |

**`brewers`** (заварочные устройства)
| Атрибут | Тип | Ограничения | Описание |
|---------|-----|-------------|----------|
| `brewer_id` | `INTEGER` | `PRIMARY KEY` | ID |
| `brewer` | `VARCHAR(200)` | `NOT NULL UNIQUE` | Название |
| `type` | `VARCHAR(100)` | | Тип (воронка, аэропресс...) enum |
| `url` | `VARCHAR(500)` | | Ссылка |
| `description` | `TEXT` | | Описание |

### 🏷️ Вкусы и теги

**`flavours`** (вкусы из колеса)
| Атрибут | Тип | Ограничения | Описание |
|---------|-----|-------------|----------|
| `flavour_id` | `INTEGER` | `PRIMARY KEY` | ID вкуса |
| `flavour_weel` | `VARCHAR(100)` | `NOT NULL UNIQUE` | Название вкуса |
| `description` | `TEXT` | | Описание |

**`coffee_flavours`** (связь кофе с вкусами)
| Атрибут | Тип | Ограничения | Описание |
|---------|-----|-------------|----------|
| `flavour_id` | `INTEGER` | `FOREIGN KEY REFERENCES flavours(flavour_id)` | Вкус |
| `coffee_id` | `BIGINT` | `FOREIGN KEY REFERENCES coffees(coffee_id)` | Кофе |
| `weighted` | `DECIMAL(5,2)` | | Вес (важность) |
| `counter` | `INTEGER` | `DEFAULT 0` | Счётчик упоминаний |
| `PRIMARY KEY` | `(flavour_id, coffee_id)` | | Составной ключ |

**`tags`** (пользовательские теги)
| Атрибут | Тип | Ограничения | Описание |
|---------|-----|-------------|----------|
| `tag_id` | `BIGSERIAL` | `PRIMARY KEY` | ID тега |
| `tag` | `VARCHAR(100)` | `NOT NULL UNIQUE` | Текст тега |
| `counter` | `INTEGER` | `DEFAULT 0` | Частота использования |

**`coffee_tags`** (связь кофе с тегами)
| Атрибут | Тип | Ограничения | Описание |
|---------|-----|-------------|----------|
| `tag_id` | `BIGINT` | `FOREIGN KEY REFERENCES tags(tag_id)` | Тег |
| `coffee_id` | `BIGINT` | `FOREIGN KEY REFERENCES coffees(coffee_id)` | Кофе |
| `counter` | `INTEGER` | `DEFAULT 0` | Счётчик |
| `weighted` | `DECIMAL(5,2)` | | Вес |
| `PRIMARY KEY` | `(tag_id, coffee_id)` | | Составной ключ |

### 📬 Сообщения и комментарии

**`messages`** (сообщения/комментарии)
| Атрибут | Тип | Ограничения | Описание |
|---------|-----|-------------|----------|
| `message_id` | `BIGSERIAL` | `PRIMARY KEY` | ID сообщения |
| `user_id` | `BIGINT` | `FOREIGN KEY REFERENCES users(user_id)` | Автор |
| `parent_id` | `BIGINT` | `FOREIGN KEY REFERENCES messages(message_id)` | Ответ на сообщение |
| `review_id` | `BIGINT` | `FOREIGN KEY REFERENCES reviews(review_id)` | Комментарий к отзыву |
| `coffee_id` | `BIGINT` | `FOREIGN KEY REFERENCES coffees(coffee_id)` | Комментарий к кофе |
| `message` | `TEXT` | `NOT NULL` | Текст |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL DEFAULT NOW()` | Дата |
| `updated_at` | `TIMESTAMPTZ` | | Дата обновления |


### 🔄 Подписки (все используют составной ключ)

**`follow_coffees`**
| Атрибут | Тип | Ограничения | Описание |
|---------|-----|-------------|----------|
| `follower_id` | `BIGINT` | `FOREIGN KEY REFERENCES users(user_id)` | Подписчик |
| `coffee_id` | `BIGINT` | `FOREIGN KEY REFERENCES coffees(coffee_id)` | Кофе |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL DEFAULT NOW()` | Дата подписки |
| `PRIMARY KEY` | `(follower_id, coffee_id)` | | Составной ключ |

**`follow_users`**
| Атрибут | Тип | Ограничения | Описание |
|---------|-----|-------------|----------|
| `follower_id` | `BIGINT` | `FOREIGN KEY REFERENCES users(user_id)` | Кто подписался |
| `followee_id` | `BIGINT` | `FOREIGN KEY REFERENCES users(user_id)` | На кого подписался |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL DEFAULT NOW()` | Дата |
| `PRIMARY KEY` | `(follower_id, followee_id)` | | Составной ключ |
| `CONSTRAINT` | `no_self_follow` | `CHECK (follower_id != followee_id)` | Нельзя на себя |

**`follow_roasters`**
| Атрибут | Тип | Ограничения | Описание |
|---------|-----|-------------|----------|
| `follower_id` | `BIGINT` | `FOREIGN KEY REFERENCES users(user_id)` | Подписчик |
| `roaster_id` | `BIGINT` | `FOREIGN KEY REFERENCES roasters(roaster_id)` | Обжарщик |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL DEFAULT NOW()` | Дата |
| `PRIMARY KEY` | `(follower_id, roaster_id)` | | Составной ключ |

**`follow_farms`**
| Атрибут | Тип | Ограничения | Описание |
|---------|-----|-------------|----------|
| `follower_id` | `BIGINT` | `FOREIGN KEY REFERENCES users(user_id)` | Подписчик |
| `farm_id` | `BIGINT` | `FOREIGN KEY REFERENCES farms(farm_id)` | Ферма |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL DEFAULT NOW()` | Дата |
| `PRIMARY KEY` | `(follower_id, farm_id)` | | Составной ключ |

**`follow_beans`**
| Атрибут | Тип | Ограничения | Описание |
|---------|-----|-------------|----------|
| `follower_id` | `BIGINT` | `FOREIGN KEY REFERENCES users(user_id)` | Подписчик |
| `bean_id` | `BIGINT` | `FOREIGN KEY REFERENCES green_beans(beans_id)` | Партия зерна |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL DEFAULT NOW()` | Дата |
| `PRIMARY KEY` | `(follower_id, bean_id)` | | Составной ключ |

**`follow_answers`**
| Атрибут | Тип | Ограничения | Описание |
|---------|-----|-------------|----------|
| `user_id` | `BIGINT` | `FOREIGN KEY REFERENCES users(user_id)` | Подписчик |
| `message_id` | `BIGINT` | `FOREIGN KEY REFERENCES messages(message_id)` | Сообщение |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL DEFAULT NOW()` | Дата |
| `PRIMARY KEY` | `(user_id, message_id)` | | Составной ключ |

**`follow_reviews`**
| Атрибут | Тип | Ограничения | Описание |
|---------|-----|-------------|----------|
| `user_id` | `BIGINT` | `FOREIGN KEY REFERENCES users(user_id)` | Подписчик |
| `review_id` | `BIGINT` | `FOREIGN KEY REFERENCES reviews(review_id)` | Отзыв |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL DEFAULT NOW()` | Дата |
| `PRIMARY KEY` | `(user_id, review_id)` | | Составной ключ |

---

## 📌 ENUM-типы (определения)

enum-типы не создаем

## 🎯 Ключевые рекомендации

1. **Все внешние ключи** должны иметь тот же тип, что и PK родительской таблицы.
2. **Для денег** всегда используйте `DECIMAL`, никогда `FLOAT`/`REAL`.
3. **Для дат** всегда `TIMESTAMPTZ` (с часовым поясом).
4. **Счётчики** (`followers`, `marks`) лучше обновлять триггерами, чтобы не рассинхронизироваться.
5. **В таблице `messages`** добавлен CHECK для гарантии, что сообщение привязано ровно к одной сущности.
