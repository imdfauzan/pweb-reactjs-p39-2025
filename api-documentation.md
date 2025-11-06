GET /health-check - Server status
GET /test-db - Database test
POST /auth/register - Register user
POST /auth/login - Login (get token)


Berikut yang membutuhkan akses token/JWT:
Auth (1):
5. GET /auth/me - Current user info

Genres (5):
6. GET /genre - List all
7. POST /genre - Create
8. GET /genre/:id - Get one
9. PUT /genre/:id - Update
10. DELETE /genre/:id - Delete

Books (6):
11. GET /books - List all
12. POST /books - Create
13. GET /books/:id - Get one
14. GET /books/genre/:genreId - By genre
15. PUT /books/:id - Update
16. DELETE /books/:id - Delete

Transactions (4):
17. POST /transactions - Create order
18. GET /transactions - List all
19. GET /transactions/:id - Get one
20. GET /transactions/statistics - Stats