// prisma/seed.ts
import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Starting database seeding...\n');

  // Clear existing data (optional - be careful in production!)
  console.log('🗑️  Clearing existing data...');
  await prisma.order_items.deleteMany();
  await prisma.orders.deleteMany();
  await prisma.books.updateMany({
    data: { deleted_at: null }
  });
  await prisma.genres.updateMany({
    data: { deleted_at: null }
  });
  await prisma.users.deleteMany();
  await prisma.books.deleteMany();
  await prisma.genres.deleteMany();

  // Hash password once
  const hashedPassword = await bcrypt.hash('password123', 10);
  console.log('🔐 Password hashed successfully\n');

  // Create users
  console.log('👥 Creating users...');
  const admin = await prisma.users.create({
    data: {
      username: 'admin',
      email: 'admin@example.com',
      password: hashedPassword,
    },
  });
  console.log(`✅ Created user: ${admin.username} (${admin.email})`);

  const testuser = await prisma.users.create({
    data: {
      username: 'testuser',
      email: 'testuser@example.com',
      password: hashedPassword,
    },
  });
  console.log(`✅ Created user: ${testuser.username} (${testuser.email})`);

  const johndoe = await prisma.users.create({
    data: {
      username: 'johndoe',
      email: 'john.doe@example.com',
      password: hashedPassword,
    },
  });
  console.log(`✅ Created user: ${johndoe.username} (${johndoe.email})\n`);

  // Create genres
  console.log('📚 Creating genres...');
  const programming = await prisma.genres.create({
    data: { name: 'Programming' },
  });
  console.log(`✅ Created genre: ${programming.name}`);

  const database = await prisma.genres.create({
    data: { name: 'Database' },
  });
  console.log(`✅ Created genre: ${database.name}`);

  const webDev = await prisma.genres.create({
    data: { name: 'Web Development' },
  });
  console.log(`✅ Created genre: ${webDev.name}`);

  const networking = await prisma.genres.create({
    data: { name: 'Networking' },
  });
  console.log(`✅ Created genre: ${networking.name}`);

  const security = await prisma.genres.create({
    data: { name: 'Security' },
  });
  console.log(`✅ Created genre: ${security.name}\n`);

  // Create books
  console.log('📖 Creating books...');
  const book1 = await prisma.books.create({
    data: {
      title: 'Clean Code',
      writer: 'Robert C. Martin',
      publisher: 'Prentice Hall',
      publication_year: 2008,
      description: 'A Handbook of Agile Software Craftsmanship',
      price: 45.99,
      stock_quantity: 100,
      genre_id: programming.id,
    },
  });
  console.log(`✅ Created book: ${book1.title}`);

  const book2 = await prisma.books.create({
    data: {
      title: 'Database System Concepts',
      writer: 'Abraham Silberschatz',
      publisher: 'McGraw-Hill',
      publication_year: 2019,
      description: 'Comprehensive database fundamentals',
      price: 89.99,
      stock_quantity: 50,
      genre_id: database.id,
    },
  });
  console.log(`✅ Created book: ${book2.title}`);

  const book3 = await prisma.books.create({
    data: {
      title: 'JavaScript: The Good Parts',
      writer: 'Douglas Crockford',
      publisher: "O'Reilly Media",
      publication_year: 2008,
      description: 'JavaScript essential features',
      price: 29.99,
      stock_quantity: 75,
      genre_id: webDev.id,
    },
  });
  console.log(`✅ Created book: ${book3.title}`);

  const book4 = await prisma.books.create({
    data: {
      title: 'Computer Networking: A Top-Down Approach',
      writer: 'James Kurose',
      publisher: 'Pearson',
      publication_year: 2020,
      description: 'Modern networking fundamentals',
      price: 99.99,
      stock_quantity: 40,
      genre_id: networking.id,
    },
  });
  console.log(`✅ Created book: ${book4.title}`);

  const book5 = await prisma.books.create({
    data: {
      title: 'The Art of Computer Programming',
      writer: 'Donald Knuth',
      publisher: 'Addison-Wesley',
      publication_year: 1968,
      description: 'Fundamental algorithms and data structures',
      price: 199.99,
      stock_quantity: 25,
      genre_id: programming.id,
    },
  });
  console.log(`✅ Created book: ${book5.title}`);

  const book6 = await prisma.books.create({
    data: {
      title: 'Introduction to Algorithms',
      writer: 'Thomas H. Cormen',
      publisher: 'MIT Press',
      publication_year: 2009,
      description: 'Comprehensive algorithms textbook',
      price: 89.99,
      stock_quantity: 60,
      genre_id: programming.id,
    },
  });
  console.log(`✅ Created book: ${book6.title}`);

  const book7 = await prisma.books.create({
    data: {
      title: 'Web Security Testing Cookbook',
      writer: 'Paco Hope',
      publisher: "O'Reilly Media",
      publication_year: 2008,
      description: 'Practical web security testing',
      price: 49.99,
      stock_quantity: 30,
      genre_id: security.id,
    },
  });
  console.log(`✅ Created book: ${book7.title}`);

  const book8 = await prisma.books.create({
    data: {
      title: 'Learning React',
      writer: 'Alex Banks',
      publisher: "O'Reilly Media",
      publication_year: 2020,
      description: 'Modern React development',
      price: 39.99,
      stock_quantity: 80,
      genre_id: webDev.id,
    },
  });
  console.log(`✅ Created book: ${book8.title}`);

  const book9 = await prisma.books.create({
    data: {
      title: 'PostgreSQL: Up and Running',
      writer: 'Regina Obe',
      publisher: "O'Reilly Media",
      publication_year: 2017,
      description: 'PostgreSQL database guide',
      price: 44.99,
      stock_quantity: 55,
      genre_id: database.id,
    },
  });
  console.log(`✅ Created book: ${book9.title}`);

  const book10 = await prisma.books.create({
    data: {
      title: 'Node.js Design Patterns',
      writer: 'Mario Casciaro',
      publisher: 'Packt Publishing',
      publication_year: 2020,
      description: 'Advanced Node.js patterns',
      price: 54.99,
      stock_quantity: 45,
      genre_id: webDev.id,
    },
  });
  console.log(`✅ Created book: ${book10.title}\n`);

  // Create sample transactions
  console.log('💰 Creating sample transactions...');
  const order1 = await prisma.orders.create({
    data: {
      user_id: admin.id,
      order_items: {
        create: [
          {
            book_id: book1.id,
            quantity: 1,
          },
          {
            book_id: book3.id,
            quantity: 1,
          },
        ],
      },
    },
  });
  console.log(`✅ Created transaction: ${order1.id}`);

  const order2 = await prisma.orders.create({
    data: {
      user_id: testuser.id,
      order_items: {
        create: [
          {
            book_id: book2.id,
            quantity: 1,
          },
        ],
      },
    },
  });
  console.log(`✅ Created transaction: ${order2.id}`);

  console.log('\n✅ Database seeding completed successfully!\n');
  console.log('📊 Summary:');
  console.log(`   - Users: 3 (admin, testuser, johndoe)`);
  console.log(`   - Genres: 5`);
  console.log(`   - Books: 10`);
  console.log(`   - Transactions: 2`);
  console.log('\n🔑 Login credentials:');
  console.log(`   Email: admin@example.com`);
  console.log(`   Password: password123\n`);
}

main()
  .catch((e) => {
    console.error('❌ Error seeding database:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
