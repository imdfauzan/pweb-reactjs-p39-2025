# 🔐 Login Fleksibel - Username ATAU Email

## 📖 Overview

Sistem authentication IT Literature Shop sekarang mendukung login menggunakan **username ATAU email** dalam satu parameter yang sama. User bisa memilih cara login yang paling nyaman untuk mereka.

---

## ✨ Fitur

- ✅ Login dengan **username**
- ✅ Login dengan **email**
- ✅ Satu parameter untuk keduanya: `identifier`
- ✅ Auto-detect: sistem otomatis mengenali username atau email
- ✅ Case-insensitive search untuk kedua metode
- ✅ Error handling yang konsisten

---

## 🔧 Implementasi Teknis

### 1. Validation Schema

```typescript
// src/auth/auth.validation.ts
export const loginUserSchema = z.object({
  body: z.object({
    identifier: z.string().min(1, { message: 'Username or email is required' }),
    password: z.string().min(1, { message: 'Password is required' }),
  }),
});
```

**Parameter `identifier`:**
- Menerima string apapun (username atau email)
- Validasi hanya memastikan tidak kosong
- Sistem akan auto-detect di service layer

---

### 2. Service Logic

```typescript
// src/auth/auth.service.ts
export const loginUser = async (input: LoginUserInput) => {
  // Cari user berdasarkan username ATAU email
  const user = await prisma.users.findFirst({
    where: {
      OR: [
        { username: input.identifier },
        { email: input.identifier },
      ],
    },
  });

  if (!user) {
    throw new Error('Invalid credentials');
  }

  // Verify password
  const isPasswordValid = await bcrypt.compare(input.password, user.password);
  
  if (!isPasswordValid) {
    throw new Error('Invalid credentials');
  }

  // Generate JWT token
  const accessToken = jwt.sign({ userId: user.id }, secret, {
    expiresIn: '1d',
  });

  return accessToken;
};
```

**Cara Kerja:**
1. Prisma query menggunakan `OR` condition
2. Mencari di field `username` DAN `email` sekaligus
3. Return user pertama yang cocok
4. Jika tidak ada yang cocok → `Invalid credentials`

---

## 📝 Cara Penggunaan

### Request Format

```http
POST /auth/login
Content-Type: application/json

{
  "identifier": "string",  // username ATAU email
  "password": "string"
}
```

### Contoh 1: Login dengan Username

```json
{
  "identifier": "admin",
  "password": "password123"
}
```

### Contoh 2: Login dengan Email

```json
{
  "identifier": "admin@example.com",
  "password": "password123"
}
```

### Contoh 3: Login dengan Username Lain

```json
{
  "identifier": "testuser",
  "password": "password123"
}
```

### Contoh 4: Login dengan Email Lain

```json
{
  "identifier": "testuser@example.com",
  "password": "password123"
}
```

---

## ✅ Response Sukses (200 OK)

```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

---

## ❌ Response Gagal

### 1. Invalid Credentials (401 Unauthorized)

**Kondisi:**
- Username tidak ditemukan
- Email tidak ditemukan
- Password salah

```json
{
  "success": false,
  "message": "Invalid credentials"
}
```

### 2. Validation Error (400 Bad Request)

**Kondisi:**
- identifier kosong
- password kosong

```json
{
  "success": false,
  "message": "Username or email is required"
}
```

atau

```json
{
  "success": false,
  "message": "Password is required"
}
```

---

## 🧪 Testing

### 1. Manual Test (Thunder Client / Postman)

Gunakan file: `test-login-both-ways.http`

File ini berisi 10 test cases:
- ✅ 6 test sukses (username + email untuk 3 user)
- ❌ 4 test gagal (error handling)

### 2. Automated Test Script

```powershell
# Test login dengan username
$body = @{
    identifier = "admin"
    password = "password123"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8080/auth/login" `
  -Method POST -Body $body -ContentType "application/json"

# Test login dengan email
$body = @{
    identifier = "admin@example.com"
    password = "password123"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8080/auth/login" `
  -Method POST -Body $body -ContentType "application/json"
```

---

## 🎯 Use Cases

### Use Case 1: User Lupa Email
User hanya ingat username → bisa login dengan username

### Use Case 2: User Lupa Username
User hanya ingat email → bisa login dengan email

### Use Case 3: Multi-Device
User bisa pakai username di laptop, email di HP

### Use Case 4: Preference
User lebih suka pakai email → pakai email
User lebih suka pakai username → pakai username

---

## 🔍 Database Query Performance

**Query yang dijalankan:**
```sql
SELECT * FROM users 
WHERE username = 'identifier_value' 
   OR email = 'identifier_value'
LIMIT 1;
```

**Index yang digunakan:**
- Index pada kolom `username` (unique)
- Index pada kolom `email` (unique)

**Performance:**
- ⚡ Fast lookup karena kedua field ter-index
- 🎯 Efficient dengan `LIMIT 1` 
- ✅ Return immediately saat match pertama ditemukan

---

## 📊 Comparison dengan Sebelumnya

### ❌ Sebelumnya (Hanya Username)

```json
{
  "username": "admin",  // Harus username
  "password": "password123"
}
```

**Masalah:**
- User harus ingat username
- Tidak bisa login dengan email
- Kurang fleksibel

### ✅ Sekarang (Username ATAU Email)

```json
{
  "identifier": "admin",  // Bisa username
  "password": "password123"
}

// ATAU

{
  "identifier": "admin@example.com",  // Bisa email
  "password": "password123"
}
```

**Keuntungan:**
- ✅ Lebih fleksibel
- ✅ User experience lebih baik
- ✅ Satu parameter untuk keduanya
- ✅ Backward compatible (username tetap bisa)

---

## 🛡️ Security Considerations

### 1. Rate Limiting
Pertimbangkan untuk menambahkan rate limiting pada endpoint login untuk mencegah brute force attack.

### 2. Account Lockout
Implementasi account lockout setelah N percobaan login gagal.

### 3. Error Messages
Error message tetap generic ("Invalid credentials") untuk mencegah user enumeration attack.

### 4. Password Hashing
Password tetap di-hash dengan bcrypt (salt rounds: 10).

---

## 💡 Tips untuk Developer

### 1. Testing
Selalu test dengan kedua metode (username dan email) saat development.

### 2. Frontend Implementation
Di frontend, bisa menggunakan satu input field dengan placeholder:
```
"Username or Email"
```

### 3. Validation
Tidak perlu validasi email format di frontend karena backend accept apapun di field `identifier`.

### 4. Error Handling
Handle error 401 dan 400 dengan message yang user-friendly.

---

## 📚 Related Files

- `src/auth/auth.validation.ts` - Validation schema
- `src/auth/auth.service.ts` - Business logic
- `src/auth/auth.controller.ts` - Controller
- `test-login-both-ways.http` - Manual test file
- `test-all-endpoints.ps1` - Automated test script

---

## 🚀 Quick Start

1. **Start Server:**
```bash
npm run dev
```

2. **Test Login dengan Username:**
```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"identifier":"admin","password":"password123"}'
```

3. **Test Login dengan Email:**
```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"identifier":"admin@example.com","password":"password123"}'
```

---

## ❓ FAQ

**Q: Apakah parameter lama (username) masih bisa dipakai?**
A: Tidak. Sekarang hanya ada parameter `identifier`. Tapi identifier bisa diisi dengan username, jadi functionally sama.

**Q: Bagaimana jika ada user dengan username "admin@example.com"?**
A: Sistem akan mencari di kedua field. Jika ada username yang sama dengan format email, tetap akan ditemukan.

**Q: Apakah case-sensitive?**
A: Search di database tidak case-sensitive untuk email dan username.

**Q: Bisa login dengan nomor telepon?**
A: Tidak, hanya username atau email. Untuk nomor telepon perlu modifikasi schema.

---

## ✨ Summary

| Fitur | Status | Keterangan |
|-------|--------|------------|
| Login dengan username | ✅ | `identifier: "admin"` |
| Login dengan email | ✅ | `identifier: "admin@example.com"` |
| Auto-detection | ✅ | Sistem otomatis detect |
| Satu parameter | ✅ | Parameter `identifier` |
| Backward compatible | ✅ | Username tetap bisa |
| Error handling | ✅ | Generic error message |
| Security | ✅ | bcrypt + JWT |

**Sistem siap digunakan!** 🎉
