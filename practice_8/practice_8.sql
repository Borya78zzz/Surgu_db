

-- Отдельная схема позволяет сохранить существующие таблицы прошлых работ.
CREATE SCHEMA IF NOT EXISTS practice_8;
SET search_path TO practice_8;

-- Задание 1. Книги и издательства: приведение к 3НФ
-- Первичный ключ исходной таблицы: book_id.
-- Основные функциональные зависимости:
-- book_id -> title, author_name, publisher_id;
-- publisher_id -> publisher_name, publisher_city.
-- Следовательно, book_id определяет и все остальные поля книги.
-- Транзитивная зависимость:
-- book_id -> publisher_id -> publisher_name, publisher_city.
-- Название и город издательства зависят от неключевого publisher_id.
-- Из-за этого сведения об одном издательстве повторяются у разных книг.
-- Устраняем нарушение 3НФ: выносим издательства в отдельную таблицу.

CREATE TABLE Publishers (
    publisher_id INT PRIMARY KEY,
    publisher_name VARCHAR(255),
    publisher_city VARCHAR(100)
);

CREATE TABLE Books (
    book_id INT PRIMARY KEY,
    title VARCHAR(255),
    author_name VARCHAR(255),
    publisher_id INT,
    FOREIGN KEY (publisher_id) REFERENCES Publishers(publisher_id)
);

-- Теперь данные издательства зависят от ключа Publishers,
-- а в Books остаются сведения о книге и ссылка на издательство.
-- Обе таблицы находятся в 3НФ при зависимостях из условия.

-- Задание 2. Результаты заездов: приведение к 3НФ
-- Первичный ключ исходной таблицы: (race_id, driver_id).
-- Основные функциональные зависимости:
-- (race_id, driver_id) -> car_model, finish_time;
-- car_model -> car_manufacturer.
-- Составной ключ также определяет производителя автомобиля.
-- Транзитивная зависимость:
-- (race_id, driver_id) -> car_model -> car_manufacturer.
-- Производитель зависит от модели, поэтому исходная таблица нарушает 3НФ.
-- Зависимость driver_id -> car_model условием не задана:
-- в разных заездах водитель может использовать разные модели.

CREATE TABLE CarModels (
    car_model VARCHAR(100) PRIMARY KEY,
    car_manufacturer VARCHAR(100)
);

CREATE TABLE RaceResults (
    race_id INT,
    driver_id INT,
    car_model VARCHAR(100),
    finish_time TIME,
    PRIMARY KEY (race_id, driver_id),
    FOREIGN KEY (car_model) REFERENCES CarModels(car_model)
);

-- Производитель хранится один раз для каждой модели.
-- В RaceResults модель и время финиша зависят от всей пары заезд-водитель.
-- Транзитивная зависимость устранена, обе таблицы находятся в 3НФ.

-- Задание 3. Бронирование комнат: приведение к НФБК
-- Основные функциональные зависимости исходной таблицы:
-- (booking_time, room_name) -> event_name;
-- event_name -> event_type;
-- event_type -> room_name.
-- Из этих зависимостей следуют потенциальные ключи:
-- (booking_time, room_name), (booking_time, event_name),
-- а также (booking_time, event_type).
-- Ни event_type, ни event_name не определяют время бронирования,
-- поэтому по отдельности они не являются суперключами.
-- event_type -> room_name нарушает НФБК: определитель не является суперключом.
-- Аналогично НФБК нарушает зависимость event_name -> event_type.
-- Для НФБК выносим обе зависимости в отдельные таблицы.
-- Имена мероприятий и типов используем как идентификаторы по условию задачи.

CREATE TABLE EventTypes (
    event_type VARCHAR(50) PRIMARY KEY,
    room_name VARCHAR(100) NOT NULL
);

CREATE TABLE Events (
    event_name VARCHAR(255) PRIMARY KEY,
    event_type VARCHAR(50) NOT NULL,
    FOREIGN KEY (event_type) REFERENCES EventTypes(event_type)
);

-- В PostgreSQL дата и время хранятся в TIMESTAMP вместо DATETIME из примера.
CREATE TABLE RoomBookings (
    booking_time TIMESTAMP,
    event_name VARCHAR(255),
    PRIMARY KEY (booking_time, event_name),
    FOREIGN KEY (event_name) REFERENCES Events(event_name)
);

-- EventTypes: event_type -> room_name, определитель является ключом.
-- Events: event_name -> event_type, определитель является ключом.
-- RoomBookings содержит только поля составного ключа.
-- Все три таблицы находятся в НФБК.
-- Декомпозиция выполняется без потерь: общими полями при разделении
-- служат event_type и event_name, являющиеся ключами вынесенных таблиц.

-- Ограничение уникальности (booking_time, room_name) после декомпозиции
-- затрагивает несколько таблиц и не обеспечивается одним PRIMARY KEY или UNIQUE.
-- В частности, разные типы мероприятий могут ссылаться на одну комнату.
-- В прикладной системе для запрета таких пересечений нужна общая проверка
-- при изменениях броней, мероприятий и назначений комнат с учетом конкуренции.
-- Следующий запрос выявляет нарушения: корректный результат не содержит строк.
SELECT rb.booking_time, et.room_name, COUNT(*) booking_count
FROM RoomBookings rb
INNER JOIN Events e ON rb.event_name = e.event_name
INNER JOIN EventTypes et ON e.event_type = et.event_type
GROUP BY rb.booking_time, et.room_name
HAVING COUNT(*) > 1;

RESET search_path;
