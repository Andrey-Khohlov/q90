-- coffee-db

-- Создание схем
CREATE SCHEMA IF NOT EXISTS geography;
CREATE SCHEMA IF NOT EXISTS organizations;
CREATE SCHEMA IF NOT EXISTS users;
CREATE SCHEMA IF NOT EXISTS coffee;
CREATE SCHEMA IF NOT EXISTS equipment;
CREATE SCHEMA IF NOT EXISTS social;
CREATE SCHEMA IF NOT EXISTS moderation;

-- =====================================================
-- Схема: geography
-- =====================================================
-- реализация паттерна "Single Table Inheritance" или, точнее, иерархической структуры в одной таблице.
CREATE TABLE geography.locations (
    location_id BIGSERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    location_type VARCHAR(50) NOT NULL, -- 'world_part', 'country', 'region', 'locality', 'city'
    parent_id BIGINT NOT NULL REFERENCES geography.locations(location_id) DEFERRABLE INITIALLY IMMEDIATE,
    country_code CHAR(2), -- для стран (ISO Alpha-2)
    is_coffee_growing BOOLEAN DEFAULT false, -- для стран
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);

COMMENT ON TABLE geography.locations IS 'Географические объекты (части света, страны, регионы, местности, города)';

CREATE INDEX idx_locations_parent ON geography.locations(parent_id);
CREATE UNIQUE INDEX idx_locations_country_code ON geography.locations(country_code) WHERE location_type = 'country';

-- =====================================================
-- Схема: organizations
-- =====================================================
CREATE TABLE organizations.organizations (
    org_id BIGSERIAL PRIMARY KEY,
    org_name VARCHAR(200) NOT NULL,
    internet_site VARCHAR(500),
    about TEXT,
    location_id BIGINT NOT NULL REFERENCES geography.locations(location_id) DEFERRABLE INITIALLY IMMEDIATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);

COMMENT ON TABLE organizations.organizations IS 'Организации-участники рынка (фермы, экспортёры, импортёры, обжарщики)';

CREATE INDEX idx_organizations_location ON organizations.organizations(location_id);

CREATE TABLE organizations.organization_type_dict (
    org_type VARCHAR(50) PRIMARY KEY -- 'farm', 'exporter', 'importer', 'roaster'
);

COMMENT ON TABLE organizations.organization_type_dict IS 'Справочник типов организаций';

CREATE TABLE organizations.organization_types (
    org_id BIGINT NOT NULL REFERENCES organizations.organizations(org_id) DEFERRABLE INITIALLY IMMEDIATE,
    org_type VARCHAR(50) NOT NULL REFERENCES organizations.organization_type_dict(org_type) DEFERRABLE INITIALLY IMMEDIATE,
    PRIMARY KEY (org_id, org_type)
);

COMMENT ON TABLE organizations.organization_types IS 'Связь организации с её типами (many-to-many)';

CREATE INDEX idx_organization_types_org_type ON organizations.organization_types(org_type);

CREATE TABLE organizations.farm_details (
    farm_id BIGINT PRIMARY KEY REFERENCES organizations.organizations(org_id) DEFERRABLE INITIALLY IMMEDIATE,
    mill VARCHAR(200),
    cooperative VARCHAR(200),
    owner VARCHAR(200),
    coordinates POINT,
    story TEXT,
    phone VARCHAR(30),
    followers INTEGER DEFAULT 0
);

COMMENT ON TABLE organizations.farm_details IS 'Детальная информация о фермах';

CREATE TABLE organizations.roaster_details (
    roaster_id BIGINT PRIMARY KEY REFERENCES organizations.organizations(org_id) DEFERRABLE INITIALLY IMMEDIATE,
    rating_spro DECIMAL(3,2),
    rating_filter DECIMAL(3,2),
    market_vol SMALLINT,
    avrg_self_Q DECIMAL(3,2),
    followers INTEGER DEFAULT 0
);

COMMENT ON TABLE organizations.roaster_details IS 'Детальная информация об обжарщиках';

-- =====================================================
-- Схема: users
-- =====================================================
CREATE TABLE users.users (
    user_id BIGSERIAL PRIMARY KEY,
    location_id BIGINT NOT NULL REFERENCES geography.locations(location_id) DEFERRABLE INITIALLY IMMEDIATE,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255),
    provider VARCHAR(50),
    provider_id VARCHAR(255),
    avatar_url VARCHAR(500),
    avatar_img BYTEA,
    is_verified BOOLEAN DEFAULT false,
    language VARCHAR(10) DEFAULT 'ru',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    following_count INTEGER DEFAULT 0,
    followers_count INTEGER DEFAULT 0
);

COMMENT ON TABLE users.users IS 'Пользователи системы';

CREATE INDEX idx_users_location ON users.users(location_id);

CREATE TABLE users.role_dict (
    role_name VARCHAR(50) PRIMARY KEY
);

COMMENT ON TABLE users.role_dict IS 'Справочник ролей пользователей';

CREATE TABLE users.user_roles (
    user_id BIGINT NOT NULL REFERENCES users.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    role_name VARCHAR(50) NOT NULL REFERENCES users.role_dict(role_name) DEFERRABLE INITIALLY IMMEDIATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id, role_name)
);

COMMENT ON TABLE users.user_roles IS 'Роли пользователей (many-to-many)';

CREATE INDEX idx_user_roles_role ON users.user_roles(role_name);

-- =====================================================
-- Схема: coffee
-- =====================================================
CREATE TABLE coffee.varieties (
    variety_id SERIAL PRIMARY KEY,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by BIGINT NOT NULL REFERENCES users.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    variety VARCHAR(100) UNIQUE NOT NULL,
    species VARCHAR(100) NOT NULL,
    taste_description TEXT,
    history TEXT,
    origin_type VARCHAR(20) NOT NULL,
    updated_at TIMESTAMPTZ,
    updated_by BIGINT REFERENCES users.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    deleted_at TIMESTAMPTZ,
    deleted_by BIGINT REFERENCES users.users(user_id) DEFERRABLE INITIALLY IMMEDIATE
);

COMMENT ON TABLE coffee.varieties IS 'Сорта кофе';

CREATE TABLE coffee.variety_parents (
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by BIGINT NOT NULL REFERENCES users.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    variety_id INTEGER NOT NULL REFERENCES coffee.varieties(variety_id) DEFERRABLE INITIALLY IMMEDIATE,
    parent_id INTEGER NOT NULL REFERENCES coffee.varieties(variety_id) DEFERRABLE INITIALLY IMMEDIATE,
    parent_role VARCHAR(20) NOT NULL,
    notes TEXT,
    updated_at TIMESTAMPTZ,
    updated_by BIGINT REFERENCES users.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    deleted_at TIMESTAMPTZ,
    deleted_by BIGINT REFERENCES users.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    PRIMARY KEY (variety_id, parent_id)
);

COMMENT ON TABLE coffee.variety_parents IS 'Связь сорта с его предками';

CREATE INDEX ON coffee.variety_parents (parent_id);

CREATE TABLE coffee.green_beans (
    beans_id BIGSERIAL PRIMARY KEY,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by BIGINT NOT NULL REFERENCES users.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    farm_id BIGINT REFERENCES organizations.organizations(org_id) DEFERRABLE INITIALLY IMMEDIATE,
    variety_id INTEGER REFERENCES coffee.varieties(variety_id) DEFERRABLE INITIALLY IMMEDIATE,
    mix BOOLEAN DEFAULT false,
    process VARCHAR(100) NOT NULL,
    height_min SMALLINT,
    height_max SMALLINT,
    description TEXT,
    followers INTEGER DEFAULT 0,
    updated_at TIMESTAMPTZ,
    updated_by BIGINT REFERENCES users.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    deleted_at TIMESTAMPTZ,
    deleted_by BIGINT REFERENCES users.users(user_id) DEFERRABLE INITIALLY IMMEDIATE
);

COMMENT ON TABLE coffee.green_beans IS 'Партии зеленого зерна';

CREATE INDEX idx_green_beans_farm ON coffee.green_beans(farm_id);
CREATE INDEX idx_green_beans_variety ON coffee.green_beans(variety_id);

CREATE TABLE coffee.coffees (
    coffee_id BIGSERIAL PRIMARY KEY,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by BIGINT NOT NULL REFERENCES users.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    green_bean_id BIGINT NOT NULL REFERENCES coffee.green_beans(beans_id) DEFERRABLE INITIALLY IMMEDIATE,
    crop_year SMALLINT NOT NULL,
    crop_month SMALLINT NOT NULL CHECK (crop_month BETWEEN 1 AND 12),
    exporter_id BIGINT REFERENCES organizations.organizations(org_id) DEFERRABLE INITIALLY IMMEDIATE,
    importer_id BIGINT REFERENCES organizations.organizations(org_id) DEFERRABLE INITIALLY IMMEDIATE,
    roaster_id BIGINT NOT NULL REFERENCES organizations.organizations(org_id) DEFERRABLE INITIALLY IMMEDIATE,
    roasting_level VARCHAR(100) NOT NULL,
    price INTEGER,
    weight INTEGER,
    currency CHAR(3) NOT NULL,
    title VARCHAR(300) NOT NULL,
    description TEXT,
    q_grade DECIMAL(3,1),
    pack_image BYTEA,
    pack_url VARCHAR(500),
    url VARCHAR(500),
    updated_at TIMESTAMPTZ,
    updated_by BIGINT REFERENCES users.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    deleted_at TIMESTAMPTZ,
    deleted_by BIGINT REFERENCES users.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    avg_rating DECIMAL(3,2),
    ratings_count INTEGER DEFAULT 0,
    reviews_count INTEGER DEFAULT 0,
    comments_count INTEGER DEFAULT 0
);

COMMENT ON TABLE coffee.coffees IS 'Обжаренный кофе';

CREATE INDEX idx_coffees_green_bean ON coffee.coffees(green_bean_id);
CREATE INDEX idx_coffees_roaster ON coffee.coffees(roaster_id);
CREATE INDEX idx_coffees_exporter ON coffee.coffees(exporter_id);
CREATE INDEX idx_coffees_importer ON coffee.coffees(importer_id);
CREATE INDEX idx_coffees_created_by ON coffee.coffees(created_by);
CREATE INDEX idx_coffees_roaster_rating ON coffee.coffees(roaster_id, avg_rating);
CREATE INDEX idx_coffees_created_rating ON coffee.coffees(created_at, avg_rating);

CREATE TABLE coffee.flavours (
    flavour_id INTEGER PRIMARY KEY,
    flavour_weel VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    deleted_at TIMESTAMPTZ
);

COMMENT ON TABLE coffee.flavours IS 'Вкусы из кофейного колеса';

CREATE TABLE coffee.coffee_flavours (
    flavour_id INTEGER REFERENCES coffee.flavours(flavour_id) DEFERRABLE INITIALLY IMMEDIATE,
    coffee_id BIGINT REFERENCES coffee.coffees(coffee_id) DEFERRABLE INITIALLY IMMEDIATE,
    created_by BIGINT REFERENCES users.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    weighted DECIMAL(5,2),
    counter INTEGER DEFAULT 0,
    deleted_at TIMESTAMPTZ,
    PRIMARY KEY (flavour_id, coffee_id)
);

COMMENT ON TABLE coffee.coffee_flavours IS 'Связь кофе с вкусами';

CREATE TABLE coffee.tags (
    tag_id BIGSERIAL PRIMARY KEY,
    tag VARCHAR(100) UNIQUE NOT NULL,
    counter INTEGER DEFAULT 0,
    deleted_at TIMESTAMPTZ
);

COMMENT ON TABLE coffee.tags IS 'Пользовательские теги';

CREATE TABLE coffee.coffee_tags (
    tag_id BIGINT REFERENCES coffee.tags(tag_id) DEFERRABLE INITIALLY IMMEDIATE,
    coffee_id BIGINT REFERENCES coffee.coffees(coffee_id) DEFERRABLE INITIALLY IMMEDIATE,
    created_by BIGINT REFERENCES users.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    counter INTEGER DEFAULT 0,
    weighted DECIMAL(5,2),
    deleted_at TIMESTAMPTZ,
    PRIMARY KEY (tag_id, coffee_id)
);

COMMENT ON TABLE coffee.coffee_tags IS 'Связь кофе с тегами';

-- =====================================================
-- Схема: equipment
-- =====================================================
CREATE TABLE equipment.waters (
    water_id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    name VARCHAR(100) NOT NULL,
    ppm INTEGER,
    ph DECIMAL(3,1),
    gh DECIMAL(5,1),
    kh DECIMAL(5,1),
    recipe TEXT,
    is_public BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

COMMENT ON TABLE equipment.waters IS 'Профили воды для заваривания';

CREATE INDEX idx_waters_user ON equipment.waters(user_id);

CREATE TABLE equipment.grinders (
    grinder_id SERIAL PRIMARY KEY,
    grinder VARCHAR(200) UNIQUE NOT NULL,
    diam SMALLINT,
    type VARCHAR(100),
    scale_min INTEGER,
    scale_max INTEGER,
    scale_div DECIMAL(3,2),
    url VARCHAR(500),
    description TEXT,
    deleted_at TIMESTAMPTZ
);

COMMENT ON TABLE equipment.grinders IS 'Кофемолки';

CREATE TABLE equipment.brewers (
    brewer_id SERIAL PRIMARY KEY,
    brewer VARCHAR(200) UNIQUE NOT NULL,
    type VARCHAR(100),
    url VARCHAR(500),
    description TEXT,
    deleted_at TIMESTAMPTZ
);

COMMENT ON TABLE equipment.brewers IS 'Заварочные устройства';

-- =====================================================
-- Схема: social
-- =====================================================
CREATE TABLE social.reviews (
    review_id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    coffee_id BIGINT REFERENCES coffee.coffees(coffee_id) DEFERRABLE INITIALLY IMMEDIATE,
    review TEXT NOT NULL,
    method VARCHAR(100),
    grinder_id INTEGER REFERENCES equipment.grinders(grinder_id) DEFERRABLE INITIALLY IMMEDIATE,
    brewer_id INTEGER REFERENCES equipment.brewers(brewer_id) DEFERRABLE INITIALLY IMMEDIATE,
    water_id BIGINT REFERENCES equipment.waters(water_id) DEFERRABLE INITIALLY IMMEDIATE,
    brew_ratio VARCHAR(20),
    tds DECIMAL(4,2),
    extraction DECIMAL(4,1),
    brewing_recipe TEXT,
    taste_notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);

COMMENT ON TABLE social.reviews IS 'Отзывы на кофе';

CREATE INDEX idx_reviews_user ON social.reviews(user_id);
CREATE INDEX idx_reviews_coffee ON social.reviews(coffee_id);
CREATE INDEX idx_reviews_grinder ON social.reviews(grinder_id);
CREATE INDEX idx_reviews_brewer ON social.reviews(brewer_id);
CREATE INDEX idx_reviews_water ON social.reviews(water_id);
CREATE INDEX idx_reviews_created ON social.reviews(created_at);

CREATE TABLE social.ratings (
    user_id BIGINT REFERENCES users.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    coffee_id BIGINT REFERENCES coffee.coffees(coffee_id) DEFERRABLE INITIALLY IMMEDIATE,
    mark_scale SMALLINT,
    mark SMALLINT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    PRIMARY KEY (user_id, coffee_id)
);

COMMENT ON TABLE social.ratings IS 'Оценки кофе пользователями';

CREATE INDEX idx_ratings_coffee_mark ON social.ratings(coffee_id, mark);

CREATE TABLE social.messages (
    message_id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    parent_id BIGINT REFERENCES social.messages(message_id) DEFERRABLE INITIALLY IMMEDIATE,
    review_id BIGINT REFERENCES social.reviews(review_id) DEFERRABLE INITIALLY IMMEDIATE,
    coffee_id BIGINT REFERENCES coffee.coffees(coffee_id) DEFERRABLE INITIALLY IMMEDIATE,
    message TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);

COMMENT ON TABLE social.messages IS 'Сообщения и комментарии';

CREATE INDEX idx_messages_user ON social.messages(user_id);
CREATE INDEX idx_messages_parent ON social.messages(parent_id);
CREATE INDEX idx_messages_review ON social.messages(review_id);
CREATE INDEX idx_messages_coffee ON social.messages(coffee_id);

CREATE TABLE social.follows (
    follow_id BIGSERIAL PRIMARY KEY,
    follower_id BIGINT NOT NULL REFERENCES users.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    target_type VARCHAR(50) NOT NULL, -- 'coffee', 'user', 'roaster', 'farm', 'bean', 'message', 'review'
    target_id BIGINT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (follower_id, target_type, target_id),
    deleted_at TIMESTAMPTZ
);

COMMENT ON TABLE social.follows IS 'Подписки пользователей на различные объекты';

CREATE INDEX idx_follows_follower ON social.follows(follower_id);
CREATE INDEX idx_follows_target ON social.follows(target_type, target_id);

-- =====================================================
-- Схема: moderation
-- =====================================================
CREATE TABLE moderation.moderation_statuses (
    status_id VARCHAR(20) PRIMARY KEY
);

COMMENT ON TABLE moderation.moderation_statuses IS 'Статусы модерации';

CREATE TABLE moderation.reasons (
    reason_id VARCHAR(20) PRIMARY KEY
);

COMMENT ON TABLE moderation.reasons IS 'Причины жалоб';

INSERT INTO moderation.reasons VALUES 
    ('initial filling'),
    ('spam'),
    ('offensive'),
    ('incorrect');

CREATE TABLE moderation.moderations (
    moderation_id BIGSERIAL PRIMARY KEY,
    target_type VARCHAR(50) NOT NULL,   -- 'messages', 'reviews', 'coffee', 'location', 'organization', 'farm_detail', 'roaster_detail', 'variety', 'green_bean', 'grinder', 'brewer', 'waters', 'grinders', 'brewers', 'flavours', 'tags'
    target_id BIGINT NOT NULL,
    complainer_id BIGINT REFERENCES users.users(user_id),
    reason VARCHAR(50) NOT NULL REFERENCES moderation.reasons(reason_id),
    description TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'pending' REFERENCES moderation.moderation_statuses(status_id),
    moderated_by BIGINT REFERENCES users.users(user_id),
    moderated_at TIMESTAMPTZ,
    moderation_comment TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    UNIQUE (target_type, target_id, complainer_id)
);

COMMENT ON TABLE moderation.moderations IS 'Модерация различных объектов';

CREATE INDEX idx_moderations_target ON moderation.moderations(target_type, target_id);
CREATE INDEX idx_moderations_status ON moderation.moderations(status);

-- =====================================================
-- Дополнительные комментарии (если требуется)
-- =====================================================
COMMENT ON TABLE geography.locations IS 'Географические объекты (части света, страны, регионы, местности, города)';
COMMENT ON TABLE organizations.organizations IS 'Организации-участники рынка (фермы, экспортёры, импортёры, обжарщики)';
COMMENT ON TABLE organizations.organization_type_dict IS 'Справочник типов организаций';
COMMENT ON TABLE organizations.organization_types IS 'Связь организации с её типами (many-to-many)';
COMMENT ON TABLE organizations.farm_details IS 'Детальная информация о фермах';
COMMENT ON TABLE organizations.roaster_details IS 'Детальная информация об обжарщиках';
COMMENT ON TABLE users.users IS 'Пользователи системы (ссылка на location)';
COMMENT ON TABLE users.role_dict IS 'Справочник ролей пользователей';
COMMENT ON TABLE users.user_roles IS 'Роли пользователей (many-to-many)';
COMMENT ON TABLE social.follows IS 'Подписки пользователей на различные объекты';
