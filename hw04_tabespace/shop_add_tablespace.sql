-- Предварительно надо подключиться под пользоваталем postgres и дать
-- права суперпользователя пользоватею sergey выполнив
-- ALTER ROLE sergey SUPERUSER;

-- Создание отдельного табличного пространсва на SSD для хранения индексов
CREATE TABLESPACE fastspace OWNER sergey LOCATION '/var/lib/postgresql';

-- Создание отдельной схемы для расположения в ней таблиц содержащих персональные данные (ФИО, электронная почта, адрес, номер телефона)
CREATE SCHEMA private;

-- категория продуктов(ID, название категории)
CREATE TABLE ProductCategory (
    Id INT PRIMARY KEY,
    Name TEXT NOT NULL
);

-- производитель продуктов(ID, название, контактные данные)
CREATE TABLE private.Producer (
    Id INT PRIMARY KEY,
    Name TEXT NOT NULL,
    Email TEXT NOT NULL,
    Address TEXT NOT NULL,
    ContactNumber TEXT NOT NULL
);

-- поставщик продуктов(ID, название, контактные данные)
CREATE TABLE private.Provider (
    Id INT PRIMARY KEY,
    Name TEXT NOT NULL,
    Email TEXT NOT NULL,
    Address TEXT NOT NULL,
    ContactNumber TEXT NOT NULL
);

-- продукт(ID, название, описание, цена, категория, производитель)
-- ProducerID связь один-ко-многим, так как один продукт может быть
-- произвден только один конкретным производителем
CREATE TABLE Product (
    Id INT PRIMARY KEY,
    Name TEXT NOT NULL,
    Description TEXT NOT NULL,
    Price INT NOT NULL,
    ProducerID INT references private.Producer(Id)
);

-- связь поставщика продукта с продуктом многие-ко-многим, так как 
-- один и тот же продукт может поставляться разными поставщиками и 
-- соответственно разные поставщики могут поставлять один и тот же продукт
CREATE TABLE ProviderToProduct (
    ProductID INT references Product(Id),
    ProviderID INT references private.Provider(Id),
    PRIMARY KEY(ProductID, ProviderID)
);

-- связь категории продукта с продуктом многие-ко-многим, так как 
-- один и тот же продукт может входить в разные категории и 
-- соответственно разные категории могут содержать один и тот же продукт
CREATE TABLE CategoryToProduct (
    ProductID INT references Product(Id),
    CategoryID INT references ProductCategory(Id),
    PRIMARY KEY(ProductID, CategoryID)
);

-- покупатель (ID, имя, контактные данные)
CREATE TABLE private.Customer (
    Id INT PRIMARY KEY,
    Name TEXT NOT NULL, 
    Email TEXT NOT NULL,
    Address TEXT NOT NULL,
    ContactNumber TEXT NOT NULL
);

-- заказ (ID заказа, ID покупателя, дата оформления заказа)
CREATE TABLE ShopOrder (
    Id INT PRIMARY KEY,
    CustomerID INT references private.Customer(Id),
    OrderDate TIMESTAMP WITH TIME ZONE NOT NULL
);

-- элемент заказа (ID, ID заказа, ID продукта, количество, итоговая цена)
-- если в заказе несколько товаров, то в рамках одного OrderID в таблице
-- ShopOrderItem будет создано несколько строк с одним OrderID но разными ProductID
CREATE TABLE ShopOrderItem (
    Id INT PRIMARY KEY,
    OrderID INT references ShopOrder(Id),
    ProductID INT references Product(Id),
    Count INT NOT NULL,
    Price INT NOT NULL
);

-- ИНДЕКСЫ

-- индекс для фильтра/сортировки продуктов по цене
CREATE INDEX product_price_idx ON Product(Price) TABLESPACE fastspace;

-- индекс для фильтра/сортировки продуктов по производителям (и дополнительно по диапазону цен)
-- цена указана последней в индексе несмотря на то, что обладает большей кардинальностью
-- это обсуловлено поиском по диапазону цен, а не по конкретному значению
CREATE INDEX product_producer_price_idx ON Product(ProducerID, Price) TABLESPACE fastspace;

-- индекс для полтотекстового поиска продуктов по названию
CREATE INDEX product_name_en_idx ON Product USING GIN(to_tsvector('english', Name)) TABLESPACE fastspace;
CREATE INDEX product_name_ru_idx ON Product USING GIN(to_tsvector('russian', Name)) TABLESPACE fastspace;

-- индекс для фильтра продуктов по категориям
-- фактически это обратный индекс к индексу первичного ключа (ProductID, CategoryID)
CREATE INDEX categorytoproduct_category_idx ON CategoryToProduct(CategoryID) TABLESPACE fastspace;

-- индекс для фильтра продуктов по поставщикам
-- фактически это обратный индекс к индексу первичного ключа (ProductID, ProviderID)
CREATE INDEX providertoproduct_provider_idx ON ProviderToProduct(ProviderID) TABLESPACE fastspace;

-- индекс для фильтра/сортировки заказов по дате
CREATE INDEX shoporder_orderdate_idx ON ShopOrder(OrderDate) TABLESPACE fastspace;

-- индекс для фильтра заказов по покупателю (и дополнительно по диапазону дат)
-- дата указана последней в индексе несмотря на то, что обладает большей кардинальностью
-- это обсуловлено поиском по диапазону дат, а не по конкретному значению
CREATE INDEX shoporder_сustomer_orderdate_idx ON ShopOrder(CustomerID, OrderDate) TABLESPACE fastspace;



