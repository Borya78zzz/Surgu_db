-- Задание 1. Количество товаров по категориям
SELECT category, COUNT(*) product_count
FROM Products
GROUP BY category;

-- Задание 2. Общая выручка
SELECT SUM(quantity * price_per_unit) total_revenue
FROM Order_Items;

-- Задание 3. Количество заказов на клиента, включая клиентов без заказов
SELECT c.full_name, COUNT(o.order_id) order_count
FROM Customers c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name;

-- Задание 4. Средняя стоимость одного заказа
SELECT AVG(order_total) average_order_total
FROM (
    SELECT o.order_id, COALESCE(SUM(oi.quantity * oi.price_per_unit), 0) order_total
    FROM Orders o
    LEFT JOIN Order_Items oi ON o.order_id = oi.order_id
    GROUP BY o.order_id
) order_totals;

-- Задание 5. Количество заказов по статусам
SELECT status, COUNT(*) order_count
FROM Orders
GROUP BY status;

-- Задание 6. Категории, в которых больше одного товара
SELECT category, COUNT(*) product_count
FROM Products
GROUP BY category
HAVING COUNT(*) > 1;

-- Задание 7. Клиенты, сделавшие больше одного заказа
SELECT c.full_name
FROM Customers c
INNER JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name
HAVING COUNT(o.order_id) > 1;

-- Задание 8. Самый продаваемый товар по количеству единиц
-- При одинаковом максимуме выводятся все товары-лидеры.
SELECT p.product_name
FROM Products p
INNER JOIN Order_Items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
HAVING SUM(oi.quantity) = (
    SELECT MAX(total_quantity)
    FROM (
        SELECT SUM(quantity) total_quantity
        FROM Order_Items
        WHERE product_id IS NOT NULL
        GROUP BY product_id
    ) product_sales
);
