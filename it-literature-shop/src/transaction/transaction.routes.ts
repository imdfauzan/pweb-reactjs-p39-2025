// src/transactions/transaction.routes.ts
import { Router } from 'express';
import {
  createTransactionController,
  getAllTransactionsController,
  getTransactionByIdController,
  getTransactionStatisticsController,
} from './transaction.controller';
import { authenticate } from '../middleware/auth';
import validate from '../middleware/validate';
import { createTransactionSchema } from './transaction.validation';

const router = Router();

// Lindungi semua rute transaksi
router.use(authenticate);

router.post('/', validate(createTransactionSchema), createTransactionController);
router.get('/statistics', getTransactionStatisticsController);

router.get('/', getAllTransactionsController);
router.get('/:id', getTransactionByIdController);

export default router;