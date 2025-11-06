// src/genres/genre.controller.ts
import { Request, Response, NextFunction } from 'express';
import { createGenre, getAllGenres } from './genre.service';
import { getGenreById, updateGenre, deleteGenre } from './genre.service';

export const createGenreController = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const { name } = req.body;
    const genre = await createGenre(name);

    res.status(201).json({
      success: true,
      message: 'Genre created successfully',
      data: {
        id: genre.id,
        name: genre.name,
        created_at: genre.created_at,
      },
    });
  } catch (error: any) {
    // Tangani error jika nama genre sudah ada
    if (error.code === 'P2002') {
      return res.status(409).json({
        success: false,
        message: 'Genre with that name already exists',
      });
    }
    next(error);
  }
};

export const getAllGenresController = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const genres = await getAllGenres();
    res.status(200).json({
      success: true,
      message: 'Get all genre successfully',
      data: genres,
      // Kita akan tambahkan 'meta' untuk pagination nanti
    });
  } catch (error) {
    next(error);
  }
};

export const getGenreByIdController = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const { id } = req.params;
    const genre = await getGenreById(id);

    if (!genre) {
      return res.status(404).json({
        success: false,
        message: 'Genre not found',
      });
    }

    res.status(200).json({
      success: true,
      message: 'Get genre detail successfully',
      data: genre,
    });
  } catch (error) {
    next(error);
  }
};

export const updateGenreController = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const { id } = req.params;
    const { name } = req.body;
    const genre = await updateGenre(id, name);

    res.status(200).json({
      success: true,
      message: 'Genre updated successfully',
      data: {
        id: genre.id,
        name: genre.name,
        updated_at: genre.updated_at,
      },
    });
  } catch (error: any) {
    // P2025: Record to update not found
    if (error.code === 'P2025') {
      return res.status(404).json({
        success: false,
        message: 'Genre not found',
      });
    }
    // P2002: Unique constraint failed (nama sudah ada)
    if (error.code === 'P2002') {
        return res.status(409).json({
          success: false,
          message: 'Genre with that name already exists',
        });
      }
    next(error);
  }
};

export const deleteGenreController = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const { id } = req.params;
    await deleteGenre(id);
    res.status(200).json({
      success: true,
      message: 'Genre removed successfully',
    });
  } catch (error: any) {
    // P2025: Record to delete not found
    if (error.code === 'P2025') {
      return res.status(404).json({
        success: false,
        message: 'Genre not found',
      });
    }
    next(error);
  }
};