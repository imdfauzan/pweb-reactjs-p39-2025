// src/auth/auth.controller.ts

/// <reference path="../types/express.d.ts" />
import { Request, Response, NextFunction } from 'express';
import { createUser, loginUser, findUserById } from './auth.service';

export const registerUserController = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const { email, password, username } = req.body;

    // Panggil service untuk membuat user baru
    const user = await createUser({ email, password, username });

    // Kirim response sesuai format yang diminta
    res.status(201).json({
      success: true,
      message: 'User registered successfully',
      data: {
        id: user.id,
        email: user.email,
        created_at: user.created_at,
      },
    });
  } catch (error: any) {
    // Jika email atau username sudah ada, Prisma akan melempar error unik
    // Kode P2002 adalah untuk unique constraint violation
    if (error.code === 'P2002') {
      // Cek field mana yang duplikat dari error meta
      const field = error.meta?.target?.[0] || 'field';
      const message = field === 'email' 
        ? 'Email already exists' 
        : field === 'username'
        ? 'Username already exists'
        : 'Duplicate entry';
      
      return res.status(409).json({ // 409 Conflict
        success: false,
        message,
      });
    }
    // Kirim error ke error handler global jika ada masalah lain
    next(error);
  }
};

export const loginUserController = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const { email, password } = req.body;
    const accessToken = await loginUser({ email, password });

    res.status(200).json({
      success: true,
      message: 'Login successful',
      data: {
        token: accessToken,
      },
    });
  } catch (error: any) {
    // Tangani error 'Invalid credentials' dari service
    if (error.message === 'Invalid credentials') {
      return res.status(401).json({ // 401 Unauthorized
        success: false,
        message: 'Invalid credentials',
      });
    }
    next(error);
  }
};

export const getMeController = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    // req.user diisi oleh middleware authenticate
    const userId = req.user?.userId;

    if (!userId) {
      return res.status(401).json({
        success: false,
        message: 'Unauthorized',
      });
    }

    const user = await findUserById(userId);

    res.status(200).json({
      success: true,
      message: 'Get me successfully',
      data: {
        id: user.id,
        username: user.username,
        email: user.email,
      },
    });
  } catch (error) {
    next(error);
  }
};