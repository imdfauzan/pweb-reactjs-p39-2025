// src/genres/genre.service.ts
import prisma from '../utils/prisma';

export const createGenre = async (name: string) => {
  // Cek dulu apakah genre dengan nama yang sama sudah ada (termasuk yang di-soft delete)
  const existingGenre = await prisma.genres.findFirst({
    where: { 
      name: {
        equals: name,
        mode: 'insensitive', // Case-insensitive comparison
      }
    },
  });

  if (existingGenre) {
    // Jika ada dan sudah dihapus, restore dengan undelete
    if (existingGenre.deleted_at) {
      const restoredGenre = await prisma.genres.update({
        where: { id: existingGenre.id },
        data: { deleted_at: null },
      });
      return restoredGenre;
    }
    // Jika masih aktif, throw error
    const error: any = new Error('Genre already exists');
    error.code = 'P2002';
    throw error;
  }

  // Jika belum ada, buat baru
  const genre = await prisma.genres.create({
    data: { name },
  });
  return genre;
};

// Fungsi untuk mendapatkan semua genre dengan filter
// Kita akan buat sederhana dulu, lalu tambahkan pagination nanti
export const getAllGenres = async () => {
  // Hanya ambil genre yang belum di "soft delete"
  const genres = await prisma.genres.findMany({
    where: {
      deleted_at: null,
    },
    select: {
      id: true,
      name: true,
    },
    orderBy: {
      name: 'asc', // Urutkan berdasarkan nama secara default
    },
  });
  return genres;
};

export const getGenreById = async (id: string) => {
  const genre = await prisma.genres.findFirst({
    where: { id, deleted_at: null }, // Pastikan tidak mengambil yang sudah di-soft-delete
    select: { id: true, name: true },
  });
  return genre;
};

export const updateGenre = async (id: string, name: string) => {
  // Cek apakah genre yang akan diupdate ada dan belum dihapus
  const existingGenre = await prisma.genres.findFirst({
    where: { id, deleted_at: null },
  });

  if (!existingGenre) {
    const error: any = new Error('Genre not found');
    error.code = 'P2025';
    throw error;
  }

  // Cek apakah nama baru sudah dipakai oleh genre lain
  const duplicateGenre = await prisma.genres.findFirst({
    where: {
      name: {
        equals: name,
        mode: 'insensitive',
      },
      id: { not: id }, // Exclude genre yang sedang diupdate
      deleted_at: null,
    },
  });

  if (duplicateGenre) {
    const error: any = new Error('Genre with that name already exists');
    error.code = 'P2002';
    throw error;
  }

  // Update genre
  const genre = await prisma.genres.update({
    where: { id },
    data: { name },
  });
  return genre;
};

export const deleteGenre = async (id: string) => {
  // Cek apakah genre ada dan belum dihapus
  const genre = await prisma.genres.findFirst({
    where: { id, deleted_at: null },
  });

  if (!genre) {
    const error: any = new Error('Genre not found');
    error.code = 'P2025';
    throw error;
  }

  // Soft delete - set deleted_at
  await prisma.genres.update({
    where: { id },
    data: { deleted_at: new Date() },
  });
};