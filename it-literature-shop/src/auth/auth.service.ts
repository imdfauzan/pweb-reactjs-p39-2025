// src/auth/auth.service.ts
import prisma from '../utils/prisma';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken'; // <-- Import JWT

// Tipe data untuk input register
type CreateUserInput = {
  email: string;
  username: string;
  password: string;
};

export const createUser = async (input: CreateUserInput) => {
  // Hash password sebelum disimpan
  const hashedPassword = await bcrypt.hash(input.password, 10);

  const user = await prisma.users.create({
    data: {
      email: input.email,
      username: input.username,
      password: hashedPassword,
    },
  });

  return user;
};

type LoginUserInput = {
  email: string;
  password: string;
};

export const loginUser = async (input: LoginUserInput) => {
  // 1. Cari user berdasarkan email
  const user = await prisma.users.findFirst({
    where: { email: input.email },
  });

  if (!user) {
    throw new Error('Invalid credentials');
  }

  // 2. Bandingkan password yang diinput dengan yang ada di database
  const isPasswordValid = await bcrypt.compare(input.password, user.password);

  if (!isPasswordValid) {
    throw new Error('Invalid credentials');
  }

  // 3. Jika valid, buat access token
  const secret = process.env.JWT_SECRET;
  if (!secret) {
    throw new Error('JWT secret not found');
  }

  const accessToken = jwt.sign({ userId: user.id }, secret, {
    expiresIn: '1d', // Token berlaku selama 1 hari
  });

  return accessToken;
};

export const findUserById = async (id: string) => {
  const user = await prisma.users.findUnique({
    where: { id },
  });

  if (!user) {
    throw new Error('User not found');
  }

  // Kita tidak ingin mengirim password ke client
  const { password, ...userWithoutPassword } = user;
  return userWithoutPassword;
};