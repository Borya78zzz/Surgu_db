
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    quantity INT NOT NULL CHECK (quantity >= 0) -- Количество на складе
);

CREATE TABLE order_history (
    log_id SERIAL PRIMARY KEY,
    product_id INT NOT NULL REFERENCES products (product_id),
    quantity_changed INT NOT NULL,
    notes VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO products (product_id, name, quantity) VALUES
(1, 'Ноутбук', 20),
(2, 'Смартфон', 50);
BEGIN;
UPDATE products SET quantity = quantity - 5 WHERE product_id = 1;

INSERT INTO order_history (product_id, quantity_changed, notes) VALUES
(1,-5,'Ноутбуки');
COMMIT;
BEGIN;
INSERT INTO order_history (product_id, quantity_changed) VALUES (2, -100);
UPDATE products SET quantity = quantity - 100 WHERE product_id = 2;

ROLLBACK;
SELECT * FROM products WHERE product_id = 2;
SELECT * FROM order_history;
BEGIN;
UPDATE products SET quantity = quantity - 2 WHERE product_id = 1;
ROLLBACK;
SELECT * FROM products WHERE product_id = 1;

-- Задание 4: два подключения (psql в двух терминалах)
-- Сессия 1:
BEGIN ISOLATION LEVEL READ COMMITTED;
UPDATE products SET quantity = quantity - 10 WHERE product_id = 2;
-- Сессия 2:
BEGIN ISOLATION LEVEL READ COMMITTED;
SELECT * FROM products WHERE product_id = 2; -- 50
-- Почему 50: Сессия 1 ещё не сделала COMMIT, её изменение не зафиксировано.
-- READ COMMITTED показывает только зафиксированные данные, грязного чтения нет.
-- Сессия 1:
COMMIT;
-- Сессия 2:
SELECT * FROM products WHERE product_id = 2; -- 40
-- Почему 40: в READ COMMITTED каждый запрос видит данные, зафиксированные
-- к моменту его начала. Второй SELECT начался после COMMIT Сессии 1,
-- поэтому увидел новое значение. Это неповторяющееся чтение.
COMMIT;
