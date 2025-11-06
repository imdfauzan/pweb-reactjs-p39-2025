-- Quick query to get all Genre IDs and Names
-- Copy and run this in your Neon SQL Editor

SELECT 
    id,
    name,
    created_at
FROM genres
WHERE deleted_at IS NULL
ORDER BY name;

-- Result will show you the actual UUID for each genre
-- Example output:
-- id                                   | name                    | created_at
-- -------------------------------------|-------------------------|----------------------------
-- abc123-uuid-here                     | Artificial Intelligence | 2025-10-21 00:00:00
-- def456-uuid-here                     | Computer Networks       | 2025-10-21 00:00:00
-- etc...
