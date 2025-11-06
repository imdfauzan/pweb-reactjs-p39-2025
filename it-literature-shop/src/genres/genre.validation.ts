// src/genres/genre.validation.ts
import { z } from 'zod';

export const createGenreSchema = z.object({
  body: z.object({
    name: z.string().min(1, { message: 'Genre name is required' }),
  }),
});

export const updateGenreSchema = z.object({
  body: z.object({
    name: z.string().min(1, { message: 'Genre name is required' }),
  }),
});