# 🔐 Quick Reference - Login Fleksibel

## 📌 Parameter Login

```json
{
  "identifier": "username_atau_email",
  "password": "password_anda"
}
```

---

## ✅ Contoh Login yang BENAR

### 1️⃣ Login dengan Username
```json
POST /auth/login

{
  "identifier": "admin",
  "password": "password123"
}
```

### 2️⃣ Login dengan Email
```json
POST /auth/login

{
  "identifier": "admin@example.com",
  "password": "password123"
}
```

---

## ❌ Contoh Login yang SALAH

### ❌ Menggunakan field "username" (deprecated)
```json
{
  "username": "admin",  ❌ Field salah!
  "password": "password123"
}
```
**Error:** Field `username` tidak dikenali

### ❌ Menggunakan field "email" (deprecated)
```json
{
  "email": "admin@example.com",  ❌ Field salah!
  "password": "password123"
}
```
**Error:** Field `email` tidak dikenali

### ✅ Yang Benar: Gunakan "identifier"
```json
{
  "identifier": "admin",  ✅ Benar! (bisa username)
  "password": "password123"
}

{
  "identifier": "admin@example.com",  ✅ Benar! (bisa email)
  "password": "password123"
}
```

---

## 📝 Response

### ✅ Sukses (200 OK)
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

### ❌ Gagal (401 Unauthorized)
```json
{
  "success": false,
  "message": "Invalid credentials"
}
```

### ❌ Validation Error (400 Bad Request)
```json
{
  "success": false,
  "message": "Username or email is required"
}
```

---

## 🧪 Testing

### PowerShell Script
```powershell
# Test dengan username
.\test-login-flexibility.ps1

# Atau manual
$body = @{
    identifier = "admin"
    password = "password123"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8080/auth/login" `
  -Method POST -Body $body -ContentType "application/json"
```

### HTTP File (Thunder Client / REST Client)
```http
POST http://localhost:8080/auth/login
Content-Type: application/json

{
  "identifier": "admin",
  "password": "password123"
}
```

### cURL
```bash
# Login dengan username
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"identifier":"admin","password":"password123"}'

# Login dengan email
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"identifier":"admin@example.com","password":"password123"}'
```

---

## 👥 Test Users

| Username | Email | Password |
|----------|-------|----------|
| admin | admin@example.com | password123 |
| testuser | testuser@example.com | password123 |
| johndoe | john.doe@example.com | password123 |

**Test dengan keduanya!**
- `identifier: "admin"` ✅
- `identifier: "admin@example.com"` ✅

---

## 💡 Best Practices

1. **Frontend Input**
   - Gunakan satu input field dengan placeholder: "Username or Email"
   - Tidak perlu validasi format email di frontend
   - Backend akan handle deteksi otomatis

2. **Error Handling**
   ```javascript
   try {
     const response = await login(identifier, password);
     // Success - save token
   } catch (error) {
     if (error.status === 401) {
       // Invalid credentials
       showError("Username/email atau password salah");
     } else if (error.status === 400) {
       // Validation error
       showError("Mohon isi username/email dan password");
     }
   }
   ```

3. **Testing**
   - Selalu test dengan username DAN email
   - Test error cases (wrong password, non-existent user)
   - Test validation (empty fields)

---

## 🎯 Cheat Sheet

| Scenario | Request | Expected Response |
|----------|---------|-------------------|
| Login valid (username) | `{"identifier":"admin","password":"password123"}` | 200 OK + token |
| Login valid (email) | `{"identifier":"admin@example.com","password":"password123"}` | 200 OK + token |
| Wrong password | `{"identifier":"admin","password":"wrong"}` | 401 Unauthorized |
| User not found | `{"identifier":"notexist","password":"123"}` | 401 Unauthorized |
| Empty identifier | `{"identifier":"","password":"123"}` | 400 Bad Request |
| Empty password | `{"identifier":"admin","password":""}` | 400 Bad Request |

---

## 📂 Related Files

- `test-login-flexibility.ps1` - Automated test script
- `test-login-both-ways.http` - Manual HTTP tests
- `LOGIN-DOCUMENTATION.md` - Full documentation
- `src/auth/auth.service.ts` - Implementation

---

## 🚀 Quick Start

1. Start server: `npm run dev`
2. Run test: `.\test-login-flexibility.ps1`
3. Check results

**Semua ready to use!** 🎉
