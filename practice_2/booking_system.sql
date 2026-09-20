--Задание 1/2
CREATE TABLE Readers(
  reader_id SERIAL PRIMARY KEY,
  full_name VARCHAR(100) NOT NULL,
  phone VARCHAR(30) UNIQUE NOT NULL
);

CREATE TABLE Books(
  isbn VARCHAR(20) PRIMARY KEY,
  title VARCHAR(100) NOT NULL,
  publish_year INT NOT NULL CHECK (publish_year > 0)
);

CREATE TABLE Authors(
  author_id SERIAL PRIMARY KEY,
  full_name VARCHAR(100) NOT NULL
);

CREATE TABLE Book_Authors (
  book_isbn VARCHAR(20) NOT NULL,
  author_id INT NOT NULL,
  FOREIGN KEY (book_isbn) REFERENCES Books(isbn) ON DELETE CASCADE,
  FOREIGN KEY (author_id) REFERENCES Authors(author_id) ON DELETE CASCADE,
  PRIMARY KEY (book_isbn, author_id)
);

CREATE TABLE Loans (
  loan_id SERIAL PRIMARY KEY,
  reader_id INT NOT NULL,
  book_isbn VARCHAR(20) NOT NULL,
  FOREIGN KEY (reader_id) REFERENCES Readers(reader_id),
  FOREIGN KEY (book_isbn) REFERENCES Books(isbn),
  issue_date DATE NOT NULL,
  due_date DATE NOT NULL,
  actual_return_date DATE,
  CHECK (due_date >= issue_date),
  CHECK (actual_return_date IS NULL OR actual_return_date >= issue_date)
);
--Задание 3
INSERT INTO Readers (full_name,phone) VALUES
('Анна Петрова','+7-900-111-22-33'),
('Иван Соколов','+7-900-222-33-44'),
('Мария Ким','+7-900-333-44-55'),
('Олег Васильев','+7-900-444-55-66');

INSERT INTO Authors (full_name) VALUES
('Михаил Булгаков'),      
('Федор Достоевский'),    
('Лев Толстой'),          
('Илья Ильф'),            
('Евгений Петров'),       
('Аркадий Стругацкий'),   
('Борис Стругацкий');

INSERT INTO Books (isbn, title, publish_year) VALUES
('978-5-17-118366-8', 'Мастер и Маргарита', 1967),
('978-5-389-06256-6', 'Преступление и наказание', 1866),
('978-5-04-116716-3', 'Война и мир', 1869),
('978-5-699-12014-7', 'Золотой теленок', 1931),
('978-5-389-03713-7', 'Пикник на обочине', 1972);

INSERT INTO Book_Authors (book_isbn, author_id) VALUES

('978-5-17-118366-8', 1),  
('978-5-389-06256-6', 2),  
('978-5-04-116716-3', 3),  

('978-5-699-12014-7', 4),  
('978-5-699-12014-7', 5),  

('978-5-389-03713-7', 6),  
('978-5-389-03713-7', 7);  

INSERT INTO Loans (reader_id, book_isbn, issue_date, due_date, actual_return_date) VALUES
-- 1. Анна Петрова  взяла Мастера и Маргариту и крч вернула
(1, '978-5-17-118366-8', '2026-08-01', '2026-08-15', '2026-08-12'),

-- 2. Анна Петрова  взяла Золотого телёнка и не вернула собака сутулая, но все еще впереди
(1, '978-5-699-12014-7', '2026-09-01', '2026-09-20', NULL),

-- 3. Иван Соколов взял Преступление и наказание и ВЕРНУЛ!!!!!!!!!!!!!
(2, '978-5-389-06256-6', '2026-08-10', '2026-08-25', '2026-08-24'),

-- 4. Иван Соколов  взял Войну и мир и ЕЩЁ ЧИТАЕТ !??!?!??? именно зэк воровской
(2, '978-5-04-116716-3', '2026-09-05', '2026-09-25', NULL),

-- 5. Мария Ким взяла Пикник на обочине и суп с котом
(3, '978-5-389-03713-7', '2026-09-08', '2026-09-22', NULL),

-- 6. Олег Васильев взял Мастера и Маргариту и ВЕРНУЛ БОЖЕШЬ ТЫ МОЙ
(4, '978-5-17-118366-8', '2026-07-01', '2026-07-15', '2026-07-14');

--Задание 4
UPDATE Readers SET phone = '+7-908-228-14-88' WHERE full_name = 'Олег Васильев';
UPDATE Loans SET actual_return_date '2026-09-21' WHERE loans_id = '5';
INSERT INTO Readers (full_name, phone) VALUES ('Сергей Смирнов', '+7-900-777-66-55');
DELETE FROM Readers WHERE full_name = 'Сергей Смирнов';
