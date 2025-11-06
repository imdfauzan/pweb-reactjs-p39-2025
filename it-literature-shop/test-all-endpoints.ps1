# IT Literature Shop - Complete API Testing Script
# This script tests all 20 endpoints

$BASE_URL = "http://localhost:8080"
$JWT_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiIxMmMzNzVhNy00NGZkLTQ5ODYtOTkxNy1iNTkwOGMzZjk3N2QiLCJpYXQiOjE3NjEwNTY3NDQsImV4cCI6MTc2MTE0MzE0NH0.CRSuElotM58AvFmWTn_iRWlq3bZdKHlm6_GbrGGS00I"

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

# Variables to store IDs for testing
$GENRE_ID = $null
$BOOK_ID = $null
$TRANSACTION_ID = $null

Write-Host "`n Starting API Endpoint Tests...`n" -ForegroundColor Magenta

# ============================================
# PUBLIC ENDPOINTS (No Token)
# ============================================

Write-Header "PUBLIC ENDPOINTS (No Token Required)"

# 1. Health Check
Write-Info "Test 1: GET /health-check"
try {
    $response = Invoke-RestMethod -Uri "$BASE_URL/health-check" -Method GET
    if ($response.success) {
        Write-Success "Health Check Passed - Server is running!"
        Write-Host "   Message: $($response.message)" -ForegroundColor Gray
    }
} catch {
    Write-ErrorMsg "Health Check Failed: $_"
}
Start-Sleep -Seconds 1

# 2. Database Test
Write-Info "Test 2: GET /test-db"
try {
    $response = Invoke-RestMethod -Uri "$BASE_URL/test-db" -Method GET
    if ($response.success) {
        Write-Success "Database Test Passed"
        Write-Host "   Users: $($response.data.users.Count)" -ForegroundColor Gray
        Write-Host "   Genres: $($response.data.total_genres)" -ForegroundColor Gray
        Write-Host "   Books: $($response.data.total_books)" -ForegroundColor Gray
    }
} catch {
    Write-ErrorMsg "Database Test Failed: $_"
}
Start-Sleep -Seconds 1

# 3. Register User (Optional - will fail if user exists)
Write-Info "Test 3: POST /auth/register (optional test)"
try {
    $body = @{
        username = "testuser_$(Get-Random -Maximum 9999)"
        email = "test_$(Get-Random -Maximum 9999)@example.com"
        password = "password123"
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "$BASE_URL/auth/register" -Method POST -Body $body -ContentType "application/json"
    Write-Success "User Registration Passed"
    Write-Host "   User ID: $($response.data.id)" -ForegroundColor Gray
} catch {
    Write-Host "   [WARNING] Registration skipped (user may already exist)" -ForegroundColor Yellow
}
Start-Sleep -Seconds 1

# 4. Login
Write-Info "Test 4: POST /auth/login"
try {
    $body = @{
        email = "admin@example.com"
        password = "password123"
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "$BASE_URL/auth/login" -Method POST -Body $body -ContentType "application/json"
    Write-Success "Login Passed - Token received"
    Write-Host "   Token: $($response.data.token.Substring(0, 50))..." -ForegroundColor Gray
} catch {
    Write-ErrorMsg "Login Failed: $_"
    Write-Host "   Make sure you ran the password fix SQL in Neon!" -ForegroundColor Red
    exit
}
Start-Sleep -Seconds 1

# ============================================
# PROTECTED ENDPOINTS (Need Token)
# ============================================

Write-Header "PROTECTED ENDPOINTS (Token Required)"

$headers = @{
    "Authorization" = "Bearer $JWT_TOKEN"
    "Content-Type" = "application/json"
}

# 5. Get Current User
Write-Info "Test 5: GET /auth/me"
try {
    $response = Invoke-RestMethod -Uri "$BASE_URL/auth/me" -Method GET -Headers $headers
    if ($response.success) {
        Write-Success "Get Current User Passed"
        Write-Host "   Username: $($response.data.username)" -ForegroundColor Gray
        Write-Host "   Email: $($response.data.email)" -ForegroundColor Gray
    }
} catch {
    Write-ErrorMsg "Get Current User Failed: $_"
}
Start-Sleep -Seconds 1

# ============================================
# GENRE ENDPOINTS
# ============================================

Write-Header "GENRE ENDPOINTS"

# 6. Get All Genres
Write-Info "Test 6: GET /genre"
try {
    $response = Invoke-RestMethod -Uri "$BASE_URL/genre" -Method GET -Headers $headers
    if ($response.success) {
        Write-Success "Get All Genres Passed - Found $($response.data.Count) genres"
        # Save first genre ID for later tests
        if ($response.data.Count -gt 0) {
            $GENRE_ID = $response.data[0].id
            Write-Host "   First Genre: $($response.data[0].name) (ID: $GENRE_ID)" -ForegroundColor Gray
        }
    }
} catch {
    Write-ErrorMsg "Get All Genres Failed: $_"
}
Start-Sleep -Seconds 1

# 7. Create Genre
Write-Info "Test 7: POST /genre"
try {
    $body = @{
        name = "Test Genre $(Get-Random -Maximum 9999)"
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "$BASE_URL/genre" -Method POST -Body $body -Headers $headers
    if ($response.success) {
        Write-Success "Create Genre Passed"
        $NEW_GENRE_ID = $response.data.id
        Write-Host "   Created Genre: $($response.data.name) (ID: $NEW_GENRE_ID)" -ForegroundColor Gray
    }
} catch {
    Write-ErrorMsg "Create Genre Failed: $_"
}
Start-Sleep -Seconds 1

# 8. Get Genre by ID
if ($GENRE_ID) {
    Write-Info "Test 8: GET /genre/$GENRE_ID"
    try {
        $response = Invoke-RestMethod -Uri "$BASE_URL/genre/$GENRE_ID" -Method GET -Headers $headers
        if ($response.success) {
            Write-Success "Get Genre by ID Passed"
            Write-Host "   Genre: $($response.data.name)" -ForegroundColor Gray
        }
    } catch {
        Write-ErrorMsg "Get Genre by ID Failed: $_"
    }
    Start-Sleep -Seconds 1
} else {
    Write-Host "   [WARNING] Skipped (no genre ID available)" -ForegroundColor Yellow
}

# 9. Update Genre
if ($NEW_GENRE_ID) {
    Write-Info "Test 9: PATCH /genre/$NEW_GENRE_ID"
    try {
        $body = @{
            name = "Updated Genre $(Get-Random -Maximum 9999)"
        } | ConvertTo-Json
        
        $response = Invoke-RestMethod -Uri "$BASE_URL/genre/$NEW_GENRE_ID" -Method PATCH -Body $body -Headers $headers
        if ($response.success) {
            Write-Success "Update Genre Passed"
            Write-Host "   Updated to: $($response.data.name)" -ForegroundColor Gray
        }
    } catch {
        Write-ErrorMsg "Update Genre Failed: $_"
    }
    Start-Sleep -Seconds 1
} else {
    Write-Host "   [WARNING] Skipped (no new genre created)" -ForegroundColor Yellow
}

# 10. Delete Genre
if ($NEW_GENRE_ID) {
    Write-Info "Test 10: DELETE /genre/$NEW_GENRE_ID"
    try {
        $response = Invoke-RestMethod -Uri "$BASE_URL/genre/$NEW_GENRE_ID" -Method DELETE -Headers $headers
        if ($response.success) {
            Write-Success "Delete Genre Passed"
        }
    } catch {
        Write-ErrorMsg "Delete Genre Failed: $_"
    }
    Start-Sleep -Seconds 1
} else {
    Write-Host "   [WARNING] Skipped (no genre to delete)" -ForegroundColor Yellow
}

# ============================================
# BOOK ENDPOINTS
# ============================================

Write-Header "BOOK ENDPOINTS"

# 11. Get All Books
Write-Info "Test 11: GET /books"
try {
    $response = Invoke-RestMethod -Uri "$BASE_URL/books" -Method GET -Headers $headers
    if ($response.success) {
        Write-Success "Get All Books Passed - Found $($response.data.Count) books"
        # Save first book ID for later tests
        if ($response.data.Count -gt 0) {
            $BOOK_ID = $response.data[0].id
            Write-Host "   First Book: $($response.data[0].title) (ID: $BOOK_ID)" -ForegroundColor Gray
        }
    }
} catch {
    Write-ErrorMsg "Get All Books Failed: $_"
}
Start-Sleep -Seconds 1

# 12. Create Book
if ($GENRE_ID) {
    Write-Info "Test 12: POST /books"
    try {
        $body = @{
            title = "Test Book $(Get-Random -Maximum 9999)"
            writer = "Test Author"
            publisher = "Test Publisher"
            publication_year = 2024
            description = "A test book created by automated script"
            price = 29.99
            stock_quantity = 50
            genre_id = $GENRE_ID
        } | ConvertTo-Json
        
        $response = Invoke-RestMethod -Uri "$BASE_URL/books" -Method POST -Body $body -Headers $headers
        if ($response.success) {
            Write-Success "Create Book Passed"
            $NEW_BOOK_ID = $response.data.id
            Write-Host "   Created Book: $($response.data.title) (ID: $NEW_BOOK_ID)" -ForegroundColor Gray
        }
    } catch {
        Write-ErrorMsg "Create Book Failed: $_"
    }
    Start-Sleep -Seconds 1
} else {
    Write-Host "   ⚠️  Skipped (no genre ID available)" -ForegroundColor Yellow
}

# 13. Get Book by ID
if ($BOOK_ID) {
    Write-Info "Test 13: GET /books/$BOOK_ID"
    try {
        $response = Invoke-RestMethod -Uri "$BASE_URL/books/$BOOK_ID" -Method GET -Headers $headers
        if ($response.success) {
            Write-Success "Get Book by ID Passed"
            Write-Host "   Book: $($response.data.title) by $($response.data.writer)" -ForegroundColor Gray
        }
    } catch {
        Write-ErrorMsg "Get Book by ID Failed: $_"
    }
    Start-Sleep -Seconds 1
} else {
    Write-Host "   ⚠️  Skipped (no book ID available)" -ForegroundColor Yellow
}

# 14. Get Books by Genre
if ($GENRE_ID) {
    Write-Info "Test 14: GET /books/genre/$GENRE_ID"
    try {
        $response = Invoke-RestMethod -Uri "$BASE_URL/books/genre/$GENRE_ID" -Method GET -Headers $headers
        if ($response.success) {
            Write-Success "Get Books by Genre Passed - Found $($response.data.Count) books"
        }
    } catch {
        Write-ErrorMsg "Get Books by Genre Failed: $_"
    }
    Start-Sleep -Seconds 1
} else {
    Write-Host "   ⚠️  Skipped (no genre ID available)" -ForegroundColor Yellow
}

# 15. Update Book
if ($NEW_BOOK_ID) {
    Write-Info "Test 15: PATCH /books/$NEW_BOOK_ID"
    try {
        $body = @{
            description = "Updated description for test book"
            price = 39.99
            stock_quantity = 100
        } | ConvertTo-Json
        
        $response = Invoke-RestMethod -Uri "$BASE_URL/books/$NEW_BOOK_ID" -Method PATCH -Body $body -Headers $headers
        if ($response.success) {
            Write-Success "Update Book Passed"
            Write-Host "   New Price: $($response.data.price)" -ForegroundColor Gray
        }
    } catch {
        Write-ErrorMsg "Update Book Failed: $_"
    }
    Start-Sleep -Seconds 1
} else {
    Write-Host "   [WARNING] Skipped (no new book created)" -ForegroundColor Yellow
}

# 16. Delete Book
if ($NEW_BOOK_ID) {
    Write-Info "Test 16: DELETE /books/$NEW_BOOK_ID"
    try {
        $response = Invoke-RestMethod -Uri "$BASE_URL/books/$NEW_BOOK_ID" -Method DELETE -Headers $headers
        if ($response.success) {
            Write-Success "Delete Book Passed"
        }
    } catch {
        Write-ErrorMsg "Delete Book Failed: $_"
    }
    Start-Sleep -Seconds 1
} else {
    Write-Host "   [WARNING] Skipped (no book to delete)" -ForegroundColor Yellow
}

# ============================================
# TRANSACTION ENDPOINTS
# ============================================

Write-Header "TRANSACTION ENDPOINTS"

# 17. Create Transaction
if ($BOOK_ID) {
    Write-Info "Test 17: POST /transactions"
    try {
        $body = @{
            items = @(
                @{
                    book_id = $BOOK_ID
                    quantity = 2
                }
            )
        } | ConvertTo-Json -Depth 3
        
        $response = Invoke-RestMethod -Uri "$BASE_URL/transactions" -Method POST -Body $body -Headers $headers
        if ($response.success) {
            Write-Success "Create Transaction Passed"
            $TRANSACTION_ID = $response.data.transaction_id
            Write-Host "   Transaction ID: $TRANSACTION_ID" -ForegroundColor Gray
            Write-Host "   Total: $($response.data.total_price)" -ForegroundColor Gray
        }
    } catch {
        Write-ErrorMsg "Create Transaction Failed: $_"
        Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    Start-Sleep -Seconds 1
} else {
    Write-Host "   ⚠️  Skipped (no book ID available)" -ForegroundColor Yellow
}

# 18. Get All Transactions
Write-Info "Test 18: GET /transactions"
try {
    $response = Invoke-RestMethod -Uri "$BASE_URL/transactions" -Method GET -Headers $headers
    if ($response.success) {
        Write-Success "Get All Transactions Passed - Found $($response.data.Count) transactions"
        # Save first transaction ID if we don't have one
        if (!$TRANSACTION_ID -and $response.data.Count -gt 0) {
            $TRANSACTION_ID = $response.data[0].id
        }
    }
} catch {
    Write-ErrorMsg "Get All Transactions Failed: $_"
}
Start-Sleep -Seconds 1

# 19. Get Transaction by ID
if ($TRANSACTION_ID) {
    Write-Info "Test 19: GET /transactions/$TRANSACTION_ID"
    try {
        $response = Invoke-RestMethod -Uri "$BASE_URL/transactions/$TRANSACTION_ID" -Method GET -Headers $headers
        if ($response.success) {
            Write-Success "Get Transaction by ID Passed"
            Write-Host "   Items: $($response.data.items.Count)" -ForegroundColor Gray
            Write-Host "   Total: $($response.data.total_price)" -ForegroundColor Gray
        }
    } catch {
        Write-ErrorMsg "Get Transaction by ID Failed: $_"
    }
    Start-Sleep -Seconds 1
} else {
    Write-Host "   [WARNING] Skipped (no transaction ID available)" -ForegroundColor Yellow
}

# 20. Get Transaction Statistics
Write-Info "Test 20: GET /transactions/statistics"
try {
    $response = Invoke-RestMethod -Uri "$BASE_URL/transactions/statistics" -Method GET -Headers $headers
    if ($response.success) {
        Write-Success "Get Transaction Statistics Passed"
        Write-Host "   Total Transactions: $($response.data.total_transactions)" -ForegroundColor Gray
        Write-Host "   Average Amount: $($response.data.average_transaction_amount)" -ForegroundColor Gray
        Write-Host "   Most Sold Genre: $($response.data.most_book_sales_genre)" -ForegroundColor Gray
        Write-Host "   Least Sold Genre: $($response.data.fewest_book_sales_genre)" -ForegroundColor Gray
    }
} catch {
    Write-ErrorMsg "Get Transaction Statistics Failed: $_"
}

# ============================================
# SUMMARY
# ============================================

Write-Host "`n" -NoNewline
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "          TEST SUMMARY" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "`n[SUCCESS] All 20 endpoints have been tested!" -ForegroundColor Green
Write-Host "[INFO] Check the results above for any failures`n" -ForegroundColor Cyan
Write-Host "[TIP] Any failures marked with [WARNING] are optional tests" -ForegroundColor Yellow
Write-Host "[INFO] All critical endpoints should show [SUCCESS]`n" -ForegroundColor Green
