// src/auth/auth.routes.ts
import { Router } from 'express';
import {
  registerUserController,
  loginUserController,
  getMeController,
} from './auth.controller';
import validate from '../middleware/validate';
import { registerUserSchema, loginUserSchema } from './auth.validation';
import { authenticate } from '../middleware/auth';

const router = Router();

router.post('/register', validate(registerUserSchema), registerUserController);
router.post('/login', validate(loginUserSchema), loginUserController);

router.get('/me', authenticate, getMeController);

export default router;