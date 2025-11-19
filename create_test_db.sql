-- Создаем базу данных
CREATE DATABASE testdb;

-- Подключаемся к новой базе
\c testdb

-- Создаем простую таблицу
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50)
);

-- Добавляем тестовые данные
INSERT INTO users (name) VALUES 
('Иван Иванов'),
('Петр Петров'),
('Мария Сидорова');

-- Проверяем данные
SELECT * FROM users;