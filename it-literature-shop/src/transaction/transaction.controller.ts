// src/transactions/transaction.controller.ts
import { Request, Response, NextFunction } from 'express';
import {
  createTransaction,
  getAllTransactions,
  getTransactionById,
  getTransactionStatistics,
} from './transaction.service';

export const createTransactionController = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const userId = req.user?.userId;
    if (!userId) {
      return res
        .status(401)
        .json({ success: false, message: 'Unauthorized' });
    }

    const { items } = req.body;
    const result = await createTransaction(userId, items);

    res.status(201).json({
      success: true,
      message: 'Transaction created successfully',
      data: result,
    });
  } catch (error: any) {
    // Tangani error spesifik dari service (stok kurang, buku tidak ada)
    res.status(400).json({
      success: false,
      message: error.message,
    });
  }
};

export const getAllTransactionsController = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const transactions = await getAllTransactions();
    res.status(200).json({
      success: true,
      message: 'Get all transaction successfully',
      data: transactions,
    });
  } catch (error) {
    next(error);
  }
};

export const getTransactionByIdController = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const { id } = req.params;
    const transaction = await getTransactionById(id);

    if (!transaction) {
      return res.status(404).json({
        success: false,
        message: 'Transaction not found',
      });
    }

    res.status(200).json({
      success: true,
      message: 'Get transaction detail successfully',
      data: transaction,
    });
  } catch (error) {
    next(error);
  }
};

export const getTransactionStatisticsController = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const stats = await getTransactionStatistics();
    res.status(200).json({
      success: true,
      message: 'Get transactions statistics successfully',
      data: stats,
    });
  } catch (error) {
    next(error);
  }
};