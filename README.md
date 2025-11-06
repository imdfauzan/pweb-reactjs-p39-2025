# Praktikum Pemrograman Web 🌐

## 📖 Modul 4

React JS

## 👥 Anggota Kelompok

| Nama                     | NRP        |
| ------------------------ | ---------- |
| Imam Mahmud Dalil Fauzan | 5027241100 |
| Mochammad Atha Tajuddin  | 5027241093 |
| Mey Rosalina             | 5027241004 |

## 📚 Membuat Backend Express **IT Literature Shop**

> **Tech Stack:** Express + TypeScript + PostgreSQL (Neon Database) + Prisma ORM

---

## 🚀 Quick Start

### 1. Install Dependencies

```powershell
cd it-literature-shop
npm install
npm install --save-dev @types/node
```

### 2. Setup Database

1. Run `database-setup.sql` in your Neon SQL Editor
2. Update `.env` with your Neon credentials
3. Run Prisma commands:

```powershell
npx prisma generate
npx prisma db pull
```

### 3. Start Server

```powershell
npm run dev
```

### 4. Test API

- Open: `http://localhost:8080/health-check`
- Import Postman collection: `IT-Literature-Shop-Postman-Collection.json`
- Login with: `testuser` / `password123`

---

## 📋 API Endpoints (19 Total)

### Public Endpoints (3)

- `GET /health-check` - Server status
- `POST /auth/register` - Register user
- `POST /auth/login` - Login & get JWT token

### Protected Endpoints (16)

**Authentication:**

- `GET /auth/me` - Get current user

**Genres (5):**

- `POST /genre` - Create genre
- `GET /genre` - Get all genres
- `GET /genre/:id` - Get genre by ID
- `PATCH /genre/:id` - Update genre
- `DELETE /genre/:id` - Delete genre

**Books (6):**

- `POST /books` - Create book
- `GET /books` - Get all books
- `GET /books/:id` - Get book by ID
- `GET /books/genre/:id` - Get books by genre
- `PATCH /books/:id` - Update book
- `DELETE /books/:id` - Delete book

**Transactions (4):**

- `POST /transactions` - Create order
- `GET /transactions` - Get all orders
- `GET /transactions/:id` - Get order by ID
- `GET /transactions/statistics` - Get order stats

---

## 📁 Project Structure

```
it-literature-shop/
├── prisma/
│   └── schema.prisma          # Database schema
├── src/
│   ├── auth/                  # Authentication logic
│   │   ├── auth.controller.ts
│   │   ├── auth.routes.ts
│   │   ├── auth.service.ts
│   │   └── auth.validation.ts
│   ├── books/                 # Books management
│   ├── genres/                # Genres management
│   ├── transaction/           # Transaction logic
│   ├── middleware/            # Auth & validation middleware
│   ├── types/                 # TypeScript types
│   ├── utils/                 # Prisma client & utilities
│   ├── app.ts                 # Express app configuration
│   └── index.ts               # Server entry point
├── .env                       # Environment variables
├── package.json               # Dependencies
├── tsconfig.json              # TypeScript config
├── database-setup.sql         # Database schema SQL
├── API-DOCUMENTATION.md       # Complete API docs
├── DEPLOYMENT-GUIDE.md        # Setup & deployment guide
├── TESTING-GUIDE.md           # Postman testing guide
├── api-status.json            # API status summary
└── IT-Literature-Shop-Postman-Collection.json
```

---

## 📖 Documentation

| File                   | Description                                                                            |
| ---------------------- | -------------------------------------------------------------------------------------- |
| `API-DOCUMENTATION.md` | Complete API reference with all endpoints, request/response examples, and status codes |
| `TESTING-GUIDE.md`     | Postman collection usage guide and testing workflow                                    |
| `api-status.json`      | Quick API status overview and endpoint summary                                         |

---

## 🗄️ Database Schema

**Tables:**

- `users` - User accounts
- `genres` - Book categories
- `books` - Book catalog
- `orders` - Customer orders
- `order_items` - Order details

**Features:**

- UUID primary keys
- Soft deletes (`deleted_at`)
- Auto-updated timestamps
- Foreign key relationships
- Indexes for performance

---

## 🧪 Test Data

**Sample Users:** (password: `password123`)

- `testuser`
- `admin`
- `johndoe`

**Sample Data:**

- 8 Genres (Programming, Database, Web Development, etc.)
- 6 Books (Clean Code, JavaScript: The Good Parts, etc.)

---

## 🛠️ Development Commands

```powershell
# Install dependencies
npm install

# Start development server with hot reload
npm run dev

# Build for production
npm run build

# Start production server
npm start

# Generate Prisma client
npx prisma generate

# Open Prisma Studio (visual database browser)
npx prisma studio

# Pull database schema
npx prisma db pull

# Push schema changes to database
npx prisma db push
```

---

## 🔐 Environment Variables

```env
PORT=8080
DATABASE_URL="postgresql://user:pass@host/db?sslmode=require"
JWT_SECRET="your-secret-key-here"
NODE_ENV="development"
```

---

## ✅ Verification Checklist

- [ ] Database setup complete (run SQL script)
- [ ] `.env` file configured
- [ ] Dependencies installed
- [ ] Prisma client generated
- [ ] Server starts without errors
- [ ] Health check returns 200 OK
- [ ] Can login with test user
- [ ] Postman collection imported
- [ ] All endpoints accessible

---

## 🎯 Features

✅ RESTful API architecture  
✅ JWT authentication  
✅ Input validation with Zod  
✅ PostgreSQL with Prisma ORM  
✅ TypeScript for type safety  
✅ Soft deletes  
✅ Transaction management  
✅ Error handling  
✅ Password hashing (bcrypt)  
✅ Complete API documentation

---

**Last Updated:** October 21, 2025  
**Version:** 1.0.0

Referensi tutorial terkait Neon DB : https://youtu.be/XKwOsn37KCc?si=QbC7fCgV0dNAP7Gy
