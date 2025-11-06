# Login Testing Script - Username vs Email
# Tests login with both username and email for all users

$BASE_URL = "http://localhost:8080"

# Color output functions
function Write-Success { 
    param($message) 
    Write-Host "[SUCCESS] $message" -ForegroundColor Green 
}

function Write-ErrorMsg { 
    param($message) 
    Write-Host "[ERROR] $message" -ForegroundColor Red 
}

function Write-Info { 
    param($message) 
    Write-Host "[INFO] $message" -ForegroundColor Cyan 
}

function Write-Header { 
    param($message) 
    Write-Host "`n========================================" -ForegroundColor Yellow
    Write-Host $message -ForegroundColor Yellow
    Write-Host "========================================`n" -ForegroundColor Yellow 
}

Write-Host "`n🔐 Testing Login with Username OR Email...`n" -ForegroundColor Magenta

# ============================================
# TEST LOGIN DENGAN USERNAME
# ============================================

Write-Header "LOGIN TESTS - USING USERNAME"

# Test 1: Login admin dengan username
Write-Info "Test 1: Login with username 'admin'"
try {
    $body = @{
        identifier = "admin"
        password = "password123"
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "$BASE_URL/auth/login" -Method POST -Body $body -ContentType "application/json"
    if ($response.success) {
        Write-Success "Login dengan USERNAME berhasil!"
        Write-Host "   Token: $($response.data.token.Substring(0, 50))..." -ForegroundColor Gray
    }
} catch {
    Write-ErrorMsg "Login gagal: $_"
}
Start-Sleep -Seconds 1

# Test 2: Login testuser dengan username
Write-Info "Test 2: Login with username 'testuser'"
try {
    $body = @{
        identifier = "testuser"
        password = "password123"
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "$BASE_URL/auth/login" -Method POST -Body $body -ContentType "application/json"
    if ($response.success) {
        Write-Success "Login dengan USERNAME berhasil!"
        Write-Host "   Token: $($response.data.token.Substring(0, 50))..." -ForegroundColor Gray
    }
} catch {
    Write-ErrorMsg "Login gagal: $_"
}
Start-Sleep -Seconds 1

# Test 3: Login johndoe dengan username
Write-Info "Test 3: Login with username 'johndoe'"
try {
    $body = @{
        identifier = "johndoe"
        password = "password123"
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "$BASE_URL/auth/login" -Method POST -Body $body -ContentType "application/json"
    if ($response.success) {
        Write-Success "Login dengan USERNAME berhasil!"
        Write-Host "   Token: $($response.data.token.Substring(0, 50))..." -ForegroundColor Gray
    }
} catch {
    Write-ErrorMsg "Login gagal: $_"
}
Start-Sleep -Seconds 1

# ============================================
# TEST LOGIN DENGAN EMAIL
# ============================================

Write-Header "LOGIN TESTS - USING EMAIL"

# Test 4: Login admin dengan email
Write-Info "Test 4: Login with email 'admin@example.com'"
try {
    $body = @{
        identifier = "admin@example.com"
        password = "password123"
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "$BASE_URL/auth/login" -Method POST -Body $body -ContentType "application/json"
    if ($response.success) {
        Write-Success "Login dengan EMAIL berhasil!"
        Write-Host "   Token: $($response.data.token.Substring(0, 50))..." -ForegroundColor Gray
    }
} catch {
    Write-ErrorMsg "Login gagal: $_"
}
Start-Sleep -Seconds 1

# Test 5: Login testuser dengan email
Write-Info "Test 5: Login with email 'testuser@example.com'"
try {
    $body = @{
        identifier = "testuser@example.com"
        password = "password123"
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "$BASE_URL/auth/login" -Method POST -Body $body -ContentType "application/json"
    if ($response.success) {
        Write-Success "Login dengan EMAIL berhasil!"
        Write-Host "   Token: $($response.data.token.Substring(0, 50))..." -ForegroundColor Gray
    }
} catch {
    Write-ErrorMsg "Login gagal: $_"
}
Start-Sleep -Seconds 1

# Test 6: Login johndoe dengan email
Write-Info "Test 6: Login with email 'john.doe@example.com'"
try {
    $body = @{
        identifier = "john.doe@example.com"
        password = "password123"
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "$BASE_URL/auth/login" -Method POST -Body $body -ContentType "application/json"
    if ($response.success) {
        Write-Success "Login dengan EMAIL berhasil!"
        Write-Host "   Token: $($response.data.token.Substring(0, 50))..." -ForegroundColor Gray
    }
} catch {
    Write-ErrorMsg "Login gagal: $_"
}
Start-Sleep -Seconds 1

# ============================================
# TEST ERROR HANDLING
# ============================================

Write-Header "ERROR HANDLING TESTS"

# Test 7: Username tidak ada
Write-Info "Test 7: Login with non-existent username"
try {
    $body = @{
        identifier = "usertidakada"
        password = "password123"
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "$BASE_URL/auth/login" -Method POST -Body $body -ContentType "application/json"
    Write-ErrorMsg "Error handling gagal - seharusnya return 401"
} catch {
    if ($_.Exception.Response.StatusCode.value__ -eq 401) {
        Write-Success "Error handling benar - 401 Invalid credentials"
    } else {
        Write-ErrorMsg "Error handling salah - status code: $($_.Exception.Response.StatusCode.value__)"
    }
}
Start-Sleep -Seconds 1

# Test 8: Email tidak ada
Write-Info "Test 8: Login with non-existent email"
try {
    $body = @{
        identifier = "notfound@example.com"
        password = "password123"
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "$BASE_URL/auth/login" -Method POST -Body $body -ContentType "application/json"
    Write-ErrorMsg "Error handling gagal - seharusnya return 401"
} catch {
    if ($_.Exception.Response.StatusCode.value__ -eq 401) {
        Write-Success "Error handling benar - 401 Invalid credentials"
    } else {
        Write-ErrorMsg "Error handling salah - status code: $($_.Exception.Response.StatusCode.value__)"
    }
}
Start-Sleep -Seconds 1

# Test 9: Password salah
Write-Info "Test 9: Login with wrong password"
try {
    $body = @{
        identifier = "admin"
        password = "wrongpassword"
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "$BASE_URL/auth/login" -Method POST -Body $body -ContentType "application/json"
    Write-ErrorMsg "Error handling gagal - seharusnya return 401"
} catch {
    if ($_.Exception.Response.StatusCode.value__ -eq 401) {
        Write-Success "Error handling benar - 401 Invalid credentials"
    } else {
        Write-ErrorMsg "Error handling salah - status code: $($_.Exception.Response.StatusCode.value__)"
    }
}
Start-Sleep -Seconds 1

# Test 10: Identifier kosong
Write-Info "Test 10: Login with empty identifier"
try {
    $body = @{
        identifier = ""
        password = "password123"
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "$BASE_URL/auth/login" -Method POST -Body $body -ContentType "application/json"
    Write-ErrorMsg "Validation gagal - seharusnya return 400"
} catch {
    if ($_.Exception.Response.StatusCode.value__ -eq 400) {
        Write-Success "Validation benar - 400 Bad Request"
    } else {
        Write-ErrorMsg "Validation salah - status code: $($_.Exception.Response.StatusCode.value__)"
    }
}

# ============================================
# SUMMARY
# ============================================

Write-Header "TEST SUMMARY"

Write-Host "✅ Test dengan USERNAME:" -ForegroundColor Green
Write-Host "   - admin (username)" -ForegroundColor Gray
Write-Host "   - testuser (username)" -ForegroundColor Gray
Write-Host "   - johndoe (username)" -ForegroundColor Gray
Write-Host ""

Write-Host "✅ Test dengan EMAIL:" -ForegroundColor Green
Write-Host "   - admin@example.com" -ForegroundColor Gray
Write-Host "   - testuser@example.com" -ForegroundColor Gray
Write-Host "   - john.doe@example.com" -ForegroundColor Gray
Write-Host ""

Write-Host "✅ Error Handling:" -ForegroundColor Green
Write-Host "   - Username tidak ada → 401" -ForegroundColor Gray
Write-Host "   - Email tidak ada → 401" -ForegroundColor Gray
Write-Host "   - Password salah → 401" -ForegroundColor Gray
Write-Host "   - Identifier kosong → 400" -ForegroundColor Gray
Write-Host ""

Write-Host "💡 Tips:" -ForegroundColor Cyan
Write-Host "   - Gunakan parameter 'identifier' untuk login" -ForegroundColor Gray
Write-Host "   - Identifier bisa diisi username ATAU email" -ForegroundColor Gray
Write-Host "   - Sistem otomatis mendeteksi yang mana" -ForegroundColor Gray
Write-Host ""

Write-Host "🎉 Semua test selesai!`n" -ForegroundColor Magenta
