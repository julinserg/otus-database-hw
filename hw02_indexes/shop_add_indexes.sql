-- категория продуктов(ID, название категории)
CREATE TABLE ProductCategory (
    Id INT PRIMARY KEY,
    Name TEXT
);

-- производитель продуктов(ID, название, контактные данные)
CREATE TABLE Producer (
    Id INT PRIMARY KEY,
    Name TEXT,
	Email TEXT,
    Address TEXT,
    ContactNumber TEXT
);

-- поставщик продуктов(ID, название, контактные данные)
CREATE TABLE Provider (
	Id INT PRIMARY KEY,
    Name TEXT,
	Email TEXT,
    Address TEXT,
    ContactNumber TEXT
);

-- продукт(ID, название, описание, цена, категория, производитель)
-- CategoryID связь один-ко-многим, так как один продукт может быть 
-- только в одной конкретнйо категории (продукты питания, товары для дома, автотовары)
-- ProducerID связь один-ко-многим, так как один продукт может быть
-- произвден только один конкретным производителем
CREATE TABLE Product (
    Id INT PRIMARY KEY,
    Name TEXT,
    Description TEXT,
	Price INT,
	CategoryID INT references ProductCategory(Id),
	ProducerID INT references Producer(Id)
);

-- связь поставщика продукта с продуктом многие-ко-многим, так как 
-- один и тот же продукт может поставляться разными поставщиками и 
-- соответсвенно разные поставщики могут поставлять один и тот же продукт
CREATE TABLE ProviderToProduct (
	ProductID INT references Product(Id),
    ProviderID INT references Provider(Id),
	PRIMARY KEY(ProductID, ProviderID)
);

-- покупатель (ID, имя, контактные данные)
CREATE TABLE Customer (
    Id INT PRIMARY KEY,
    Name TEXT, 
    Email TEXT,
    Address TEXT,
    ContactNumber TEXT
);

-- заказ (ID заказа, ID покупателя, дата оформления заказа)
CREATE TABLE ShopOrder (
    Id INT PRIMARY KEY,
    CustomerID INT references Customer(Id),
    OrderDate TIMESTAMP
);

-- элемент заказа (ID, ID заказа, ID продукта, количество, итоговая цена)
-- если в заказе несколько товаров, то в рамках одного OrderID в таблице
-- ShopOrderItem будет создано несколько строк с одним OrderID но разными ProductID
CREATE TABLE ShopOrderItem (
    Id INT PRIMARY KEY,
    OrderID INT references ShopOrder(Id),
    ProductID INT references Product(Id),
    Count INT,
    Price INT
);


