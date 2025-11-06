// src/books/book.validation.ts
import { z } from 'zod';

export const createBookSchema = z.object({
  body: z.object({
    title: z.string().min(1, { message: 'Title is required' }),
    writer: z.string().min(1, { message: 'Writer is required' }),
    publisher: z.string().min(1, { message: 'Publisher is required' }),
    publication_year: z.number().int().positive(),
    price: z.number().positive(),
    stock_quantity: z.number().int().min(0),
    genre_id: z.string().uuid({ message: 'Genre ID must be a valid UUID' }),
    description: z.string().optional(),
  }),
});

export const updateBookSchema = z.object({
  body: z
    .object({
      description: z.string(),
      price: z.number().positive(),
      stock_quantity: z.number().int().min(0),
    })
    .partial(), // .partial() membuat semua field di dalamnya menjadi opsional
});