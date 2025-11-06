// src/auth/auth.validation.ts
import { z } from 'zod';

export const registerUserSchema = z.object({
  body: z.object({
    email: z.string().min(1, { message: 'Email is required' }).email({ message: 'Must be a valid email' }),
    password: z
      .string()
      .min(6, { message: 'Password must be at least 6 characters long' }),
    username: z.string().min(1, { message: 'Username is required' }),
  }),
});

export const loginUserSchema = z.object({
  body: z.object({
    email: z.string().min(1, { message: 'Email is required' }),
    password: z.string().min(1, { message: 'Password is required' }),
  }),
});