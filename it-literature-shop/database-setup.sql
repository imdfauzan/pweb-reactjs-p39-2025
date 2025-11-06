-- IT Literature Shop Database Schema
-- Created for Neon PostgreSQL Database

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Drop tables if they exist (in correct order to handle foreign keys)
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS books CASCADE;
DROP TABLE IF EXISTS genres CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- Create users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username TEXT NOT NULL UNIQUE,
    password TEXT NOT NULL,
    email TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create genres table
CREATE TABLE genres (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

-- Create books table
CREATE TABLE books (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    writer TEXT NOT NULL,
    publisher TEXT NOT NULL,
    publication_year INT NOT NULL,
    description TEXT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0,
    genre_id UUID NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    CONSTRAINT fk_genre FOREIGN KEY (genre_id) REFERENCES genres(id) ON DELETE RESTRICT
);

-- Create orders table
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Create order_items table
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    quantity INT NOT NULL,
    order_id UUID NOT NULL,
    book_id UUID NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    CONSTRAINT fk_book FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE RESTRICT
);

-- Create indexes for better performance
CREATE INDEX idx_books_genre_id ON books(genre_id);
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_book_id ON order_items(book_id);
CREATE INDEX idx_books_deleted_at ON books(deleted_at);
CREATE INDEX idx_genres_deleted_at ON genres(deleted_at);

-- Create function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_genres_updated_at BEFORE UPDATE ON genres
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_books_updated_at BEFORE UPDATE ON books
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_order_items_updated_at BEFORE UPDATE ON order_items
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert sample data for users
-- Password for all users is: "password123" (hashed with bcrypt)
INSERT INTO users (username, password, email) VALUES
    ('admin', '$2a$10$rH3ZKvKnH0ZqXZJJqKJQu.Y5JqZpJ5Xw0L7ZKJQu.Y5JqZpJ5Xw0L', 'admin@itliterature.com'),
    ('testuser', '$2a$10$rH3ZKvKnH0ZqXZJJqKJQu.Y5JqZpJ5Xw0L7ZKJQu.Y5JqZpJ5Xw0L', 'testuser@example.com'),
    ('johndoe', '$2a$10$rH3ZKvKnH0ZqXZJJqKJQu.Y5JqZpJ5Xw0L7ZKJQu.Y5JqZpJ5Xw0L', 'john.doe@example.com');

-- Insert sample data for genres
INSERT INTO genres (name) VALUES
    ('Programming'),
    ('Database'),
    ('Web Development'),
    ('Data Science'),
    ('Artificial Intelligence'),
    ('Computer Networks'),
    ('Software Engineering'),
    ('Cybersecurity');

-- Insert sample data for books
INSERT INTO books (title, writer, publisher, publication_year, description, price, stock_quantity, genre_id) VALUES
    ('Clean Code', 'Robert C. Martin', 'Prentice Hall', 2008, 'A Handbook of Agile Software Craftsmanship', 45.99, 100, (SELECT id FROM genres WHERE name = 'Programming' LIMIT 1)),
    ('Database System Concepts', 'Abraham Silberschatz', 'McGraw-Hill', 2019, 'Comprehensive database systems textbook', 89.99, 50, (SELECT id FROM genres WHERE name = 'Database' LIMIT 1)),
    ('JavaScript: The Good Parts', 'Douglas Crockford', 'O''Reilly Media', 2008, 'Unearthing the Excellence in JavaScript', 29.99, 75, (SELECT id FROM genres WHERE name = 'Web Development' LIMIT 1)),
    ('Python for Data Analysis', 'Wes McKinney', 'O''Reilly Media', 2022, 'Data Wrangling with Pandas, NumPy, and IPython', 54.99, 60, (SELECT id FROM genres WHERE name = 'Data Science' LIMIT 1)),
    ('Introduction to Algorithms', 'Thomas H. Cormen', 'MIT Press', 2009, 'Comprehensive algorithms textbook', 79.99, 40, (SELECT id FROM genres WHERE name = 'Programming' LIMIT 1)),
    ('Computer Networking', 'James Kurose', 'Pearson', 2021, 'A Top-Down Approach', 94.99, 35, (SELECT id FROM genres WHERE name = 'Computer Networks' LIMIT 1));

-- Verify the setup
SELECT 'Users table created' as status, COUNT(*) as count FROM users
UNION ALL
SELECT 'Genres table created', COUNT(*) FROM genres
UNION ALL
SELECT 'Books table created', COUNT(*) FROM books
UNION ALL
SELECT 'Orders table created', COUNT(*) FROM orders
UNION ALL
SELECT 'Order_items table created', COUNT(*) FROM order_items;
