// src/books/book.service.ts
import prisma from '../utils/prisma';

type CreateBookInput = {
  title: string;
  writer: string;
  publisher: string;
  publication_year: number;
  description: string;
  price: number;
  stock_quantity: number;
  genre_id: string;
};

export const createBook = async (input: CreateBookInput) => {
  // Cek duplikasi title (case-insensitive)
  const existingBook = await prisma.books.findFirst({
    where: {
      title: {
        equals: input.title,
        mode: 'insensitive',
      },
      deleted_at: null,
    },
  });

  if (existingBook) {
    const error: any = new Error('Book with that title already exists');
    error.code = 'P2002';
    throw error;
  }

  const book = await prisma.books.create({
    data: input,
  });
  return book;
};

export const getAllBooks = async (filters?: {
  page?: number;
  limit?: number;
  search?: string;
  genre_id?: string;
  min_price?: number;
  max_price?: number;
}) => {
  const page = filters?.page || 1;
  const limit = filters?.limit || 10;
  const skip = (page - 1) * limit;

  // Build where clause
  const where: any = {
    deleted_at: null,
  };

  if (filters?.search) {
    where.OR = [
      { title: { contains: filters.search, mode: 'insensitive' } },
      { writer: { contains: filters.search, mode: 'insensitive' } },
      { publisher: { contains: filters.search, mode: 'insensitive' } },
    ];
  }

  if (filters?.genre_id) {
    where.genre_id = filters.genre_id;
  }

  if (filters?.min_price !== undefined || filters?.max_price !== undefined) {
    where.price = {};
    if (filters.min_price !== undefined) {
      where.price.gte = filters.min_price;
    }
    if (filters.max_price !== undefined) {
      where.price.lte = filters.max_price;
    }
  }

  // Get total count for pagination
  const total = await prisma.books.count({ where });

  // Get books
  const books = await prisma.books.findMany({
    where,
    select: {
      id: true,
      title: true,
      writer: true,
      publisher: true,
      publication_year: true,
      price: true,
      stock_quantity: true,
      genres: {
        select: {
          name: true,
        },
      },
    },
    skip,
    take: limit,
    orderBy: {
      created_at: 'desc',
    },
  });

  return {
    data: books,
    pagination: {
      page,
      limit,
      total,
      total_pages: Math.ceil(total / limit),
    },
  };
};

export const getBookById = async (id: string) => {
  const book = await prisma.books.findFirst({
    where: { id, deleted_at: null },
    select: {
      id: true,
      title: true,
      writer: true,
      publisher: true,
      publication_year: true,
      price: true,
      stock_quantity: true,
      description: true,
      genres: {
        select: {
          name: true,
        },
      },
    },
  });

  if (!book) return null;

  return {
    ...book,
    genre: book.genres.name,
  };
};

interface UpdateBookInput {
  description?: string;
  price?: number;
  stock_quantity?: number;
}

export const updateBook = async (id: string, data: UpdateBookInput) => {
  // Cek apakah book ada dan belum dihapus
  const existingBook = await prisma.books.findFirst({
    where: { id, deleted_at: null },
  });

  if (!existingBook) {
    const error: any = new Error('Book not found');
    error.code = 'P2025';
    throw error;
  }

  // Update book
  const book = await prisma.books.update({
    where: { id },
    data,
  });
  return book;
};

export const deleteBook = async (id: string) => {
  // Cek apakah book ada dan belum dihapus
  const book = await prisma.books.findFirst({
    where: { id, deleted_at: null },
  });

  if (!book) {
    const error: any = new Error('Book not found');
    error.code = 'P2025';
    throw error;
  }

  // Soft delete - set deleted_at
  await prisma.books.update({
    where: { id },
    data: { deleted_at: new Date() },
  });
};

export const getBooksByGenre = async (
  genreId: string,
  filters?: {
    page?: number;
    limit?: number;
    search?: string;
    min_price?: number;
    max_price?: number;
  }
) => {
  const page = filters?.page || 1;
  const limit = filters?.limit || 10;
  const skip = (page - 1) * limit;

  // Build where clause
  const where: any = {
    genre_id: genreId,
    deleted_at: null,
  };

  if (filters?.search) {
    where.OR = [
      { title: { contains: filters.search, mode: 'insensitive' } },
      { writer: { contains: filters.search, mode: 'insensitive' } },
      { publisher: { contains: filters.search, mode: 'insensitive' } },
    ];
  }

  if (filters?.min_price !== undefined || filters?.max_price !== undefined) {
    where.price = {};
    if (filters.min_price !== undefined) {
      where.price.gte = filters.min_price;
    }
    if (filters.max_price !== undefined) {
      where.price.lte = filters.max_price;
    }
  }

  // Get total count
  const total = await prisma.books.count({ where });

  // Get books
  const books = await prisma.books.findMany({
    where,
    select: {
      id: true,
      title: true,
      writer: true,
      publisher: true,
      publication_year: true,
      price: true,
      stock_quantity: true,
      genres: {
        select: {
          name: true,
        },
      },
    },
    skip,
    take: limit,
    orderBy: {
      created_at: 'desc',
    },
  });

  return {
    data: books.map((book) => ({
      ...book,
      genre: book.genres.name,
    })),
    pagination: {
      page,
      limit,
      total,
      total_pages: Math.ceil(total / limit),
    },
  };
};  // <-- pastikan ada kurung tutup di sini
