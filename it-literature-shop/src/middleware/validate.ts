// src/middleware/validate.ts
import { Request, Response, NextFunction } from 'express';
import { ZodObject } from 'zod';

const validate =
  (schema: ZodObject) =>
  (req: Request, res: Response, next: NextFunction) => {
    try {
      schema.parse({
        body: req.body,
        query: req.query,
        params: req.params,
      });
      next();
    } catch (e: any) {
      return res.status(400).json({
        success: false,
        message: 'Validation error',
        errors: e.errors,
      });
    }
  };

export default validate;