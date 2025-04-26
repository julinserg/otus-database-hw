INSERT INTO productcategory (id, name)
VALUES
(1, 'Компьютерная техника'),
(2, 'Офис и канцелярия'),
(3, 'Мелкая бытовая техника');

TRUNCATE private.producer cascade
INSERT INTO private.producer (id, name, email, address, contactnumber)
VALUES
(1, 'Dewal', 'Dewal@gmail.com','Dewal Streat','89054567832'),
(2, 'HP','HP@gmail.com','HP Streat','1234567890'),
(3, 'Gastrorag','Gastrorag@gmail.com','Gastrorag Streat','XX0987654321'),
(4, 'Asus','Asus@gmail.com','Asus Streat','111222333444'),
(5, 'KitchenAid','KitchenAid@gmail.com','KitchenAid Streat','KitchenAid Phone');

INSERT INTO product (id, name, description, price, producerid)
VALUES
(1, 'Кухонный комбайн KitchenAid 5KSM156', 'Кухонный комбайн', 15000, 5),
(2, 'Видеокарта Asus GeForce GT 1030','Видеокарта', 5000, 4),
(3, 'Ноутбук HP ENVY 13-ad000','Ноутбук', 80000, 2),
(4, 'Фен Dewal 03-401','Фен', 4000, 1),
(5, 'Кофеварка Gastrorag CM-717','Кофеварка', 25000, 3),
(6, 'Видеокарта Asus GeForce RTX 3060','Видеокарта', 45000, 4),
(7, 'Видеокарта Asus GeForce RTX 4090','Видеокарта', 80000, 4);

INSERT INTO categorytoproduct (productid, categoryid)
VALUES
(1, 3),
(2, 1),
(3, 1),
(4, 3),
(5, 3),
(6, 1);

-- выбираем валидные номера телефонов состоящие из цифр от 0 до 9 и длиной 10 или 11 символов
SELECT * 
FROM private.producer
WHERE contactnumber similar to '[0-9]{10,11}'

-- выбираем все товары с привязкой к категории товара 
-- LEFT JOIN выдает все товары из product (7 штук), даже те у которых не указана категория
-- то есть соответсвующей записи нет в таблице categorytoproduct
SELECT product.*, productcategory.name as category_name  
FROM product
LEFT JOIN categorytoproduct ON product.id = categorytoproduct.productid 
LEFT JOIN productcategory ON categoryid = productcategory.id

-- выбираем все товары с привязкой к категории товара 
-- INNER JOIN выдает только те товары которые есть и в product и в categorytoproduct (6 штук)
SELECT product.*, productcategory.name as category_name  
FROM product
INNER JOIN categorytoproduct ON product.id = categorytoproduct.productid 
LEFT JOIN productcategory ON categoryid = productcategory.id


-- вставка с возвратом id
INSERT INTO product (id, name, description, price, producerid)
VALUES
(8, 'Видеокарта Asus GeForce RTX 5070','Видеокарта', 500000, 4)
RETURNING id;

-- обновление данных с использованием другой таблицы
-- в описание товаров вставим информацию о производителе
UPDATE product
SET description = product.description || ' Producer phone : ' || private.producer.contactnumber 
FROM private.producer
WHERE product.producerid = private.producer.id

-- удаление всех продуктов категории 3 (Мелкая бытовая техника)
ALTER TABLE CategoryToProduct
DROP CONSTRAINT categorytoproduct_productid_fkey;

ALTER TABLE CategoryToProduct
ADD CONSTRAINT categorytoproduct_productid_fkey
FOREIGN KEY (ProductID)
REFERENCES Product(Id)
ON DELETE CASCADE;
	  
DELETE
FROM product
USING categorytoproduct 
WHERE product.id = categorytoproduct.productid AND
      categorytoproduct.categoryid = 3;

























