SET search_path TO geography, organizations, users, coffee, equipment, social, moderation, public;

SHOW search_path;

-- =====================================================
-- Схема: geography
-- =====================================================
INSERT INTO geography.locations (name, location_type, parent_id, country_code, is_coffee_growing, created_at)
VALUES
    ('PLanet', 'world_part', 1, NULL, DEFAULT, NOW()),
    ('Africa', 'world_part', 1, NULL, DEFAULT, NOW()),
    ('Africa', 'world_part', 1, NULL, DEFAULT, NOW()),
    ('Asia', 'world_part', 1, NULL, DEFAULT, NOW()),
    ('Europe', 'world_part', 1, NULL, DEFAULT, NOW()),
    ('North America', 'world_part', 1, NULL, DEFAULT, NOW()),
    ('Central America', 'world_part', 1, NULL, DEFAULT, NOW()),  -- ключевой кофейный регион
    ('South America', 'world_part', 1, NULL, DEFAULT, NOW()),    -- ключевой кофейный регион
    ('Australia and Oceania', 'world_part', 1, NULL, DEFAULT, NOW())
RETURNING location_id, name, is_coffee_growing;

-- Получение ID для дальнейшего использования (например, для вставки стран)
-- SELECT location_id, name FROM geography.locations WHERE location_type = 'world_part';

-- Вставка стран с указанием части света (parent_id) и признаком кофепроизводства
-- Предварительно получим ID частей света (предполагается, что они уже вставлены)

DO $$
DECLARE
    africa_id BIGINT;
    asia_id BIGINT;
    europe_id BIGINT;
    north_america_id BIGINT;
    central_america_id BIGINT;
    south_america_id BIGINT;
    oceania_id BIGINT;
BEGIN
    -- Получаем ID частей света по названиям
    SELECT location_id INTO africa_id FROM geography.locations WHERE name = 'Africa' AND location_type = 'world_part';
    SELECT location_id INTO asia_id FROM geography.locations WHERE name = 'Asia' AND location_type = 'world_part';
    SELECT location_id INTO europe_id FROM geography.locations WHERE name = 'Europe' AND location_type = 'world_part';
    SELECT location_id INTO north_america_id FROM geography.locations WHERE name = 'North America' AND location_type = 'world_part';
    SELECT location_id INTO central_america_id FROM geography.locations WHERE name = 'Central America' AND location_type = 'world_part';
    SELECT location_id INTO south_america_id FROM geography.locations WHERE name = 'South America' AND location_type = 'world_part';
    SELECT location_id INTO oceania_id FROM geography.locations WHERE name = 'Australia and Oceania' AND location_type = 'world_part';

    -- Вставка стран Африки
    INSERT INTO geography.locations (name, location_type, parent_id, country_code, is_coffee_growing, created_at) VALUES
    ('Algeria', 'country', africa_id, 'DZ', false, NOW()),
    ('Angola', 'country', africa_id, 'AO', false, NOW()),
    ('Benin', 'country', africa_id, 'BJ', false, NOW()),
    ('Botswana', 'country', africa_id, 'BW', false, NOW()),
    ('Burkina Faso', 'country', africa_id, 'BF', false, NOW()),
    ('Burundi', 'country', africa_id, 'BI', true, NOW()),
    ('Cabo Verde', 'country', africa_id, 'CV', false, NOW()),
    ('Cameroon', 'country', africa_id, 'CM', true, NOW()),
    ('Central African Republic', 'country', africa_id, 'CF', false, NOW()),
    ('Chad', 'country', africa_id, 'TD', false, NOW()),
    ('Comoros', 'country', africa_id, 'KM', false, NOW()),
    ('Congo', 'country', africa_id, 'CG', false, NOW()),
    ('Côte d''Ivoire', 'country', africa_id, 'CI', true, NOW()),
    ('Djibouti', 'country', africa_id, 'DJ', false, NOW()),
    ('Egypt', 'country', africa_id, 'EG', false, NOW()),
    ('Equatorial Guinea', 'country', africa_id, 'GQ', true, NOW()),
    ('Eritrea', 'country', africa_id, 'ER', false, NOW()),
    ('Eswatini', 'country', africa_id, 'SZ', false, NOW()),
    ('Ethiopia', 'country', africa_id, 'ET', true, NOW()),
    ('Gabon', 'country', africa_id, 'GA', false, NOW()),
    ('Gambia', 'country', africa_id, 'GM', false, NOW()),
    ('Ghana', 'country', africa_id, 'GH', false, NOW()),
    ('Guinea', 'country', africa_id, 'GN', false, NOW()),
    ('Guinea-Bissau', 'country', africa_id, 'GW', false, NOW()),
    ('Kenya', 'country', africa_id, 'KE', true, NOW()),
    ('Lesotho', 'country', africa_id, 'LS', false, NOW()),
    ('Liberia', 'country', africa_id, 'LR', true, NOW()),
    ('Libya', 'country', africa_id, 'LY', false, NOW()),
    ('Madagascar', 'country', africa_id, 'MG', false, NOW()),
    ('Malawi', 'country', africa_id, 'MW', false, NOW()),
    ('Mali', 'country', africa_id, 'ML', false, NOW()),
    ('Mauritania', 'country', africa_id, 'MR', false, NOW()),
    ('Mauritius', 'country', africa_id, 'MU', false, NOW()),
    ('Morocco', 'country', africa_id, 'MA', false, NOW()),
    ('Mozambique', 'country', africa_id, 'MZ', false, NOW()),
    ('Namibia', 'country', africa_id, 'NA', false, NOW()),
    ('Niger', 'country', africa_id, 'NE', false, NOW()),
    ('Nigeria', 'country', africa_id, 'NG', false, NOW()),
    ('Rwanda', 'country', africa_id, 'RW', true, NOW()),
    ('Sao Tome and Principe', 'country', africa_id, 'ST', false, NOW()),
    ('Senegal', 'country', africa_id, 'SN', false, NOW()),
    ('Seychelles', 'country', africa_id, 'SC', false, NOW()),
    ('Sierra Leone', 'country', africa_id, 'SL', false, NOW()),
    ('Somalia', 'country', africa_id, 'SO', false, NOW()),
    ('South Africa', 'country', africa_id, 'ZA', false, NOW()),
    ('South Sudan', 'country', africa_id, 'SS', false, NOW()),
    ('Sudan', 'country', africa_id, 'SD', false, NOW()),
    ('Tanzania', 'country', africa_id, 'TZ', true, NOW()),
    ('Togo', 'country', africa_id, 'TG', false, NOW()),
    ('Tunisia', 'country', africa_id, 'TN', false, NOW()),
    ('Uganda', 'country', africa_id, 'UG', true, NOW()),
    ('Zambia', 'country', africa_id, 'ZM', false, NOW()),
    ('Zimbabwe', 'country', africa_id, 'ZW', false, NOW());

    -- Вставка стран Азии
    INSERT INTO geography.locations (name, location_type, parent_id, country_code, is_coffee_growing, created_at) VALUES
    ('Afghanistan', 'country', asia_id, 'AF', false, NOW()),
    ('Armenia', 'country', asia_id, 'AM', false, NOW()),
    ('Azerbaijan', 'country', asia_id, 'AZ', false, NOW()),
    ('Bahrain', 'country', asia_id, 'BH', false, NOW()),
    ('Bangladesh', 'country', asia_id, 'BD', false, NOW()),
    ('Bhutan', 'country', asia_id, 'BT', false, NOW()),
    ('Brunei', 'country', asia_id, 'BN', false, NOW()),
    ('Cambodia', 'country', asia_id, 'KH', false, NOW()),
    ('China', 'country', asia_id, 'CN', true, NOW()),
    ('Cyprus', 'country', asia_id, 'CY', false, NOW()),
    ('Georgia', 'country', asia_id, 'GE', false, NOW()),
    ('India', 'country', asia_id, 'IN', true, NOW()),
    ('Indonesia', 'country', asia_id, 'ID', true, NOW()),
    ('Iran', 'country', asia_id, 'IR', false, NOW()),
    ('Iraq', 'country', asia_id, 'IQ', false, NOW()),
    ('Israel', 'country', asia_id, 'IL', false, NOW()),
    ('Japan', 'country', asia_id, 'JP', false, NOW()),
    ('Jordan', 'country', asia_id, 'JO', false, NOW()),
    ('Kazakhstan', 'country', asia_id, 'KZ', false, NOW()),
    ('Kuwait', 'country', asia_id, 'KW', false, NOW()),
    ('Kyrgyzstan', 'country', asia_id, 'KG', false, NOW()),
    ('Laos', 'country', asia_id, 'LA', true, NOW()),
    ('Lebanon', 'country', asia_id, 'LB', false, NOW()),
    ('Malaysia', 'country', asia_id, 'MY', false, NOW()),
    ('Maldives', 'country', asia_id, 'MV', false, NOW()),
    ('Mongolia', 'country', asia_id, 'MN', false, NOW()),
    ('Myanmar', 'country', asia_id, 'MM', false, NOW()),
    ('Nepal', 'country', asia_id, 'NP', false, NOW()),
    ('North Korea', 'country', asia_id, 'KP', false, NOW()),
    ('Oman', 'country', asia_id, 'OM', false, NOW()),
    ('Pakistan', 'country', asia_id, 'PK', false, NOW()),
    ('Palestine', 'country', asia_id, 'PS', false, NOW()),
    ('Philippines', 'country', asia_id, 'PH', true, NOW()),
    ('Qatar', 'country', asia_id, 'QA', false, NOW()),
    ('Saudi Arabia', 'country', asia_id, 'SA', false, NOW()),
    ('Singapore', 'country', asia_id, 'SG', false, NOW()),
    ('South Korea', 'country', asia_id, 'KR', false, NOW()),
    ('Sri Lanka', 'country', asia_id, 'LK', false, NOW()),
    ('Syria', 'country', asia_id, 'SY', false, NOW()),
    ('Taiwan', 'country', asia_id, 'TW', false, NOW()),
    ('Tajikistan', 'country', asia_id, 'TJ', false, NOW()),
    ('Thailand', 'country', asia_id, 'TH', true, NOW()),
    ('Timor-Leste', 'country', asia_id, 'TL', true, NOW()),
    ('Turkey', 'country', asia_id, 'TR', false, NOW()),
    ('Turkmenistan', 'country', asia_id, 'TM', false, NOW()),
    ('United Arab Emirates', 'country', asia_id, 'AE', false, NOW()),
    ('Uzbekistan', 'country', asia_id, 'UZ', false, NOW()),
    ('Vietnam', 'country', asia_id, 'VN', true, NOW()),
    ('Yemen', 'country', asia_id, 'YE', true, NOW());

    -- Вставка стран Европы
    INSERT INTO geography.locations (name, location_type, parent_id, country_code, is_coffee_growing, created_at) VALUES
    ('Albania', 'country', europe_id, 'AL', false, NOW()),
    ('Andorra', 'country', europe_id, 'AD', false, NOW()),
    ('Austria', 'country', europe_id, 'AT', false, NOW()),
    ('Belarus', 'country', europe_id, 'BY', false, NOW()),
    ('Belgium', 'country', europe_id, 'BE', false, NOW()),
    ('Bosnia and Herzegovina', 'country', europe_id, 'BA', false, NOW()),
    ('Bulgaria', 'country', europe_id, 'BG', false, NOW()),
    ('Croatia', 'country', europe_id, 'HR', false, NOW()),
    ('Czech Republic', 'country', europe_id, 'CZ', false, NOW()),
    ('Denmark', 'country', europe_id, 'DK', false, NOW()),
    ('Estonia', 'country', europe_id, 'EE', false, NOW()),
    ('Finland', 'country', europe_id, 'FI', false, NOW()),
    ('France', 'country', europe_id, 'FR', false, NOW()),
    ('Germany', 'country', europe_id, 'DE', false, NOW()),
    ('Greece', 'country', europe_id, 'GR', false, NOW()),
    ('Hungary', 'country', europe_id, 'HU', false, NOW()),
    ('Iceland', 'country', europe_id, 'IS', false, NOW()),
    ('Ireland', 'country', europe_id, 'IE', false, NOW()),
    ('Italy', 'country', europe_id, 'IT', false, NOW()),
    ('Kosovo', 'country', europe_id, 'XK', false, NOW()),
    ('Latvia', 'country', europe_id, 'LV', false, NOW()),
    ('Liechtenstein', 'country', europe_id, 'LI', false, NOW()),
    ('Lithuania', 'country', europe_id, 'LT', false, NOW()),
    ('Luxembourg', 'country', europe_id, 'LU', false, NOW()),
    ('Malta', 'country', europe_id, 'MT', false, NOW()),
    ('Moldova', 'country', europe_id, 'MD', false, NOW()),
    ('Monaco', 'country', europe_id, 'MC', false, NOW()),
    ('Montenegro', 'country', europe_id, 'ME', false, NOW()),
    ('Netherlands', 'country', europe_id, 'NL', false, NOW()),
    ('North Macedonia', 'country', europe_id, 'MK', false, NOW()),
    ('Norway', 'country', europe_id, 'NO', false, NOW()),
    ('Poland', 'country', europe_id, 'PL', false, NOW()),
    ('Portugal', 'country', europe_id, 'PT', false, NOW()),
    ('Romania', 'country', europe_id, 'RO', false, NOW()),
    ('Russia', 'country', europe_id, 'RU', false, NOW()),
    ('San Marino', 'country', europe_id, 'SM', false, NOW()),
    ('Serbia', 'country', europe_id, 'RS', false, NOW()),
    ('Slovakia', 'country', europe_id, 'SK', false, NOW()),
    ('Slovenia', 'country', europe_id, 'SI', false, NOW()),
    ('Spain', 'country', europe_id, 'ES', false, NOW()),
    ('Sweden', 'country', europe_id, 'SE', false, NOW()),
    ('Switzerland', 'country', europe_id, 'CH', false, NOW()),
    ('Ukraine', 'country', europe_id, 'UA', false, NOW()),
    ('United Kingdom', 'country', europe_id, 'GB', false, NOW()),
    ('Vatican City', 'country', europe_id, 'VA', false, NOW());

    -- Вставка стран Северной Америки
    INSERT INTO geography.locations (name, location_type, parent_id, country_code, is_coffee_growing, created_at) VALUES
    ('Antigua and Barbuda', 'country', north_america_id, 'AG', false, NOW()),
    ('Bahamas', 'country', north_america_id, 'BS', false, NOW()),
    ('Barbados', 'country', north_america_id, 'BB', false, NOW()),
    ('Belize', 'country', north_america_id, 'BZ', false, NOW()),
    ('Canada', 'country', north_america_id, 'CA', false, NOW()),
    ('Costa Rica', 'country', central_america_id, 'CR', true, NOW()),
    ('Cuba', 'country', north_america_id, 'CU', true, NOW()),
    ('Dominica', 'country', north_america_id, 'DM', false, NOW()),
    ('Dominican Republic', 'country', north_america_id, 'DO', true, NOW()),
    ('El Salvador', 'country', central_america_id, 'SV', true, NOW()),
    ('Grenada', 'country', north_america_id, 'GD', false, NOW()),
    ('Guatemala', 'country', central_america_id, 'GT', true, NOW()),
    ('Haiti', 'country', north_america_id, 'HT', true, NOW()),
    ('Honduras', 'country', central_america_id, 'HN', true, NOW()),
    ('Jamaica', 'country', north_america_id, 'JM', true, NOW()),
    ('Mexico', 'country', central_america_id, 'MX', true, NOW()),
    ('Nicaragua', 'country', central_america_id, 'NI', true, NOW()),
    ('Panama', 'country', central_america_id, 'PA', true, NOW()),
    ('Saint Kitts and Nevis', 'country', north_america_id, 'KN', false, NOW()),
    ('Saint Lucia', 'country', north_america_id, 'LC', false, NOW()),
    ('Saint Vincent and the Grenadines', 'country', north_america_id, 'VC', false, NOW()),
    ('Trinidad and Tobago', 'country', north_america_id, 'TT', false, NOW()),
    ('United States', 'country', north_america_id, 'US', false, NOW());

    -- Вставка стран Южной Америки
    INSERT INTO geography.locations (name, location_type, parent_id, country_code, is_coffee_growing, created_at) VALUES
    ('Argentina', 'country', south_america_id, 'AR', false, NOW()),
    ('Bolivia', 'country', south_america_id, 'BO', true, NOW()),
    ('Brazil', 'country', south_america_id, 'BR', true, NOW()),
    ('Chile', 'country', south_america_id, 'CL', false, NOW()),
    ('Colombia', 'country', south_america_id, 'CO', true, NOW()),
    ('Ecuador', 'country', south_america_id, 'EC', true, NOW()),
    ('Guyana', 'country', south_america_id, 'GY', false, NOW()),
    ('Paraguay', 'country', south_america_id, 'PY', false, NOW()),
    ('Peru', 'country', south_america_id, 'PE', true, NOW()),
    ('Suriname', 'country', south_america_id, 'SR', false, NOW()),
    ('Uruguay', 'country', south_america_id, 'UY', false, NOW()),
    ('Venezuela', 'country', south_america_id, 'VE', true, NOW());

    -- Вставка стран Австралии и Океании
    INSERT INTO geography.locations (name, location_type, parent_id, country_code, is_coffee_growing, created_at) VALUES
    ('Australia', 'country', oceania_id, 'AU', false, NOW()),
    ('Fiji', 'country', oceania_id, 'FJ', false, NOW()),
    ('Kiribati', 'country', oceania_id, 'KI', false, NOW()),
    ('Marshall Islands', 'country', oceania_id, 'MH', false, NOW()),
    ('Micronesia', 'country', oceania_id, 'FM', false, NOW()),
    ('Nauru', 'country', oceania_id, 'NR', false, NOW()),
    ('New Zealand', 'country', oceania_id, 'NZ', false, NOW()),
    ('Palau', 'country', oceania_id, 'PW', false, NOW()),
    ('Papua New Guinea', 'country', oceania_id, 'PG', true, NOW()),
    ('Samoa', 'country', oceania_id, 'WS', false, NOW()),
    ('Solomon Islands', 'country', oceania_id, 'SB', false, NOW()),
    ('Tonga', 'country', oceania_id, 'TO', false, NOW()),
    ('Tuvalu', 'country', oceania_id, 'TV', false, NOW()),
    ('Vanuatu', 'country', oceania_id, 'VU', false, NOW());

END $$;

-- Проверка количества стран по частям света
SELECT 
    parent.name AS world_part,
    COUNT(child.location_id) AS country_count,
    SUM(CASE WHEN child.is_coffee_growing THEN 1 ELSE 0 END) AS coffee_countries
FROM geography.locations child
JOIN geography.locations parent ON child.parent_id = parent.location_id
WHERE child.location_type = 'country'
GROUP BY parent.name
ORDER BY parent.name;

-- Проверка уникальности country_code (не должно быть дубликатов)
SELECT country_code, COUNT(*) 
FROM geography.locations 
WHERE location_type = 'country' 
GROUP BY country_code 
HAVING COUNT(*) > 1;




-- =====================================================
-- Схема: moderation
-- =====================================================
INSERT INTO moderation.moderation_statuses VALUES 
    ('pending'),
    ('approved'),
    ('rejected');