// src/genres/genre.routes.ts
import { Router } from 'express';
import {
  createGenreController,
  getAllGenresController,
} from './genre.controller';
import { authenticate } from '../middleware/auth';
import validate from '../middleware/validate';
import { createGenreSchema } from './genre.validation';
import {
  getGenreByIdController,
  updateGenreController,
  deleteGenreController,
} from './genre.controller';
import { updateGenreSchema } from './genre.validation';

const router = Router();

// Lindungi semua rute di bawah ini dengan middleware authenticate
router.use(authenticate);

router.post('/', validate(createGenreSchema), createGenreController);
router.get('/', getAllGenresController);

router.get('/:id', getGenreByIdController);
router.patch('/:id', validate(updateGenreSchema), updateGenreController);
router.delete('/:id', deleteGenreController);

export default router;