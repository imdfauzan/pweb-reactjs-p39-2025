# 🔧 Changelog - Bug Fixes & Improvements

## Tanggal: 24 Oktober 2025

### 📋 Ringkasan Perbaikan

Dokumen ini mencatat semua perbaikan yang dilakukan pada IT Literature Shop API untuk meningkatkan validasi, keamanan, dan konsistensi data.

---

## ✅ Perbaikan yang Dilakukan

### 1. **Validasi Register - Parameter Wajib** ✓

**Problem:**
- Username bersifat optional saat register
- Bisa register tanpa username

**Solution:**
```typescript
// auth.validation.ts
username: z.string().min(1, { message: 'Username is required' })
```

**Impact:**
- ❌ Request tanpa username akan ditolak dengan status 400
- ✅ Semua user harus memiliki username

---

### 2. **Login dengan Username ATAU Email** ✓

**Problem:**
- Login hanya bisa dengan username saja
- Tidak fleksibel untuk user

**Solution:**
```typescript
// auth.validation.ts
identifier: z.string().min(1, { message: 'Username or email is required' })

// auth.service.ts
const user = await prisma.users.findFirst({
  where: {
    OR: [
      { username: input.identifier },
      { email: input.identifier },
    ],
  },
});
```

**Impact:**
- ✅ User bisa login dengan username: `"identifier": "admin"`
- ✅ User bisa login dengan email: `"identifier": "admin@example.com"`

**Request Body:**
```json
{
  "identifier": "admin",  // bisa username atau email
  "password": "password123"
}
```

---

### 3. **Duplikasi Genre - Validation** ✓

**Problem:**
- Bisa membuat genre dengan nama yang sama berkali-kali
- Data duplikat di database

**Solution:**
```typescript
// genre.service.ts - createGenre
const existingGenre = await prisma.genres.findFirst({
  where: { 
    name: {
      equals: name,
      mode: 'insensitive', // Case-insensitive
    }
  },
});

if (existingGenre) {
  if (existingGenre.deleted_at) {
    // Restore jika sudah dihapus
    return await prisma.genres.update({
      where: { id: existingGenre.id },
      data: { deleted_at: null },
    });
  }
  // Throw error jika masih aktif
  throw error with code P2002;
}
```

**Impact:**
- ❌ Tidak bisa membuat genre duplikat (status 409)
- ✅ Jika genre sudah ada tapi terhapus, akan di-restore otomatis
- ✅ Case-insensitive: "Programming" = "programming" = "PROGRAMMING"

---

### 4. **Update Genre - Duplikasi Check** ✓

**Problem:**
- Saat update genre, bisa menggunakan nama yang sudah ada
- Tidak ada validasi duplikasi

**Solution:**
```typescript
// genre.service.ts - updateGenre
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
  throw error with code P2002;
}
```

**Impact:**
- ❌ Update ke nama yang sudah ada akan ditolak (status 409)
- ✅ Bisa update ke nama yang sama (tidak berubah)

---

### 5. **PATCH untuk Partial Updates** ✓

**Problem:**
- Menggunakan PUT untuk update padahal hanya update sebagian field
- REST convention: PUT = full update, PATCH = partial update

**Solution:**
```typescript
// genre.routes.ts & book.routes.ts
router.patch('/:id', validate(updateSchema), updateController);
```

**Impact:**
- ✅ Lebih sesuai dengan REST API best practices
- ✅ Update hanya field yang dikirim

**Before:**
```http
PUT /genre/{id}
```

**After:**
```http
PATCH /genre/{id}
```

---

### 6. **Delete Protection - Prevent Double Delete** ✓

**Problem:**
- Delete bisa dipanggil berkali-kali untuk ID yang sama
- Tidak ada error saat delete yang sudah terhapus
- Soft delete tidak memeriksa `deleted_at`

**Solution:**
```typescript
// genre.service.ts & book.service.ts - deleteGenre/deleteBook
const genre = await prisma.genres.findFirst({
  where: { id, deleted_at: null },
});

if (!genre) {
  throw error with code P2025; // Not found
}

await prisma.genres.update({
  where: { id },
  data: { deleted_at: new Date() },
});
```

**Impact:**
- ✅ Delete pertama: 200 OK
- ❌ Delete kedua: 404 Not Found
- ✅ Tidak bisa double delete

**Response Behavior:**
```
DELETE /genre/123 (pertama kali)   → 200 OK
DELETE /genre/123 (kedua kali)     → 404 Not Found
DELETE /genre/invalid-id           → 404 Not Found
```

---

### 7. **Update Validation - Check Existence** ✓

**Problem:**
- Update tidak memeriksa apakah record ada sebelum update
- Error dari Prisma kurang jelas

**Solution:**
```typescript
// genre.service.ts & book.service.ts
const existingGenre = await prisma.genres.findFirst({
  where: { id, deleted_at: null },
});

if (!existingGenre) {
  throw error with code P2025;
}
```

**Impact:**
- ❌ Update record yang tidak ada: 404 Not Found
- ❌ Update record yang sudah dihapus: 404 Not Found
- ✅ Error message lebih jelas

---

### 8. **Register Error Handling** ✓

**Problem:**
- Error message hanya "Email already exists" padahal bisa jadi username yang duplikat

**Solution:**
```typescript
// auth.controller.ts
if (error.code === 'P2002') {
  const field = error.meta?.target?.[0] || 'field';
  const message = field === 'email' 
    ? 'Email already exists' 
    : field === 'username'
    ? 'Username already exists'
    : 'Duplicate entry';
  
  return res.status(409).json({
    success: false,
    message,
  });
}
```

**Impact:**
- ✅ Error message spesifik untuk email duplikat
- ✅ Error message spesifik untuk username duplikat

---

## 🧪 Testing

### Test Script Updates

File: `test-all-endpoints.ps1`

**Changes:**
1. Login request menggunakan `identifier` bukan `username`
2. Update genre menggunakan PATCH bukan PUT
3. Update book menggunakan PATCH bukan PUT

**Run Test:**
```powershell
.\test-all-endpoints.ps1
```

---

## 📊 Summary

| No | Issue | Status | Response Code |
|----|-------|--------|---------------|
| 1 | Register tanpa username | ✅ Fixed | 400 Bad Request |
| 2 | Login hanya username | ✅ Fixed | Now supports email too |
| 3 | Genre duplikasi | ✅ Fixed | 409 Conflict |
| 4 | Update genre duplikasi | ✅ Fixed | 409 Conflict |
| 5 | PUT untuk partial update | ✅ Fixed | Changed to PATCH |
| 6 | Double delete | ✅ Fixed | 404 Not Found (2nd delete) |
| 7 | Update tanpa validasi | ✅ Fixed | 404 if not exists |
| 8 | Generic error message | ✅ Fixed | Specific messages |

---

## 🚀 Cara Menggunakan

### 1. Restart Server
```bash
npm run dev
```

### 2. Test Register (All fields required)
```http
POST http://localhost:8080/auth/register
Content-Type: application/json

{
  "username": "johndoe",     # WAJIB
  "email": "john@example.com", # WAJIB
  "password": "password123"   # WAJIB (min 6 chars)
}
```

### 3. Test Login (Username or Email)
```http
POST http://localhost:8080/auth/login
Content-Type: application/json

{
  "identifier": "johndoe",  # Bisa username ATAU email
  "password": "password123"
}
```

### 4. Test Update (PATCH, not PUT)
```http
PATCH http://localhost:8080/genre/{id}
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "New Genre Name"
}
```

### 5. Test Delete (Only once)
```http
DELETE http://localhost:8080/genre/{id}
Authorization: Bearer {token}

# First time: 200 OK
# Second time: 404 Not Found
```

---

## 🔍 Error Responses

### Register Errors
```json
// Missing username
{
  "success": false,
  "message": "Username is required"
}

// Duplicate username
{
  "success": false,
  "message": "Username already exists"
}

// Duplicate email
{
  "success": false,
  "message": "Email already exists"
}
```

### Genre Errors
```json
// Duplicate genre
{
  "success": false,
  "message": "Genre with that name already exists"
}

// Genre not found (delete/update)
{
  "success": false,
  "message": "Genre not found"
}
```

---

## ✨ Best Practices Applied

1. ✅ **Proper HTTP Methods**: PATCH for partial updates
2. ✅ **Input Validation**: All required fields validated
3. ✅ **Duplicate Prevention**: Unique constraints enforced
4. ✅ **Soft Delete Protection**: Can't delete twice
5. ✅ **Case-Insensitive Checks**: Genre names compared properly
6. ✅ **Clear Error Messages**: Specific error responses
7. ✅ **Flexible Login**: Username or email supported
8. ✅ **Auto-Restore**: Deleted genres can be restored

---

## 📝 Notes

- Semua perubahan backward compatible kecuali login request body
- Test script sudah diupdate untuk semua perubahan
- Database schema tidak berubah
- Semua soft delete tetap berfungsi

**Restart server untuk apply semua perubahan!**
