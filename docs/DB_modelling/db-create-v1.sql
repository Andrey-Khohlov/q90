-- Создание таблиц базы данных для кофейного каталога

-- =====================================================
-- ГЕОГРАФИЯ И ЛОКАЦИИ
-- =====================================================

-- Части света
CREATE TABLE world_parts (
    world_part_id SMALLINT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

-- Страны
CREATE TABLE countries (
    country_code CHAR(2) PRIMARY KEY,
    country VARCHAR(100) NOT NULL,
    world_part_id SMALLINT REFERENCES world_parts(world_part_id),
    is_coffee_growing BOOLEAN DEFAULT FALSE
);

-- Регионы/штаты
CREATE TABLE regions (
    region_id SMALLINT PRIMARY KEY,
    region VARCHAR(100) NOT NULL,
    country_code CHAR(2) REFERENCES countries(country_code)
);

-- Местности/районы
CREATE TABLE localities (
    locality_id INTEGER PRIMARY KEY,
    locality VARCHAR(100) NOT NULL,
    region_id SMALLINT REFERENCES regions(region_id)
);

-- Города
CREATE TABLE cities (
    city_id INTEGER PRIMARY KEY,
    city VARCHAR(100) NOT NULL,
    locality_id INTEGER REFERENCES localities(locality_id),
    country_code CHAR(2) REFERENCES countries(country_code)
);

-- =====================================================
-- ПРОИЗВОДИТЕЛИ И ПОСТАВЩИКИ
-- =====================================================

-- Фермы
CREATE TABLE farms (
    farm_id BIGSERIAL PRIMARY KEY,
    farm VARCHAR(200) NOT NULL,
    locality_id INTEGER REFERENCES localities(locality_id),
    mill VARCHAR(200),
    cooperative VARCHAR(200),
    owner VARCHAR(200),
    coordinates POINT,
    story TEXT,
    internet_site VARCHAR(500),
    phone VARCHAR(30),
    followers INTEGER DEFAULT 0
);

-- Экспортёры
CREATE TABLE exporters (
    exporter_id BIGSERIAL PRIMARY KEY,
    exporter VARCHAR(200) NOT NULL,
    internet_site VARCHAR(500),
    about TEXT
);

-- Импортёры
CREATE TABLE importers (
    importer_id BIGSERIAL PRIMARY KEY,
    importer VARCHAR(200) NOT NULL,
    internet_site VARCHAR(500),
    about TEXT
);

-- Обжарщики
CREATE TABLE roasters (
    roaster_id BIGSERIAL PRIMARY KEY,
    roaster VARCHAR(200) NOT NULL,
    city_id INTEGER REFERENCES cities(city_id),
    internet_site VARCHAR(500),
    rating_spro DECIMAL(3,2),
    rating_filter DECIMAL(3,2),
    about TEXT,
    market_vol SMALLINT,
    avrg_self_Q DECIMAL(3,2),
    followers INTEGER DEFAULT 0
);

-- =====================================================
-- СОРТА И ВИДЫ КОФЕ
-- =====================================================

-- Сорта кофе
CREATE TABLE varieties (
    variety_id INTEGER PRIMARY KEY,
    variety VARCHAR(100) NOT NULL UNIQUE,
    species VARCHAR(100) NOT NULL,
    taste_description TEXT,
    history TEXT,
    parent_1_id INTEGER REFERENCES varieties(variety_id),
    parent_2_id INTEGER REFERENCES varieties(variety_id)
);

-- Партии зеленого зерна
CREATE TABLE green_beans (
    beans_id BIGSERIAL PRIMARY KEY,
    farm_id BIGINT REFERENCES farms(farm_id),
    variety_id INTEGER REFERENCES varieties(variety_id),
    mix BOOLEAN DEFAULT FALSE,
    process VARCHAR(100),
    height_min SMALLINT,
    height_max SMALLINT,
    description TEXT,
    followers INTEGER DEFAULT 0
);

-- =====================================================
-- ПОЛЬЗОВАТЕЛИ
-- =====================================================

-- Пользователи (создаем до coffees, так как на нее есть ссылки)
CREATE TABLE users (
    user_id BIGSERIAL PRIMARY KEY,
    city_id INTEGER REFERENCES cities(city_id),
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255),
    provider VARCHAR(50),
    provider_id VARCHAR(255),
    avatar_url VARCHAR(500),
    avatar_img BYTEA,
    is_verified BOOLEAN DEFAULT FALSE,
    language VARCHAR(10) DEFAULT 'ru',
    is_active BOOLEAN DEFAULT TRUE,
    roles TEXT[] DEFAULT ARRAY['user'],
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    following_count INTEGER DEFAULT 0,
    followers_count INTEGER DEFAULT 0
);

-- =====================================================
-- ГОТОВАЯ ПРОДУКЦИЯ
-- =====================================================

-- Обжаренный кофе
CREATE TABLE coffees (
    coffee_id BIGSERIAL PRIMARY KEY,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by BIGINT REFERENCES users(user_id),
    green_bean_id BIGINT REFERENCES green_beans(beans_id),
    crop_year SMALLINT,
    crop_month SMALLINT CHECK (crop_month BETWEEN 1 AND 12),
    exporter_id BIGINT REFERENCES exporters(exporter_id),
    importer_id BIGINT REFERENCES importers(importer_id),
    roaster_id BIGINT REFERENCES roasters(roaster_id),
    roasting_level VARCHAR(100),
    price INTEGER,
    weight INTEGER,
    price_250g INTEGER,
    price_1Kg INTEGER,
    currency CHAR(3),
    title VARCHAR(300) NOT NULL,
    description TEXT,
    q_grade DECIMAL(3,1),
    pack_image BYTEA,
    pack_url VARCHAR(500),
    url VARCHAR(500),
    updated_at TIMESTAMPTZ,
    updated_by BIGINT REFERENCES users(user_id),
    avg_rating DECIMAL(3,2),
    ratings_count INTEGER DEFAULT 0,
    reviews_count INTEGER DEFAULT 0,
    comments_count INTEGER DEFAULT 0,
    weighted_rate DECIMAL(5,2)
);

-- =====================================================
-- ВОДА
-- =====================================================

-- Профили воды
CREATE TABLE waters (
    water_id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(user_id),
    name VARCHAR(100) NOT NULL,
    ppm DECIMAL(6,1),
    ph DECIMAL(3,1),
    kg DECIMAL(5,1),
    kh DECIMAL(5,1),
    recipe TEXT,
    is_public BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =====================================================
-- ОБОРУДОВАНИЕ
-- =====================================================

-- Кофемолки
CREATE TABLE grinders (
    grinder_id INTEGER PRIMARY KEY,
    grinder VARCHAR(200) NOT NULL UNIQUE,
    diam SMALLINT,
    type VARCHAR(100),
    scale_min INTEGER,
    scale_max INTEGER,
    scale_div DECIMAL(3,2),
    url VARCHAR(500),
    description TEXT
);

-- Заварочные устройства
CREATE TABLE brewers (
    brewer_id INTEGER PRIMARY KEY,
    brewer VARCHAR(200) NOT NULL UNIQUE,
    type VARCHAR(100),
    url VARCHAR(500),
    description TEXT
);

-- =====================================================
-- DISCUSIONS
-- =====================================================

-- Отзывы
CREATE TABLE reviews (
    review_id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(user_id),
    coffee_id BIGINT REFERENCES coffees(coffee_id),
    review TEXT NOT NULL,
    method VARCHAR(100),
    grinder_id INTEGER REFERENCES grinders(grinder_id),
    brewer_id INTEGER REFERENCES brewers(brewer_id),
    water_id BIGINT REFERENCES waters(water_id),
    brew_ratio VARCHAR(20),
    tds DECIMAL(4,2),
    extraction DECIMAL(4,1),
    brewing_recipe TEXT,
    taste_notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ
);

-- Оценки
CREATE TABLE ratings (
    user_id BIGINT REFERENCES users(user_id),
    coffee_id BIGINT REFERENCES coffees(coffee_id),
    mark_scale SMALLINT,
    mark SMALLINT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    PRIMARY KEY (user_id, coffee_id)
);

-- Сообщения/комментарии
CREATE TABLE messages (
    message_id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(user_id),
    parent_id BIGINT REFERENCES messages(message_id),
    review_id BIGINT REFERENCES reviews(review_id),
    coffee_id BIGINT REFERENCES coffees(coffee_id),
    message TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ
);

-- =====================================================
-- ВКУСЫ И ТЕГИ
-- =====================================================

-- Вкусы из колеса
CREATE TABLE flavours (
    flavour_id INTEGER PRIMARY KEY,
    flavour_weel VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

-- Связь кофе с вкусами
CREATE TABLE coffee_flavours (
    flavour_id INTEGER REFERENCES flavours(flavour_id),
    coffee_id BIGINT REFERENCES coffees(coffee_id),
    weighted DECIMAL(5,2),
    counter INTEGER DEFAULT 0,
    PRIMARY KEY (flavour_id, coffee_id)
);

-- Пользовательские теги
CREATE TABLE tags (
    tag_id BIGSERIAL PRIMARY KEY,
    tag VARCHAR(100) NOT NULL UNIQUE,
    counter INTEGER DEFAULT 0
);

-- Связь кофе с тегами
CREATE TABLE coffee_tags (
    tag_id BIGINT REFERENCES tags(tag_id),
    coffee_id BIGINT REFERENCES coffees(coffee_id),
    counter INTEGER DEFAULT 0,
    weighted DECIMAL(5,2),
    PRIMARY KEY (tag_id, coffee_id)
);


-- =====================================================
-- ПОДПИСКИ
-- =====================================================

-- Подписки на кофе
CREATE TABLE follow_coffees (
    follower_id BIGINT REFERENCES users(user_id),
    coffee_id BIGINT REFERENCES coffees(coffee_id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (follower_id, coffee_id)
);

-- Подписки на пользователей
CREATE TABLE follow_users (
    follower_id BIGINT REFERENCES users(user_id),
    followee_id BIGINT REFERENCES users(user_id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (follower_id, followee_id),
    CONSTRAINT no_self_follow CHECK (follower_id != followee_id)
);

-- Подписки на обжарщиков
CREATE TABLE follow_roasters (
    follower_id BIGINT REFERENCES users(user_id),
    roaster_id BIGINT REFERENCES roasters(roaster_id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (follower_id, roaster_id)
);

-- Подписки на фермы
CREATE TABLE follow_farms (
    follower_id BIGINT REFERENCES users(user_id),
    farm_id BIGINT REFERENCES farms(farm_id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (follower_id, farm_id)
);

-- Подписки на партии зерна
CREATE TABLE follow_beans (
    follower_id BIGINT REFERENCES users(user_id),
    bean_id BIGINT REFERENCES green_beans(beans_id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (follower_id, bean_id)
);

-- Подписки на сообщения
CREATE TABLE follow_answers (
    user_id BIGINT REFERENCES users(user_id),
    message_id BIGINT REFERENCES messages(message_id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id, message_id)
);

-- Подписки на отзывы
CREATE TABLE follow_reviews (
    user_id BIGINT REFERENCES users(user_id),
    review_id BIGINT REFERENCES reviews(review_id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id, review_id)
);

-- =====================================================
-- ИНДЕКСЫ ДЛЯ ОПТИМИЗАЦИИ
-- =====================================================

-- Индексы для внешних ключей
CREATE INDEX idx_countries_world_part ON countries(world_part_id);
CREATE INDEX idx_regions_country ON regions(country_code);
CREATE INDEX idx_localities_region ON localities(region_id);
CREATE INDEX idx_cities_locality ON cities(locality_id);
CREATE INDEX idx_cities_country ON cities(country_code);
CREATE INDEX idx_farms_locality ON farms(locality_id);
CREATE INDEX idx_roasters_city ON roasters(city_id);
CREATE INDEX idx_green_beans_farm ON green_beans(farm_id);
CREATE INDEX idx_green_beans_variety ON green_beans(variety_id);
CREATE INDEX idx_coffees_green_bean ON coffees(green_bean_id);
CREATE INDEX idx_coffees_roaster ON coffees(roaster_id);
CREATE INDEX idx_coffees_exporter ON coffees(exporter_id);
CREATE INDEX idx_coffees_importer ON coffees(importer_id);
CREATE INDEX idx_coffees_created_by ON coffees(created_by);
CREATE INDEX idx_reviews_user ON reviews(user_id);
CREATE INDEX idx_reviews_coffee ON reviews(coffee_id);
CREATE INDEX idx_reviews_grinder ON reviews(grinder_id);
CREATE INDEX idx_reviews_brewer ON reviews(brewer_id);
CREATE INDEX idx_reviews_water ON reviews(water_id);
CREATE INDEX idx_messages_user ON messages(user_id);
CREATE INDEX idx_messages_parent ON messages(parent_id);
CREATE INDEX idx_messages_review ON messages(review_id);
CREATE INDEX idx_messages_coffee ON messages(coffee_id);
CREATE INDEX idx_users_city ON users(city_id);
CREATE INDEX idx_waters_user ON waters(user_id);

-- Составные индексы для часто используемых запросов
CREATE INDEX idx_coffees_roaster_rating ON coffees(roaster_id, avg_rating);
CREATE INDEX idx_coffees_created_rating ON coffees(created_at, avg_rating);
CREATE INDEX idx_reviews_created ON reviews(created_at);
CREATE INDEX idx_ratings_coffee_mark ON ratings(coffee_id, mark);

-- Полнотекстовый поиск (опционально)
-- CREATE INDEX idx_coffees_title_trgm ON coffees USING gin (title gin_trgm_ops);
-- CREATE INDEX idx_coffees_description_trgm ON coffees USING gin (description gin_trgm_ops);

COMMENT ON TABLE world_parts IS 'Части света';
COMMENT ON TABLE countries IS 'Страны мира';
COMMENT ON TABLE regions IS 'Регионы/штаты';
COMMENT ON TABLE localities IS 'Местности/районы';
COMMENT ON TABLE cities IS 'Города';
COMMENT ON TABLE farms IS 'Фермы производителей кофе';
COMMENT ON TABLE exporters IS 'Компании-экспортёры';
COMMENT ON TABLE importers IS 'Компании-импортёры';
COMMENT ON TABLE roasters IS 'Обжарщики кофе';
COMMENT ON TABLE varieties IS 'Сорта кофе';
COMMENT ON TABLE green_beans IS 'Партии зеленого зерна';
COMMENT ON TABLE users IS 'Пользователи системы';
COMMENT ON TABLE coffees IS 'Обжаренный кофе';
COMMENT ON TABLE waters IS 'Профили воды для заваривания';
COMMENT ON TABLE grinders IS 'Кофемолки';
COMMENT ON TABLE brewers IS 'Заварочные устройства';
COMMENT ON TABLE reviews IS 'Отзывы на кофе';
COMMENT ON TABLE ratings IS 'Оценки кофе пользователями';
COMMENT ON TABLE flavours IS 'Вкусы из кофейного колеса';
COMMENT ON TABLE coffee_flavours IS 'Связь кофе с вкусами';
COMMENT ON TABLE tags IS 'Пользовательские теги';
COMMENT ON TABLE coffee_tags IS 'Связь кофе с тегами';
COMMENT ON TABLE messages IS 'Сообщения и комментарии';
COMMENT ON TABLE follow_coffees IS 'Подписки на кофе';
COMMENT ON TABLE follow_users IS 'Подписки на пользователей';
COMMENT ON TABLE follow_roasters IS 'Подписки на обжарщиков';
COMMENT ON TABLE follow_farms IS 'Подписки на фермы';
COMMENT ON TABLE follow_beans IS 'Подписки на партии зерна';
COMMENT ON TABLE follow_answers IS 'Подписки на сообщения';
COMMENT ON TABLE follow_reviews IS 'Подписки на отзывы';


