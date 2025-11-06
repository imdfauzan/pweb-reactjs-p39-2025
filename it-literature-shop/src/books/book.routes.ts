// src/books/book.routes.ts
import { Router } from 'express';
import {
  createBookController,
  getAllBooksController,
} from './book.controller';
import { authenticate } from '../middleware/auth';
import validate from '../middleware/validate';
import { createBookSchema } from './book.validation';
import {
  getBookByIdController,
  updateBookController,
  deleteBookController,
  getBooksByGenreController,
} from './book.controller';
import { updateBookSchema } from './book.validation';

const router = Router();

// Lindungi semua rute buku
router.use(authenticate);

router.post('/', validate(createBookSchema), createBookController);
router.get('/', getAllBooksController);

router.get('/genre/:id', getBooksByGenreController);

router.get('/:id', getBookByIdController);
router.patch('/:id', validate(updateBookSchema), updateBookController);
router.delete('/:id', deleteBookController);

export default router;