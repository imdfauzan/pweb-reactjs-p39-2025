// src/utils/prisma.ts
import { PrismaClient } from '@prisma/client';

// Prisma Client instance with logging
const prisma = new PrismaClient({
  log: process.env.NODE_ENV === 'development' 
    ? ['query', 'info', 'warn', 'error'] 
    : ['error'],
});

export default prisma;