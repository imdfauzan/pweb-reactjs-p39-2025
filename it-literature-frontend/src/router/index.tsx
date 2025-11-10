// src/router/index.tsx
import { createBrowserRouter, RouterProvider } from 'react-router-dom';
import Login from '../pages/Login';
import Register from '../pages/Register';
// Nanti kita akan isi ini dengan halaman-halaman kita
const routerConfig = createBrowserRouter([
  {
    path: '/login',
    element: <Login />, // <-- Ganti di sini
  },
  {
    path: '/register',
    element: <Register />, // <-- Ganti di sini
  },
  {
    path: '/',
    element: <div>Halaman Utama (Nanti jadi List Buku)</div>,
  },
]);

// Komponen utama yang akan me-render router
const AppRouter = () => {
  return <RouterProvider router={routerConfig} />;
};

export default AppRouter;