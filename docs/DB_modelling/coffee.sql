CREATE TABLE "world_parts" (
  "world_part_id" SMALLINT PRIMARY KEY,
  "name" "VARCHAR(50)" UNIQUE NOT NULL
);

CREATE TABLE "countries" (
  "country_code" "CHAR(2)" PRIMARY KEY,
  "country" "VARCHAR(100)" NOT NULL,
  "world_part_id" SMALLINT NOT NULL,
  "is_coffee_growing" BOOLEAN DEFAULT false
);

CREATE TABLE "regions" (
  "region_id" SMALLINT PRIMARY KEY,
  "region" "VARCHAR(100)" NOT NULL,
  "country_code" "CHAR(2)" NOT NULL
);

CREATE TABLE "localities" (
  "locality_id" INTEGER PRIMARY KEY,
  "locality" "VARCHAR(100)" NOT NULL,
  "region_id" SMALLINT
);

CREATE TABLE "cities" (
  "city_id" INTEGER PRIMARY KEY,
  "city" "VARCHAR(100)" NOT NULL,
  "locality_id" INTEGER,
  "country_code" "CHAR(2)"
);

CREATE TABLE "farms" (
  "farm_id" BIGSERIAL PRIMARY KEY,
  "farm" "VARCHAR(200)" NOT NULL,
  "locality_id" INTEGER,
  "mill" "VARCHAR(200)",
  "cooperative" "VARCHAR(200)",
  "owner" "VARCHAR(200)",
  "coordinates" POINT,
  "story" TEXT,
  "internet_site" "VARCHAR(500)",
  "phone" "VARCHAR(30)",
  "followers" INTEGER DEFAULT 0
);

CREATE TABLE "exporters" (
  "exporter_id" BIGSERIAL PRIMARY KEY,
  "exporter" "VARCHAR(200)" NOT NULL,
  "internet_site" "VARCHAR(500)",
  "about" TEXT
);

CREATE TABLE "importers" (
  "importer_id" BIGSERIAL PRIMARY KEY,
  "importer" "VARCHAR(200)" NOT NULL,
  "internet_site" "VARCHAR(500)",
  "about" TEXT
);

CREATE TABLE "roasters" (
  "roaster_id" BIGSERIAL PRIMARY KEY,
  "roaster" "VARCHAR(200)" NOT NULL,
  "city_id" INTEGER,
  "internet_site" "VARCHAR(500)",
  "rating_spro" "DECIMAL(3,2)",
  "rating_filter" "DECIMAL(3,2)",
  "about" TEXT,
  "market_vol" SMALLINT,
  "avrg_self_Q" "DECIMAL(3,2)",
  "followers" INTEGER DEFAULT 0
);

CREATE TABLE "varieties" (
  "variety_id" INTEGER PRIMARY KEY,
  "variety" "VARCHAR(100)" UNIQUE NOT NULL,
  "species" "VARCHAR(100)" NOT NULL,
  "taste_description" TEXT,
  "history" TEXT,
  "origin_type" "VARCHAR(20)" NOT NULL
);

CREATE TABLE "variety_parents" (
  "variety_parents_id" INTEGER PRIMARY KEY,
  "variety_id" INTEGER NOT NULL,
  "parent_id" INTEGER NOT NULL,
  "parent_role" "VARCHAR(20)",
  "notes" TEXT
);

CREATE TABLE "green_beans" (
  "beans_id" BIGSERIAL PRIMARY KEY,
  "farm_id" BIGINT,
  "variety_id" INTEGER,
  "mix" BOOLEAN DEFAULT false,
  "process" "VARCHAR(100)",
  "height_min" SMALLINT,
  "height_max" SMALLINT,
  "description" TEXT,
  "followers" INTEGER DEFAULT 0
);

CREATE TABLE "users" (
  "user_id" BIGSERIAL PRIMARY KEY,
  "city_id" INTEGER,
  "username" "VARCHAR(50)" UNIQUE NOT NULL,
  "email" "VARCHAR(255)" UNIQUE NOT NULL,
  "password" "VARCHAR(255)",
  "provider" "VARCHAR(50)",
  "provider_id" "VARCHAR(255)",
  "avatar_url" "VARCHAR(500)",
  "avatar_img" BYTEA,
  "is_verified" BOOLEAN DEFAULT false,
  "language" "VARCHAR(10)" DEFAULT 'ru',
  "is_active" BOOLEAN DEFAULT true,
  "roles" "TEXT[]" DEFAULT (ARRAY['user']),
  "created_at" "TIMESTAMPTZ" NOT NULL DEFAULT (NOW()),
  "updated_at" "TIMESTAMPTZ",
  "following_count" INTEGER DEFAULT 0,
  "followers_count" INTEGER DEFAULT 0
);

CREATE TABLE "coffees" (
  "coffee_id" BIGSERIAL PRIMARY KEY,
  "created_at" "TIMESTAMPTZ" NOT NULL DEFAULT (NOW()),
  "created_by" BIGINT,
  "green_bean_id" BIGINT,
  "crop_year" SMALLINT,
  "crop_month" SMALLINT CHECK (crop_month BETWEEN 1 AND 12),
  "exporter_id" BIGINT,
  "importer_id" BIGINT,
  "roaster_id" BIGINT,
  "roasting_level" "VARCHAR(100)",
  "price" INTEGER,
  "weight" INTEGER,
  "price_250g" INTEGER,
  "price_1Kg" INTEGER,
  "currency" "CHAR(3)",
  "title" "VARCHAR(300)" NOT NULL,
  "description" TEXT,
  "q_grade" "DECIMAL(3,1)",
  "pack_image" BYTEA,
  "pack_url" "VARCHAR(500)",
  "url" "VARCHAR(500)",
  "updated_at" "TIMESTAMPTZ",
  "updated_by" BIGINT,
  "avg_rating" "DECIMAL(3,2)",
  "ratings_count" INTEGER DEFAULT 0,
  "reviews_count" INTEGER DEFAULT 0,
  "comments_count" INTEGER DEFAULT 0,
  "weighted_rate" "DECIMAL(5,2)"
);

CREATE TABLE "waters" (
  "water_id" BIGSERIAL PRIMARY KEY,
  "user_id" BIGINT,
  "name" "VARCHAR(100)" NOT NULL,
  "ppm" "DECIMAL(6,1)",
  "ph" "DECIMAL(3,1)",
  "kg" "DECIMAL(5,1)",
  "kh" "DECIMAL(5,1)",
  "recipe" TEXT,
  "is_public" BOOLEAN DEFAULT false,
  "created_at" "TIMESTAMPTZ" NOT NULL DEFAULT (NOW())
);

CREATE TABLE "grinders" (
  "grinder_id" INTEGER PRIMARY KEY,
  "grinder" "VARCHAR(200)" UNIQUE NOT NULL,
  "diam" SMALLINT,
  "type" "VARCHAR(100)",
  "scale_min" INTEGER,
  "scale_max" INTEGER,
  "scale_div" "DECIMAL(3,2)",
  "url" "VARCHAR(500)",
  "description" TEXT
);

CREATE TABLE "brewers" (
  "brewer_id" INTEGER PRIMARY KEY,
  "brewer" "VARCHAR(200)" UNIQUE NOT NULL,
  "type" "VARCHAR(100)",
  "url" "VARCHAR(500)",
  "description" TEXT
);

CREATE TABLE "reviews" (
  "review_id" BIGSERIAL PRIMARY KEY,
  "user_id" BIGINT,
  "coffee_id" BIGINT,
  "review" TEXT NOT NULL,
  "method" "VARCHAR(100)",
  "grinder_id" INTEGER,
  "brewer_id" INTEGER,
  "water_id" BIGINT,
  "brew_ratio" "VARCHAR(20)",
  "tds" "DECIMAL(4,2)",
  "extraction" "DECIMAL(4,1)",
  "brewing_recipe" TEXT,
  "taste_notes" TEXT,
  "created_at" "TIMESTAMPTZ" NOT NULL DEFAULT (NOW()),
  "updated_at" "TIMESTAMPTZ"
);

CREATE TABLE "ratings" (
  "user_id" BIGINT,
  "coffee_id" BIGINT,
  "mark_scale" SMALLINT,
  "mark" SMALLINT NOT NULL,
  "created_at" "TIMESTAMPTZ" NOT NULL DEFAULT (NOW()),
  "updated_at" "TIMESTAMPTZ",
  PRIMARY KEY ("user_id", "coffee_id")
);

CREATE TABLE "messages" (
  "message_id" BIGSERIAL PRIMARY KEY,
  "user_id" BIGINT,
  "parent_id" BIGINT,
  "review_id" BIGINT,
  "coffee_id" BIGINT,
  "message" TEXT NOT NULL,
  "created_at" "TIMESTAMPTZ" NOT NULL DEFAULT (NOW()),
  "updated_at" "TIMESTAMPTZ"
);

CREATE TABLE "flavours" (
  "flavour_id" INTEGER PRIMARY KEY,
  "flavour_weel" "VARCHAR(100)" UNIQUE NOT NULL,
  "description" TEXT
);

CREATE TABLE "coffee_flavours" (
  "flavour_id" INTEGER,
  "coffee_id" BIGINT,
  "weighted" "DECIMAL(5,2)",
  "counter" INTEGER DEFAULT 0,
  PRIMARY KEY ("flavour_id", "coffee_id")
);

CREATE TABLE "tags" (
  "tag_id" BIGSERIAL PRIMARY KEY,
  "tag" "VARCHAR(100)" UNIQUE NOT NULL,
  "counter" INTEGER DEFAULT 0
);

CREATE TABLE "coffee_tags" (
  "tag_id" BIGINT,
  "coffee_id" BIGINT,
  "counter" INTEGER DEFAULT 0,
  "weighted" "DECIMAL(5,2)",
  PRIMARY KEY ("tag_id", "coffee_id")
);

CREATE TABLE "follow_coffees" (
  "follower_id" BIGINT,
  "coffee_id" BIGINT,
  "created_at" "TIMESTAMPTZ" NOT NULL DEFAULT (NOW()),
  PRIMARY KEY ("follower_id", "coffee_id")
);

CREATE TABLE "follow_users" (
  "follower_id" BIGINT,
  "followee_id" BIGINT,
  "created_at" "TIMESTAMPTZ" NOT NULL DEFAULT (NOW()),
  CONSTRAINT "no_self_follow" CHECK (follower_id != followee_id),
  PRIMARY KEY ("follower_id", "followee_id")
);

CREATE TABLE "follow_roasters" (
  "follower_id" BIGINT,
  "roaster_id" BIGINT,
  "created_at" "TIMESTAMPTZ" NOT NULL DEFAULT (NOW()),
  PRIMARY KEY ("follower_id", "roaster_id")
);

CREATE TABLE "follow_farms" (
  "follower_id" BIGINT,
  "farm_id" BIGINT,
  "created_at" "TIMESTAMPTZ" NOT NULL DEFAULT (NOW()),
  PRIMARY KEY ("follower_id", "farm_id")
);

CREATE TABLE "follow_beans" (
  "follower_id" BIGINT,
  "bean_id" BIGINT,
  "created_at" "TIMESTAMPTZ" NOT NULL DEFAULT (NOW()),
  PRIMARY KEY ("follower_id", "bean_id")
);

CREATE TABLE "follow_answers" (
  "user_id" BIGINT,
  "message_id" BIGINT,
  "created_at" "TIMESTAMPTZ" NOT NULL DEFAULT (NOW()),
  PRIMARY KEY ("user_id", "message_id")
);

CREATE TABLE "follow_reviews" (
  "user_id" BIGINT,
  "review_id" BIGINT,
  "created_at" "TIMESTAMPTZ" NOT NULL DEFAULT (NOW()),
  PRIMARY KEY ("user_id", "review_id")
);

CREATE INDEX "idx_countries_world_part" ON "countries" ("world_part_id");

CREATE INDEX "idx_regions_country" ON "regions" ("country_code");

CREATE INDEX "idx_localities_region" ON "localities" ("region_id");

CREATE INDEX "idx_cities_locality" ON "cities" ("locality_id");

CREATE INDEX "idx_cities_country" ON "cities" ("country_code");

CREATE INDEX "idx_farms_locality" ON "farms" ("locality_id");

CREATE INDEX "idx_roasters_city" ON "roasters" ("city_id");

CREATE UNIQUE INDEX ON "variety_parents" ("variety_id", "parent_id");

CREATE INDEX "idx_green_beans_farm" ON "green_beans" ("farm_id");

CREATE INDEX "idx_green_beans_variety" ON "green_beans" ("variety_id");

CREATE INDEX "idx_users_city" ON "users" ("city_id");

CREATE INDEX "idx_coffees_green_bean" ON "coffees" ("green_bean_id");

CREATE INDEX "idx_coffees_roaster" ON "coffees" ("roaster_id");

CREATE INDEX "idx_coffees_exporter" ON "coffees" ("exporter_id");

CREATE INDEX "idx_coffees_importer" ON "coffees" ("importer_id");

CREATE INDEX "idx_coffees_created_by" ON "coffees" ("created_by");

CREATE INDEX "idx_coffees_roaster_rating" ON "coffees" ("roaster_id", "avg_rating");

CREATE INDEX "idx_coffees_created_rating" ON "coffees" ("created_at", "avg_rating");

CREATE INDEX "idx_waters_user" ON "waters" ("user_id");

CREATE INDEX "idx_reviews_user" ON "reviews" ("user_id");

CREATE INDEX "idx_reviews_coffee" ON "reviews" ("coffee_id");

CREATE INDEX "idx_reviews_grinder" ON "reviews" ("grinder_id");

CREATE INDEX "idx_reviews_brewer" ON "reviews" ("brewer_id");

CREATE INDEX "idx_reviews_water" ON "reviews" ("water_id");

CREATE INDEX "idx_reviews_created" ON "reviews" ("created_at");

CREATE INDEX "idx_ratings_coffee_mark" ON "ratings" ("coffee_id", "mark");

CREATE INDEX "idx_messages_user" ON "messages" ("user_id");

CREATE INDEX "idx_messages_parent" ON "messages" ("parent_id");

CREATE INDEX "idx_messages_review" ON "messages" ("review_id");

CREATE INDEX "idx_messages_coffee" ON "messages" ("coffee_id");

COMMENT ON TABLE "world_parts" IS 'Части света';

COMMENT ON TABLE "countries" IS 'Страны мира';

COMMENT ON TABLE "regions" IS 'Регионы/штаты';

COMMENT ON TABLE "localities" IS 'Местности/районы';

COMMENT ON TABLE "cities" IS 'Города';

COMMENT ON TABLE "farms" IS 'Фермы производителей кофе';

COMMENT ON TABLE "exporters" IS 'Компании-экспортёры';

COMMENT ON TABLE "importers" IS 'Компании-импортёры';

COMMENT ON TABLE "roasters" IS 'Обжарщики кофе';

COMMENT ON TABLE "varieties" IS 'Сорта кофе';

COMMENT ON TABLE "variety_parents" IS 'Связь сорта с его предками';

COMMENT ON TABLE "green_beans" IS 'Партии зеленого зерна';

COMMENT ON TABLE "users" IS 'Пользователи системы';

COMMENT ON TABLE "coffees" IS 'Обжаренный кофе';

COMMENT ON TABLE "waters" IS 'Профили воды для заваривания';

COMMENT ON TABLE "grinders" IS 'Кофемолки';

COMMENT ON TABLE "brewers" IS 'Заварочные устройства';

COMMENT ON TABLE "reviews" IS 'Отзывы на кофе';

COMMENT ON TABLE "ratings" IS 'Оценки кофе пользователями';

COMMENT ON TABLE "messages" IS 'Сообщения и комментарии';

COMMENT ON TABLE "flavours" IS 'Вкусы из кофейного колеса';

COMMENT ON TABLE "coffee_flavours" IS 'Связь кофе с вкусами';

COMMENT ON TABLE "tags" IS 'Пользовательские теги';

COMMENT ON TABLE "coffee_tags" IS 'Связь кофе с тегами';

COMMENT ON TABLE "follow_coffees" IS 'Подписки на кофе';

COMMENT ON TABLE "follow_users" IS 'Подписки на пользователей';

COMMENT ON TABLE "follow_roasters" IS 'Подписки на обжарщиков';

COMMENT ON TABLE "follow_farms" IS 'Подписки на фермы';

COMMENT ON TABLE "follow_beans" IS 'Подписки на партии зерна';

COMMENT ON TABLE "follow_answers" IS 'Подписки на сообщения';

COMMENT ON TABLE "follow_reviews" IS 'Подписки на отзывы';

ALTER TABLE "countries" ADD FOREIGN KEY ("world_part_id") REFERENCES "world_parts" ("world_part_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "regions" ADD FOREIGN KEY ("country_code") REFERENCES "countries" ("country_code") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "localities" ADD FOREIGN KEY ("region_id") REFERENCES "regions" ("region_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "cities" ADD FOREIGN KEY ("locality_id") REFERENCES "localities" ("locality_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "cities" ADD FOREIGN KEY ("country_code") REFERENCES "countries" ("country_code") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "farms" ADD FOREIGN KEY ("locality_id") REFERENCES "localities" ("locality_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "roasters" ADD FOREIGN KEY ("city_id") REFERENCES "cities" ("city_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "green_beans" ADD FOREIGN KEY ("farm_id") REFERENCES "farms" ("farm_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "green_beans" ADD FOREIGN KEY ("variety_id") REFERENCES "varieties" ("variety_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "users" ADD FOREIGN KEY ("city_id") REFERENCES "cities" ("city_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "coffees" ADD FOREIGN KEY ("created_by") REFERENCES "users" ("user_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "coffees" ADD FOREIGN KEY ("green_bean_id") REFERENCES "green_beans" ("beans_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "coffees" ADD FOREIGN KEY ("exporter_id") REFERENCES "exporters" ("exporter_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "coffees" ADD FOREIGN KEY ("importer_id") REFERENCES "importers" ("importer_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "coffees" ADD FOREIGN KEY ("roaster_id") REFERENCES "roasters" ("roaster_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "coffees" ADD FOREIGN KEY ("updated_by") REFERENCES "users" ("user_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "waters" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("user_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "reviews" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("user_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "reviews" ADD FOREIGN KEY ("coffee_id") REFERENCES "coffees" ("coffee_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "reviews" ADD FOREIGN KEY ("grinder_id") REFERENCES "grinders" ("grinder_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "reviews" ADD FOREIGN KEY ("brewer_id") REFERENCES "brewers" ("brewer_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "reviews" ADD FOREIGN KEY ("water_id") REFERENCES "waters" ("water_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "ratings" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("user_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "ratings" ADD FOREIGN KEY ("coffee_id") REFERENCES "coffees" ("coffee_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "messages" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("user_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "messages" ADD FOREIGN KEY ("parent_id") REFERENCES "messages" ("message_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "messages" ADD FOREIGN KEY ("review_id") REFERENCES "reviews" ("review_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "messages" ADD FOREIGN KEY ("coffee_id") REFERENCES "coffees" ("coffee_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "coffee_flavours" ADD FOREIGN KEY ("flavour_id") REFERENCES "flavours" ("flavour_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "coffee_flavours" ADD FOREIGN KEY ("coffee_id") REFERENCES "coffees" ("coffee_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "coffee_tags" ADD FOREIGN KEY ("tag_id") REFERENCES "tags" ("tag_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "coffee_tags" ADD FOREIGN KEY ("coffee_id") REFERENCES "coffees" ("coffee_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "follow_coffees" ADD FOREIGN KEY ("follower_id") REFERENCES "users" ("user_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "follow_coffees" ADD FOREIGN KEY ("coffee_id") REFERENCES "coffees" ("coffee_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "follow_users" ADD FOREIGN KEY ("follower_id") REFERENCES "users" ("user_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "follow_users" ADD FOREIGN KEY ("followee_id") REFERENCES "users" ("user_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "follow_roasters" ADD FOREIGN KEY ("follower_id") REFERENCES "users" ("user_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "follow_roasters" ADD FOREIGN KEY ("roaster_id") REFERENCES "roasters" ("roaster_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "follow_farms" ADD FOREIGN KEY ("follower_id") REFERENCES "users" ("user_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "follow_farms" ADD FOREIGN KEY ("farm_id") REFERENCES "farms" ("farm_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "follow_beans" ADD FOREIGN KEY ("follower_id") REFERENCES "users" ("user_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "follow_beans" ADD FOREIGN KEY ("bean_id") REFERENCES "green_beans" ("beans_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "follow_answers" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("user_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "follow_answers" ADD FOREIGN KEY ("message_id") REFERENCES "messages" ("message_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "follow_reviews" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("user_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "follow_reviews" ADD FOREIGN KEY ("review_id") REFERENCES "reviews" ("review_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "variety_parents" ADD FOREIGN KEY ("variety_id") REFERENCES "varieties" ("variety_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "variety_parents" ADD FOREIGN KEY ("parent_id") REFERENCES "varieties" ("variety_id") DEFERRABLE INITIALLY IMMEDIATE;
