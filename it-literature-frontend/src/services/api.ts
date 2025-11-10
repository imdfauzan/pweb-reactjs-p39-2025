// src/services/api.ts
import axios from 'axios';

// Buat instance axios dengan baseURL
const api = axios.create({
  baseURL: 'http://localhost:8080', // Sesuaikan port jika backend Anda berjalan di port lain
});

// Ini adalah 'interceptor'
// Kode ini akan otomatis menambahkan token dari local storage
// ke setiap request yang kita kirim
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('accessToken');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
}, (error) => {
  return Promise.reject(error);
});

export default api;