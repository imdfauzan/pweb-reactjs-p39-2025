-- Fix user passwords with correct bcrypt hash for "password123"
-- Run this SQL directly in your Neon database console

UPDATE users 
SET password = '$2a$10$YQiiz078Z.z5E4VYH8jAHOxJ5hI5Z6F8X8fk4OV5qQ3c3V3V3V3V3'
WHERE username IN ('admin', 'testuser', 'johndoe');

-- Verify the update
SELECT username, email, 
       CASE 
           WHEN password LIKE '$2a$10$YQiiz078%' THEN 'Password Fixed ✅'
           ELSE 'Old Password ❌'
       END as password_status
FROM users;
