// src/middleware/auth.ts
import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';

export const authenticate = (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    // 1. Dapatkan header Authorization
    const authHeader = req.headers.authorization;

    // 2. Cek jika header ada dan formatnya benar ('Bearer <token>')
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        message: 'Unauthorized: No token provided',
      });
    }

    // 3. Ekstrak token dari header
    const token = authHeader.split(' ')[1];
    const secret = process.env.JWT_SECRET;

    if (!secret) {
      throw new Error('JWT_SECRET is not defined in environment variables');
    }

    // 4. Verifikasi token
    const decoded = jwt.verify(token, secret) as { userId: string };

    // 5. Tambahkan payload yang sudah di-decode ke objek request
    req.user = { userId: decoded.userId };

    // 6. Lanjutkan ke controller berikutnya
    next();
  } catch (error) {
    // Tangani jika token tidak valid atau kedaluwarsa
    return res.status(401).json({
      success: false,
      message: 'Unauthorized: Invalid token',
    });
  }
};