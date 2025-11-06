// src/books/book.controller.ts
import { Request, Response, NextFunction } from 'express';
import { createBook, getAllBooks } from './book.service';
import {
  getBookById,
  updateBook,
  deleteBook,
  getBooksByGenre,
} from './book.service';

export const createBookController = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const book = await createBook(req.body);

    res.status(201).json({
      success: true,
      message: 'Book added successfully',
      data: {
        id: book.id,
        title: book.title,
        created_at: book.created_at,
      },
    });
  } catch (error: any) {
    // P2002: Judul buku duplikat
    if (error.code === 'P2002') {
      return res.status(409).json({
        success: false,
        message: 'Book with that title already exists',
      });
    }
    // P2003: Foreign key constraint failed (genre_id tidak valid)
    if (error.code === 'P2003') {
      return res.status(400).json({
        success: false,
        message: 'Invalid genre_id: Genre does not exist',
      });
    }
    next(error);
  }
};

export const getAllBooksController = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const { page, limit, search, genre_id, min_price, max_price } = req.query;

    const filters = {
      page: page ? parseInt(page as string) : undefined,
      limit: limit ? parseInt(limit as string) : undefined,
      search: search as string,
      genre_id: genre_id as string,
      min_price: min_price ? parseFloat(min_price as string) : undefined,
      max_price: max_price ? parseFloat(max_price as string) : undefined,
    };

    const result = await getAllBooks(filters);
    
    res.status(200).json({
      success: true,
      message: 'Get all book successfully',
      data: result.data,
      pagination: result.pagination,
    });
  } catch (error) {
    next(error);
  }
};

export const getBookByIdController = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const { id } = req.params;
    const book = await getBookById(id);

    if (!book) {
      return res.status(404).json({
        success: false,
        message: 'Book not found',
      });
    }

    res.status(200).json({
      success: true,
      message: 'Get book detail successfully',
      data: book,
    });
  } catch (error) {
    next(error);
  }
};

export const updateBookController = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const { id } = req.params;
    const book = await updateBook(id, req.body);
    res.status(200).json({
      success: true,
      message: 'Book updated successfully',
      data: {
        id: book.id,
        title: book.title,
        updated_at: book.updated_at,
      },
    });
  } catch (error: any) {
    // P2025: Gagal update karena record tidak ditemukan
    if (error.code === 'P2025') {
      return res.status(404).json({
        success: false,
        message: 'Book not found',
      });
    }
    next(error);
  }
};

export const deleteBookController = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const { id } = req.params;
    await deleteBook(id);
    res.status(200).json({
      success: true,
      message: 'Book removed successfully',
    });
  } catch (error: any) {
    // P2025: Gagal delete karena record tidak ditemukan
    if (error.code === 'P2025') {
      return res.status(404).json({
        success: false,
        message: 'Book not found',
      });
    }
    next(error);
  }
};

export const getBooksByGenreController = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const { id } = req.params;
    const { page, limit, search, min_price, max_price } = req.query;

    const filters = {
      page: page ? parseInt(page as string) : undefined,
      limit: limit ? parseInt(limit as string) : undefined,
      search: search as string,
      min_price: min_price ? parseFloat(min_price as string) : undefined,
      max_price: max_price ? parseFloat(max_price as string) : undefined,
    };

    const result = await getBooksByGenre(id, filters);
    
    res.status(200).json({
      success: true,
      message: 'Get all book by genre successfully',
      data: result.data,
      pagination: result.pagination,
    });
  } catch (error) {
    next(error);
  }
};