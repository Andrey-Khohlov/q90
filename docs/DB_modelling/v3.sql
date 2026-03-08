-- Приведение схемы к 1НФ:
-- 1) Убраны многозначные атрибуты-массивы (organizations.org_types, users.roles).
-- 2) Для них введены отдельные справочники и таблицы связей многие-ко-многим.

-- Устранение проблем супертипов и подтипов в схеме базы данных кофейного сообщества

-- 1. ГЕОГРАФИЧЕСКАЯ ИЕРАРХИЯ (вместо world_parts, countries, regions, localities, cities)
CREATE TABLE locations (
    location_id BIGSERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    location_type VARCHAR(50) NOT NULL, -- 'world_part', 'country', 'region', 'locality', 'city'
    parent_id BIGINT REFERENCES locations(location_id) DEFERRABLE INITIALLY IMMEDIATE,
    country_code CHAR(2), -- для стран (ISO Alpha-2)
    is_coffee_growing BOOLEAN DEFAULT false, -- для стран
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ
);

COMMENT ON TABLE locations IS 'Географические объекты (части света, страны, регионы, местности, города)';

-- Индексы для быстрого поиска по иерархии
CREATE INDEX idx_locations_parent ON locations(parent_id);
CREATE INDEX idx_locations_type ON locations(location_type);
CREATE UNIQUE INDEX idx_locations_country_code ON locations(country_code) WHERE location_type = 'country';

-- 2. ОРГАНИЗАЦИИ (супертип для farms, exporters, importers, roasters)
CREATE TABLE organizations (
    org_id BIGSERIAL PRIMARY KEY,
    org_name VARCHAR(200) NOT NULL,
    internet_site VARCHAR(500),
    about TEXT,
    location_id BIGINT REFERENCES locations(location_id) DEFERRABLE INITIALLY IMMEDIATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ
);

COMMENT ON TABLE organizations IS 'Организации-участники рынка (фермы, экспортёры, импортёры, обжарщики)';

CREATE INDEX idx_organizations_location ON organizations(location_id);

-- 2.0 Типы организаций (1НФ: вместо массива org_types)
CREATE TABLE organization_type_dict (
    org_type VARCHAR(50) PRIMARY KEY -- 'farm', 'exporter', 'importer', 'roaster'
);

COMMENT ON TABLE organization_type_dict IS 'Справочник типов организаций';

CREATE TABLE organization_types (
    org_id BIGINT NOT NULL REFERENCES organizations(org_id) DEFERRABLE INITIALLY IMMEDIATE,
    org_type VARCHAR(50) NOT NULL REFERENCES organization_type_dict(org_type) DEFERRABLE INITIALLY IMMEDIATE,
    PRIMARY KEY (org_id, org_type)
);

COMMENT ON TABLE organization_types IS 'Связь организации с её типами (many-to-many)';

CREATE INDEX idx_organization_types_org_type ON organization_types(org_type);

-- 2.1 Детали ферм (специфические поля, не общие для всех организаций)
CREATE TABLE farm_details (
    farm_id BIGINT PRIMARY KEY REFERENCES organizations(org_id) DEFERRABLE INITIALLY IMMEDIATE,
    mill VARCHAR(200),
    cooperative VARCHAR(200),
    owner VARCHAR(200),
    coordinates POINT,
    story TEXT,
    phone VARCHAR(30),
    followers INTEGER DEFAULT 0
);

COMMENT ON TABLE farm_details IS 'Детальная информация о фермах';

-- 2.2 Детали обжарщиков
CREATE TABLE roaster_details (
    roaster_id BIGINT PRIMARY KEY REFERENCES organizations(org_id) DEFERRABLE INITIALLY IMMEDIATE,
    rating_spro DECIMAL(3,2),
    rating_filter DECIMAL(3,2),
    market_vol SMALLINT,
    avrg_self_Q DECIMAL(3,2),
    followers INTEGER DEFAULT 0
);

COMMENT ON TABLE roaster_details IS 'Детальная информация об обжарщиках';

-- Экспортёры и импортёры не имеют дополнительных полей, поэтому отдельные таблицы не нужны.

-- 3. ПОЛЬЗОВАТЕЛИ (без массивов, роли вынесены в отдельную таблицу)
CREATE TABLE users (
    user_id BIGSERIAL PRIMARY KEY,
    location_id BIGINT REFERENCES locations(location_id) DEFERRABLE INITIALLY IMMEDIATE,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255),
    provider VARCHAR(50),
    provider_id VARCHAR(255),
    avatar_url VARCHAR(500),
    avatar_img BYTEA,
    is_verified BOOLEAN DEFAULT false,
    language VARCHAR(10) DEFAULT 'ru',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    following_count INTEGER DEFAULT 0,
    followers_count INTEGER DEFAULT 0
);

COMMENT ON TABLE users IS 'Пользователи системы';

CREATE INDEX idx_users_location ON users(location_id);

CREATE TABLE role_dict (
    role_name VARCHAR(50) PRIMARY KEY
);

COMMENT ON TABLE role_dict IS 'Справочник ролей пользователей';

CREATE TABLE user_roles (
    user_id BIGINT NOT NULL REFERENCES users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    role_name VARCHAR(50) NOT NULL REFERENCES role_dict(role_name) DEFERRABLE INITIALLY IMMEDIATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id, role_name)
);

COMMENT ON TABLE user_roles IS 'Роли пользователей (many-to-many)';

CREATE INDEX idx_user_roles_role ON user_roles(role_name);

-- 4. СОРТА КОФЕ (без изменений)
CREATE TABLE varieties (
    variety_id INTEGER PRIMARY KEY,
    variety VARCHAR(100) UNIQUE NOT NULL,
    species VARCHAR(100) NOT NULL,
    taste_description TEXT,
    history TEXT,
    origin_type VARCHAR(20) NOT NULL
);

COMMENT ON TABLE varieties IS 'Сорта кофе';

-- 5. РОДИТЕЛЬСКИЕ СВЯЗИ СОРТОВ (убираем суррогатный ключ, используем составной)
CREATE TABLE variety_parents (
    variety_id INTEGER NOT NULL REFERENCES varieties(variety_id) DEFERRABLE INITIALLY IMMEDIATE,
    parent_id INTEGER NOT NULL REFERENCES varieties(variety_id) DEFERRABLE INITIALLY IMMEDIATE,
    parent_role VARCHAR(20),
    notes TEXT,
    PRIMARY KEY (variety_id, parent_id)
);

COMMENT ON TABLE variety_parents IS 'Связь сорта с его предками';

CREATE INDEX ON variety_parents (parent_id);

-- 6. ЗЕЛЁНОЕ ЗЕРНО (ссылается на организации-фермы)
CREATE TABLE green_beans (
    beans_id BIGSERIAL PRIMARY KEY,
    farm_id BIGINT REFERENCES organizations(org_id) DEFERRABLE INITIALLY IMMEDIATE,
    variety_id INTEGER REFERENCES varieties(variety_id) DEFERRABLE INITIALLY IMMEDIATE,
    mix BOOLEAN DEFAULT false,
    process VARCHAR(100),
    height_min SMALLINT,
    height_max SMALLINT,
    description TEXT,
    followers INTEGER DEFAULT 0
);

COMMENT ON TABLE green_beans IS 'Партии зеленого зерна';

CREATE INDEX idx_green_beans_farm ON green_beans(farm_id);
CREATE INDEX idx_green_beans_variety ON green_beans(variety_id);

-- 7. ОБЖАРЕННЫЙ КОФЕ (ссылки на организации вместо конкретных таблиц)
CREATE TABLE coffees (
    coffee_id BIGSERIAL PRIMARY KEY,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by BIGINT REFERENCES users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    green_bean_id BIGINT REFERENCES green_beans(beans_id) DEFERRABLE INITIALLY IMMEDIATE,
    crop_year SMALLINT,
    crop_month SMALLINT CHECK (crop_month BETWEEN 1 AND 12),
    exporter_id BIGINT REFERENCES organizations(org_id) DEFERRABLE INITIALLY IMMEDIATE,
    importer_id BIGINT REFERENCES organizations(org_id) DEFERRABLE INITIALLY IMMEDIATE,
    roaster_id BIGINT REFERENCES organizations(org_id) DEFERRABLE INITIALLY IMMEDIATE,
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
    updated_by BIGINT REFERENCES users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    avg_rating DECIMAL(3,2),
    ratings_count INTEGER DEFAULT 0,
    reviews_count INTEGER DEFAULT 0,
    comments_count INTEGER DEFAULT 0
);

COMMENT ON TABLE coffees IS 'Обжаренный кофе';

CREATE INDEX idx_coffees_green_bean ON coffees(green_bean_id);
CREATE INDEX idx_coffees_roaster ON coffees(roaster_id);
CREATE INDEX idx_coffees_exporter ON coffees(exporter_id);
CREATE INDEX idx_coffees_importer ON coffees(importer_id);
CREATE INDEX idx_coffees_created_by ON coffees(created_by);
CREATE INDEX idx_coffees_roaster_rating ON coffees(roaster_id, avg_rating);
CREATE INDEX idx_coffees_created_rating ON coffees(created_at, avg_rating);

-- 8. ПРОЧИЕ ТАБЛИЦЫ (без изменений, но ссылки на географию через locations там, где были city_id и т.п.)
-- Вода
CREATE TABLE waters (
    water_id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    name VARCHAR(100) NOT NULL,
    ppm DECIMAL(6,1),
    ph DECIMAL(3,1),
    kg DECIMAL(5,1),
    kh DECIMAL(5,1),
    recipe TEXT,
    is_public BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE waters IS 'Профили воды для заваривания';

CREATE INDEX idx_waters_user ON waters(user_id);

-- Кофемолки
CREATE TABLE grinders (
    grinder_id INTEGER PRIMARY KEY,
    grinder VARCHAR(200) UNIQUE NOT NULL,
    diam SMALLINT,
    type VARCHAR(100),
    scale_min INTEGER,
    scale_max INTEGER,
    scale_div DECIMAL(3,2),
    url VARCHAR(500),
    description TEXT
);

COMMENT ON TABLE grinders IS 'Кофемолки';

-- Заварочные устройства
CREATE TABLE brewers (
    brewer_id INTEGER PRIMARY KEY,
    brewer VARCHAR(200) UNIQUE NOT NULL,
    type VARCHAR(100),
    url VARCHAR(500),
    description TEXT
);

COMMENT ON TABLE brewers IS 'Заварочные устройства';

-- Отзывы (reviews) – без изменений
CREATE TABLE reviews (
    review_id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    coffee_id BIGINT REFERENCES coffees(coffee_id) DEFERRABLE INITIALLY IMMEDIATE,
    review TEXT NOT NULL,
    method VARCHAR(100),
    grinder_id INTEGER REFERENCES grinders(grinder_id) DEFERRABLE INITIALLY IMMEDIATE,
    brewer_id INTEGER REFERENCES brewers(brewer_id) DEFERRABLE INITIALLY IMMEDIATE,
    water_id BIGINT REFERENCES waters(water_id) DEFERRABLE INITIALLY IMMEDIATE,
    brew_ratio VARCHAR(20),
    tds DECIMAL(4,2),
    extraction DECIMAL(4,1),
    brewing_recipe TEXT,
    taste_notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ
);

COMMENT ON TABLE reviews IS 'Отзывы на кофе';

CREATE INDEX idx_reviews_user ON reviews(user_id);
CREATE INDEX idx_reviews_coffee ON reviews(coffee_id);
CREATE INDEX idx_reviews_grinder ON reviews(grinder_id);
CREATE INDEX idx_reviews_brewer ON reviews(brewer_id);
CREATE INDEX idx_reviews_water ON reviews(water_id);
CREATE INDEX idx_reviews_created ON reviews(created_at);

-- Оценки
CREATE TABLE ratings (
    user_id BIGINT REFERENCES users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    coffee_id BIGINT REFERENCES coffees(coffee_id) DEFERRABLE INITIALLY IMMEDIATE,
    mark_scale SMALLINT,
    mark SMALLINT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    PRIMARY KEY (user_id, coffee_id)
);

COMMENT ON TABLE ratings IS 'Оценки кофе пользователями';

CREATE INDEX idx_ratings_coffee_mark ON ratings(coffee_id, mark);

-- Сообщения
CREATE TABLE messages (
    message_id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    parent_id BIGINT REFERENCES messages(message_id) DEFERRABLE INITIALLY IMMEDIATE,
    review_id BIGINT REFERENCES reviews(review_id) DEFERRABLE INITIALLY IMMEDIATE,
    coffee_id BIGINT REFERENCES coffees(coffee_id) DEFERRABLE INITIALLY IMMEDIATE,
    message TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ
);

COMMENT ON TABLE messages IS 'Сообщения и комментарии';

CREATE INDEX idx_messages_user ON messages(user_id);
CREATE INDEX idx_messages_parent ON messages(parent_id);
CREATE INDEX idx_messages_review ON messages(review_id);
CREATE INDEX idx_messages_coffee ON messages(coffee_id);

-- Вкусы (flavours)
CREATE TABLE flavours (
    flavour_id INTEGER PRIMARY KEY,
    flavour_weel VARCHAR(100) UNIQUE NOT NULL,
    description TEXT
);

COMMENT ON TABLE flavours IS 'Вкусы из кофейного колеса';

-- Связь кофе и вкусов
CREATE TABLE coffee_flavours (
    flavour_id INTEGER REFERENCES flavours(flavour_id) DEFERRABLE INITIALLY IMMEDIATE,
    coffee_id BIGINT REFERENCES coffees(coffee_id) DEFERRABLE INITIALLY IMMEDIATE,
    weighted DECIMAL(5,2),
    counter INTEGER DEFAULT 0,
    PRIMARY KEY (flavour_id, coffee_id)
);

COMMENT ON TABLE coffee_flavours IS 'Связь кофе с вкусами';

-- Теги
CREATE TABLE tags (
    tag_id BIGSERIAL PRIMARY KEY,
    tag VARCHAR(100) UNIQUE NOT NULL,
    counter INTEGER DEFAULT 0
);

COMMENT ON TABLE tags IS 'Пользовательские теги';

-- Связь кофе и тегов
CREATE TABLE coffee_tags (
    tag_id BIGINT REFERENCES tags(tag_id) DEFERRABLE INITIALLY IMMEDIATE,
    coffee_id BIGINT REFERENCES coffees(coffee_id) DEFERRABLE INITIALLY IMMEDIATE,
    counter INTEGER DEFAULT 0,
    weighted DECIMAL(5,2),
    PRIMARY KEY (tag_id, coffee_id)
);

COMMENT ON TABLE coffee_tags IS 'Связь кофе с тегами';

-- 9. ПОДПИСКИ (единая полиморфная таблица вместо 7)
CREATE TABLE follows (
    follow_id BIGSERIAL PRIMARY KEY,
    follower_id BIGINT NOT NULL REFERENCES users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    target_type VARCHAR(50) NOT NULL, -- 'coffee', 'user', 'roaster', 'farm', 'bean', 'message', 'review'
    target_id BIGINT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (follower_id, target_type, target_id)
);

COMMENT ON TABLE follows IS 'Подписки пользователей на различные объекты';

CREATE INDEX idx_follows_follower ON follows(follower_id);
CREATE INDEX idx_follows_target ON follows(target_type, target_id);

-- 10. КОММЕНТАРИИ К ТАБЛИЦАМ (обновлены для изменённых)
COMMENT ON TABLE locations IS 'Географические объекты (части света, страны, регионы, местности, города)';
COMMENT ON TABLE organizations IS 'Организации-участники рынка (фермы, экспортёры, импортёры, обжарщики)';
COMMENT ON TABLE organization_type_dict IS 'Справочник типов организаций';
COMMENT ON TABLE organization_types IS 'Связь организации с её типами (many-to-many)';
COMMENT ON TABLE farm_details IS 'Детальная информация о фермах';
COMMENT ON TABLE roaster_details IS 'Детальная информация об обжарщиках';
COMMENT ON TABLE users IS 'Пользователи системы (ссылка на location)';
COMMENT ON TABLE role_dict IS 'Справочник ролей пользователей';
COMMENT ON TABLE user_roles IS 'Роли пользователей (many-to-many)';
COMMENT ON TABLE follows IS 'Подписки пользователей на различные объекты';
