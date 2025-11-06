// src/app.ts
import express, { Express, Request, Response, NextFunction } from 'express';
import authRouter from './auth/auth.routes'; // <-- Import router auth
import genreRouter from './genres/genre.routes'; // <-- Import router genre
import bookRouter from './books/book.routes'; // <-- Import router buku
import transactionRouter from './transaction/transaction.routes'; // <-- Import
import prisma from './utils/prisma'; // <-- Import prisma for test endpoint

const app: Express = express();

app.use(express.json());

app.get('/health-check', (req: Request, res: Response) => {
  res.status(200).json({
    success: true,
    message: 'Server is healthy and running!',
    date: new Date().toUTCString(),
  });
});

// Test endpoint to check database and list users
app.get('/test-db', async (req: Request, res: Response) => {
  try {
    const users = await prisma.users.findMany({
      select: {
        id: true,
        username: true,
        email: true,
        created_at: true,
      }
    });
    
    const genres = await prisma.genres.count();
    const books = await prisma.books.count();
    
    res.status(200).json({
      success: true,
      message: 'Database connection working!',
      data: {
        users: users,
        total_genres: genres,
        total_books: books,
      }
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: 'Database error',
      error: error.message
    });
  }
});

// Daftarkan router untuk endpoint /auth
app.use('/auth', authRouter); // <-- Gunakan router
app.use('/genre', genreRouter); // <-- Gunakan router genre
app.use('/books', bookRouter); // <-- Gunakan router buku
app.use('/transactions', transactionRouter); // <-- Gunakan router transaksi

// Middleware untuk menangani error global
// Ini akan menangkap error yang dilempar dari controller
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  console.error(err.stack);
  res.status(500).json({
    success: false,
    message: 'Internal Server Error',
  });
});

export default app;