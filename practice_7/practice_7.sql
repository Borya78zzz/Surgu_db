-- Практическая работа 7. Приведение к 1НФ и 2НФ
-- Задания: https://surgu.needcode.ru/practices/10
-- Лекция: https://surgu.needcode.ru/lectures/10

-- Задание 1. Проекты и участники: приведение к 1НФ
-- В team_members хранятся сразу несколько имен через запятую.
-- Это повторяющаяся группа: одна ячейка содержит несколько участников.
-- Для 1НФ каждый участник должен храниться отдельно.
-- Проекты и сотрудников связываем через таблицу ProjectMembers.
-- Идентификатор сотрудника позволяет различать людей с одинаковыми именами.

CREATE TABLE Projects (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(255)
);

CREATE TABLE Employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(255)
);

CREATE TABLE ProjectMembers (
    project_id INT,
    employee_id INT,
    PRIMARY KEY (project_id, employee_id),
    FOREIGN KEY (project_id) REFERENCES Projects(project_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);

-- Теперь все значения атомарны, а участники не хранятся списком.
-- Один сотрудник может участвовать в нескольких проектах.
-- Первичный ключ ProjectMembers запрещает повтор одной и той же пары.

-- Задание 2. Аренда оборудования: приведение к 2НФ
-- Исходный первичный ключ: (client_id, equipment_id).
-- Все исходные поля атомарны, поэтому таблица уже находится в 1НФ.
-- Основные функциональные зависимости:
-- client_id -> client_name, client_email;
-- equipment_id -> equipment_name;
-- (client_id, equipment_id) -> rental_date.
-- Следовательно, составной ключ определяет и все остальные поля строки.
-- client_name и client_email зависят только от client_id,
-- equipment_name зависит только от equipment_id.
-- Эти частичные зависимости нарушают 2НФ.
-- Разделяем сведения о клиентах, оборудовании и самих арендах.

CREATE TABLE Clients (
    client_id INT PRIMARY KEY,
    client_name VARCHAR(255),
    client_email VARCHAR(255)
);

CREATE TABLE Equipment (
    equipment_id INT PRIMARY KEY,
    equipment_name VARCHAR(255)
);

CREATE TABLE EquipmentRentals (
    client_id INT,
    equipment_id INT,
    rental_date DATE,
    PRIMARY KEY (client_id, equipment_id),
    FOREIGN KEY (client_id) REFERENCES Clients(client_id),
    FOREIGN KEY (equipment_id) REFERENCES Equipment(equipment_id)
);

-- Во всех трех таблицах неключевые поля зависят от всего своего ключа.
-- Сохраняем ограничение исходной задачи: одна аренда на пару клиент-оборудование.

-- Задание 3. Оценки студентов: последовательное приведение к 1НФ и 2НФ
-- 1. Нарушение 1НФ:
-- assignments_and_grades содержит повторяющиеся пары "задание - оценка".
-- В рамках этой задачи каждую такую пару нужно хранить в отдельной строке.

-- 2. Промежуточная структура в 1НФ:
-- Название задания уникально внутри курса, как ключ объекта JSON из условия.
-- Для каждого студента по каждому заданию хранится одна оценка.
-- Поэтому новый ключ: (student_id, course_id, assignment_name).

CREATE TABLE StudentGrades1NF (
    student_id INT,
    course_id INT,
    assignment_name VARCHAR(255),
    student_name VARCHAR(255),
    course_professor VARCHAR(255),
    grade INT,
    PRIMARY KEY (student_id, course_id, assignment_name)
);

-- 3. Анализ полученной таблицы:
-- student_id -> student_name;
-- course_id -> course_professor;
-- (student_id, course_id, assignment_name) -> grade.
-- Составной ключ также определяет student_name и course_professor.
-- Все поля атомарны, но имя студента и преподаватель зависят
-- только от частей составного ключа. Следовательно, 2НФ нарушена.

-- 4. Итоговая структура в 2НФ:
-- Отделяем сведения о студентах и курсах от оценок.

CREATE TABLE Students (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(255)
);

CREATE TABLE Courses (
    course_id INT PRIMARY KEY,
    course_professor VARCHAR(255)
);

-- Отдельная запись о задании курса существует независимо от полученных оценок.
CREATE TABLE CourseAssignments (
    course_id INT,
    assignment_name VARCHAR(255),
    PRIMARY KEY (course_id, assignment_name),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);

-- Связь студента с курсом сохраняется, даже если оценок пока нет.
CREATE TABLE StudentCourses (
    student_id INT,
    course_id INT,
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);

CREATE TABLE StudentGrades (
    student_id INT,
    course_id INT,
    assignment_name VARCHAR(255),
    grade INT,
    PRIMARY KEY (student_id, course_id, assignment_name),
    FOREIGN KEY (student_id, course_id) REFERENCES StudentCourses(student_id, course_id),
    FOREIGN KEY (course_id, assignment_name) REFERENCES CourseAssignments(course_id, assignment_name)
);

-- В Students и Courses сведения зависят от простого первичного ключа.
-- CourseAssignments и StudentCourses состоят только из ключевых полей.
-- В StudentGrades оценка зависит от всего ключа: студента, курса и задания.
-- Частичные зависимости устранены, все итоговые таблицы находятся в 2НФ.
