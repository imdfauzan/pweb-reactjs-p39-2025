// src/transactions/transaction.validation.ts
import { z } from 'zod';

export const createTransactionSchema = z.object({
  body: z.object({
    // user_id tidak perlu divalidasi karena kita akan mengambilnya dari token
    items: z
      .array(
        z.object({
          book_id: z
            .string()
            .uuid({ message: 'Book ID must be a valid UUID' }),
          quantity: z
            .number()
            .int()
            .positive({ message: 'Quantity must be a positive integer' }),
        })
      )
      .min(1, { message: 'Transaction must have at least one item' }),
  }),
});