-- очищаем таблицу product и ранее созданные индексы
TRUNCATE TABLE product cascade
DROP INDEX product_name_en_idx
DROP INDEX product_name_ru_idx
DROP INDEX product_price_idx
DROP INDEX product_producer_price_idx

-- вставляем в таблицу product валидные осмысленные данные
INSERT INTO product (id, name, description, price, producerid)
VALUES
(1, 'Кухонный комбайн KitchenAid 5KSM156', 'Кухонный комбайн', 15000, 5),
(2, 'Видеокарта Asus GeForce GT 1030','Видеокарта', 5000, 4),
(3, 'Ноутбук HP ENVY 13-ad000','Ноутбук', 80000, 2),
(4, 'Фен Dewal 03-401','Фен', 4000, 1),
(5, 'Кофеварка Gastrorag CM-717','Кофеварка', 25000, 3),
(6, 'Видеокарта Asus GeForce RTX 3060','Видеокарта', 45000, 4),
(7, 'Видеокарта Asus GeForce RTX 4090','Видеокарта', 80000, 4);

-- вставляем в таблицу product случайные сгенерированные данные (чтобы планировщик использовал индексы)
INSERT INTO product (id, name, description, price, producerid)
SELECT generate_series,
       substr(md5(random()::text), 1, 10) || substr(md5(random()::text), 1, 10) || substr(md5(random()::text), 1, 10),
       substr(md5(random()::text), 1, 10),
       (random() * 70 + 10)::integer,
       NULL
FROM generate_series(8, 1000000);

----------------------ПОЛНОТЕКСТОВЫЙ ПОИСК--------------------------------

-- выполянем полнотекстовый поиск по колонке name таблицы product - ищем товары по названию
explain analyze SELECT *
FROM product
WHERE to_tsvector('russian', name::text) @@ to_tsquery('russian','Видеокарта')
-- план
-- ->  Parallel Seq Scan on product  (cost=0.00..119685.00 rows=2083 width=54) (actual time=712.519..1079.178 rows=1 loops=3)
-- Execution Time: 1114.663 ms

-- создаем индекс для полнотекстового поиска
CREATE INDEX product_name_fts 
ON product 
USING gin (to_tsvector('russian', "name"));

-- выполянем полнотекстовый поиск по колонке name таблицы product - ищем товары по названию
explain analyze SELECT *
FROM product
WHERE to_tsvector('russian', name::text) @@ to_tsquery('russian','Видеокарта')
--  ->  Bitmap Index Scan on product_name_fts  (cost=0.00..61.50 rows=5000 width=0) (actual time=0.008..0.008 rows=3 loops=1)
--          Index Cond: (to_tsvector('russian'::regconfig, name) @@ '''видеокарт'''::tsquery)
--  Execution Time: 0.025 ms

----------------------ЧАСТИЧНЫЙ ИНДЕКС--------------------------------

-- выполянем поиск товаров с ценой больше 1000р
explain analyze SELECT *
FROM product
WHERE price > 1000
--   ->  Parallel Seq Scan on product  (cost=0.00..15518.33 rows=1 width=54) (actual time=25.938..47.071 rows=2 loops=3)
--   Execution Time: 74.557 ms

-- создаем индекс для товаров с ценой больше 1000
CREATE INDEX product_price_over_1000_idx 
ON product 
USING btree(price) WHERE price > 1000;

-- выполянем поиск товаров с ценой больше 1000р
explain analyze SELECT *
FROM product
WHERE price > 1000
-- Index Scan using product_price_over_1000_idx on product  (cost=0.13..8.15 rows=1 width=54) (actual time=0.009..0.011 rows=7 loops=1)
-- Execution Time: 0.021 ms

----------------------СОСТАВНОЙ ИНДЕКС--------------------------------

-- выполянем поиск товаров с ценой больше 500р от поставщика 4 (Asus)
explain analyze SELECT *
FROM product
WHERE price > 500 AND producerid = 4
--   ->  Parallel Seq Scan on product  (cost=0.00..16560.00 rows=1 width=54) (actual time=19.727..38.176 rows=1 loops=3)
--   Execution Time: 64.791 ms

-- создаем индекс для поиска товаров по цене и поставщику
CREATE INDEX product_price_and_producer_idx 
ON product 
USING btree(price, producerid);

-- выполянем поиск товаров с ценой больше 500р от поставщика 4 (Asus)
explain analyze SELECT *
FROM product
WHERE price > 500 AND producerid = 4
--  Index Scan using product_price_and_producer_idx on product  (cost=0.42..8.44 rows=1 width=54) (actual time=0.032..0.032 rows=3 loops=1)
--  Index Cond: ((price > 500) AND (producerid = 4))
--  Execution Time: 0.055 ms

