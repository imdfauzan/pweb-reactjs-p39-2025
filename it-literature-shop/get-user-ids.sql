-- Quick query to get all User IDs
-- Copy and run this in your Neon SQL Editor

SELECT 
    id,
    username,
    email,
    created_at
FROM users
ORDER BY username;

-- Result will show you the actual UUID for each user
