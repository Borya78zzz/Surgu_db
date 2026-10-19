/*
DROP TABLE IF EXISTS Order_Items;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Customers;


CREATE TABLE Customers (
    customer_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    registration_date DATE NOT NULL,
    recommended_by INT,
    FOREIGN KEY (recommended_by) REFERENCES Customers(customer_id)
);


CREATE TABLE Products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);

CREATE TABLE Orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT,
    order_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);


CREATE TABLE Order_Items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    price_per_unit DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);


INSERT INTO Customers (customer_id, full_name, email, registration_date, recommended_by) VALUES
(1, 'Иван Иванов', 'ivan.ivanov@example.com', '2023-01-15', NULL),
(2, 'Мария Петрова', 'maria.petrova@example.com', '2023-02-20', 1),
(3, 'Алексей Смирнов', 'alex.smirnov@example.com', '2023-03-10', 1),
(4, 'Елена Васильева', 'elena.v@example.com', '2023-04-01', 2),
(5, 'Андрей Николаев', 'andrey.n@example.com', '2023-05-01', NULL);

INSERT INTO Products (product_name, category, price) VALUES
('Смартфон', 'Электроника', 70000.00),
('Ноутбук', 'Электроника', 120000.00),
('Кофемашина', 'Бытовая техника', 25000.00),
('Книга "Основы SQL"', 'Книги', 1500.00),
('Фен', 'Бытовая техника', 4500.00),
('Пылесос', 'Бытовая техника', 15000.00);

INSERT INTO Orders (customer_id, order_date, status) VALUES
(1, '2024-05-10', 'Доставлен'),
(2, '2024-05-12', 'В обработке'),
(1, '2024-05-15', 'Отправлен'),
(3, '2024-05-16', 'Доставлен');

INSERT INTO Order_Items (order_id, product_id, quantity, price_per_unit) VALUES
(1, 1, 1, 70000.00),  -- Иван купил Смартфон
(1, 4, 2, 1400.00),   -- и 2 книги
(2, 2, 1, 120000.00), -- Мария купила Ноутбук
(3, 3, 1, 25000.00),  -- Иван купил Кофемашину
(4, 1, 1, 70000.00),  -- Алексей купил Смартфон
(4, 5, 1, 4500.00);   -- и Фен
*/

-- Задание 1. Заказы и их владельцы (INNER JOIN)
SELECT c.full_name, o.order_date
FROM Customers c
INNER JOIN Orders o ON c.customer_id = o.customer_id;

-- Задание 2. Покупатели без заказов (LEFT JOIN)
SELECT c.full_name
FROM Customers c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- Задание 3. Позиции заказа № 1 (соединение трех таблиц)
SELECT p.product_name, oi.quantity, oi.price_per_unit
FROM Orders o
INNER JOIN Order_Items oi ON o.order_id = oi.order_id
INNER JOIN Products p ON oi.product_id = p.product_id
WHERE o.order_id = 1;

-- Задание 4. Покупатели, заказывавшие смартфон (IN)
SELECT c.full_name
FROM Customers c
WHERE c.customer_id IN (
    SELECT customer_id
    FROM Orders
    WHERE order_id IN (
        SELECT order_id
        FROM Order_Items
        WHERE product_id IN (
            SELECT product_id
            FROM Products
            WHERE product_name = 'Смартфон'
        )
    )
);

-- Задание 5. Товары дороже средней цены (скалярный подзапрос)
SELECT p.product_id, p.product_name, p.category, p.price
FROM Products p
WHERE p.price > (
    SELECT AVG(price)
    FROM Products
);

-- Задание 6. Заказы хотя бы с одним товаром дороже 100 000 (EXISTS)
SELECT o.order_id, o.order_date
FROM Orders o
WHERE EXISTS (
    SELECT *
    FROM Order_Items oi
    INNER JOIN Products p ON oi.product_id = p.product_id
    WHERE o.order_id = oi.order_id AND p.price > 100000
);

SELECT 1 from products;

-- Задание 7. Покупатели, НЕ заказывавшие ноутбук: LEFT JOIN
SELECT c.full_name
FROM Customers c
LEFT JOIN (
    SELECT DISTINCT customer_id
    FROM Orders
    WHERE order_id IN (
        SELECT order_id
        FROM Order_Items
        WHERE product_id IN (
            SELECT product_id
            FROM Products
            WHERE product_name = 'Ноутбук'
        )
    )
) laptop_buyers ON c.customer_id = laptop_buyers.customer_id
WHERE laptop_buyers.customer_id IS NULL;

-- Задание 7. Покупатели, НЕ заказывавшие ноутбук: NOT IN
SELECT c.full_name
FROM Customers c
WHERE c.customer_id NOT IN (
    SELECT customer_id
    FROM Orders
    WHERE order_id IN (
        SELECT order_id
        FROM Order_Items
        WHERE product_id IN (
            SELECT product_id
            FROM Products
            WHERE product_name = 'Ноутбук'
        )
    )
      AND customer_id IS NOT NULL
);

-- Задание 8. Товары, которые ни разу не заказывали
SELECT p.product_name
FROM Products p
LEFT JOIN Order_Items oi ON p.product_id = oi.product_id
WHERE oi.order_item_id IS NULL;

-- Задание 9. Полный список покупателей, заказов и товаров
SELECT c.full_name, p.product_name, oi.quantity
FROM Customers c
FULL OUTER JOIN Orders o ON c.customer_id = o.customer_id
FULL OUTER JOIN Order_Items oi ON o.order_id = oi.order_id
FULL OUTER JOIN Products p ON oi.product_id = p.product_id;

-- Задание 10. Покупатели самого дорогого товара: JOIN с подзапросом
SELECT c.full_name
FROM Customers c
INNER JOIN (
    SELECT DISTINCT o.customer_id
    FROM Orders o
    INNER JOIN Order_Items oi ON o.order_id = oi.order_id
    INNER JOIN Products p ON oi.product_id = p.product_id
    WHERE p.price = (
        SELECT MAX(price)
        FROM Products
    )
) buyers ON c.customer_id = buyers.customer_id;

-- Задание 10. То же самое, только с подзапросами
SELECT c.full_name
FROM Customers c
WHERE c.customer_id IN (
    SELECT customer_id
    FROM Orders
    WHERE order_id IN (
        SELECT order_id
        FROM Order_Items
        WHERE product_id IN (
            SELECT product_id
            FROM Products
            WHERE price = (
                SELECT MAX(price)
                FROM Products
            )
        )
    )
);

-- Задание 11. Все пары «покупатель — категория» (CROSS JOIN)
SELECT c.full_name, cat.category
FROM Customers c
CROSS JOIN (SELECT DISTINCT category FROM Products) cat;

-- Задание 12. Кто кого рекомендовал (SELF JOIN)
SELECT c1.full_name new_customer, c2.full_name recommended_by
FROM Customers c1
LEFT JOIN Customers c2 ON c1.recommended_by = c2.customer_id;
