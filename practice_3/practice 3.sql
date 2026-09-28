--Практика 3

--Задание 1
SELECT * FROM READERS;

--Задание 2
SELECT title, publish_year FROM Books;

--Задание 3
SELECT title, publish_year FROM Books WHERE  publish_year > 1799 AND publish_year < 1900;

--Задание 4
SELECT title, publish_year FROM Books WHERE  publish_year > 1916 AND publish_year < 1992;

--Задание 5
SELECT * FROM readers WHERE phone = '+7-900-111-22-33';

--Задание 6
SELECT * FROM readers WHERE full_name LIKE '%ов%';

--Задание 7
SELECT * FROM loans WHERE actual_return_date IS NULL;

--Задание 8
SELECT title,publish_year FROM books ORDER BY title;

--Задание 9
SELECT * FROM loans WHERE actual_return_date IS NULL ORDER BY due_date;

--Задание 10
SELECT * FROM books ORDER BY publish_year  LIMIT 3;

SELECT * FROM books ORDER BY publish_year DESC LIMIT 3;

SELECT * FROM books ORDER BY title  LIMIT 3;
