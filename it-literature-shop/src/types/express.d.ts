// src/types/express.d.ts
// Ini adalah file "declaration merging"
// untuk menambahkan properti 'user' ke tipe 'Request' dari Express

declare namespace Express {
  export interface Request {
    user?: {
      userId: string;
    };
  }
}