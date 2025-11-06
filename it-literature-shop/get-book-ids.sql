-- Quick query to get all Book IDs and details
-- Copy and run this in your Neon SQL Editor

SELECT 
    b.id,
    b.title,
    b.writer,
    b.price,
    b.stock_quantity,
    g.name as genre_name,
    b.genre_id
FROM books b
JOIN genres g ON b.genre_id = g.id
WHERE b.deleted_at IS NULL
ORDER BY b.title;

-- Result will show you the actual UUID for each book with its genre
