// src/transactions/transaction.service.ts
import prisma from '../utils/prisma';

interface TransactionItem {
  book_id: string;
  quantity: number;
}

export const createTransaction = async (
  userId: string,
  items: TransactionItem[]
) => {
  // prisma.$transaction memastikan semua query di dalamnya berhasil atau semuanya gagal
  const result = await prisma.$transaction(async (tx) => {
    // 1. Ambil semua data buku yang dipesan dalam satu query
    const bookIds = items.map((item) => item.book_id);
    const books = await tx.books.findMany({
      where: {
        id: { in: bookIds },
        deleted_at: null, // Pastikan buku belum dihapus
      },
    });

    // 2. Validasi stok dan keberadaan buku
    let total_price = 0;
    let total_quantity = 0;

    for (const item of items) {
      const book = books.find((b) => b.id === item.book_id);
      if (!book) {
        throw new Error(`Book with id ${item.book_id} not found.`);
      }
      if (book.stock_quantity < item.quantity) {
        throw new Error(`Not enough stock for book: ${book.title}.`);
      }
      total_price += Number(book.price) * item.quantity;
      total_quantity += item.quantity;
    }

    // 3. Buat record Order
    const order = await tx.orders.create({
      data: {
        user_id: userId,
      },
    });

    // 4. Buat record OrderItem untuk setiap item
    await tx.order_items.createMany({
      data: items.map((item) => ({
        order_id: order.id,
        book_id: item.book_id,
        quantity: item.quantity,
      })),
    });

    // 5. Update stok setiap buku (ini bagian paling krusial)
    for (const item of items) {
      await tx.books.update({
        where: { id: item.book_id },
        data: {
          stock_quantity: {
            decrement: item.quantity,
          },
        },
      });
    }

    // 6. Kembalikan hasil yang akan digunakan di controller
    return {
      transaction_id: order.id,
      total_quantity,
      total_price,
    };
  });

  return result;
};

export const getAllTransactions = async () => {
  const orders = await prisma.orders.findMany({
    include: {
      order_items: {
        include: {
          books: true, // Ambil data buku untuk menghitung total harga
        },
      },
    },
    orderBy: {
      created_at: 'desc', // Tampilkan yang terbaru dulu
    },
  });

  // Format data agar sesuai dengan response yang diinginkan
  return orders.map((order) => {
    const total_quantity = order.order_items.reduce(
      (sum, item) => sum + item.quantity,
      0
    );
    const total_price = order.order_items.reduce(
      (sum, item) => sum + item.quantity * Number(item.books.price),
      0
    );
    return {
      id: order.id,
      total_quantity,
      total_price,
    };
  });
};

export const getTransactionById = async (orderId: string) => {
  const order = await prisma.orders.findUnique({
    where: { id: orderId },
    include: {
      order_items: {
        select: {
          quantity: true,
          books: {
            select: {
              id: true,
              title: true,
              price: true,
            },
          },
        },
      },
    },
  });

  if (!order) {
    return null;
  }

  // Format data agar sesuai response
  const total_quantity = order.order_items.reduce(
    (sum, item) => sum + item.quantity,
    0
  );
  const total_price = order.order_items.reduce(
    (sum, item) => sum + item.quantity * Number(item.books.price),
    0
  );

  return {
    id: order.id,
    items: order.order_items.map((item) => ({
      book_id: item.books.id,
      book_title: item.books.title,
      quantity: item.quantity,
      subtotal_price: item.quantity * Number(item.books.price),
    })),
    total_quantity,
    total_price,
  };
};

export const getTransactionStatistics = async () => {
    // 1. Hitung total transaksi
    const total_transactions = await prisma.orders.count();
  
    // 2. Kalkulasi total penjualan dari semua item di semua order
    const allOrderItems = await prisma.order_items.findMany({
      include: { books: true },
    });
    const totalRevenue = allOrderItems.reduce(
      (sum, item) => sum + item.quantity * Number(item.books.price),
      0
    );
  
    // 3. Hitung rata-rata
    const average_transaction_amount = total_transactions > 0 ? totalRevenue / total_transactions : 0;
  
    // 4. Cari genre penjualan terbanyak dan tersedikit
    const genreSales = await prisma.genres.findMany({
      include: {
        books: {
          include: {
            order_items: {
              select: { quantity: true },
            },
          },
        },
      },
    });
  
    let maxSales = -1;
    let minSales = Infinity;
    let most_book_sales_genre = 'N/A';
    let fewest_book_sales_genre = 'N/A';
  
    genreSales.forEach(genre => {
      const totalQuantity = genre.books.reduce((genreSum, book) => {
        return genreSum + book.order_items.reduce((bookSum, item) => bookSum + item.quantity, 0);
      }, 0);
  
      if (totalQuantity > 0) {
        if (totalQuantity > maxSales) {
          maxSales = totalQuantity;
          most_book_sales_genre = genre.name;
        }
        if (totalQuantity < minSales) {
          minSales = totalQuantity;
          fewest_book_sales_genre = genre.name;
        }
      }
    });
  
    return {
      total_transactions,
      average_transaction_amount,
      most_book_sales_genre,
      fewest_book_sales_genre,
    };
  };