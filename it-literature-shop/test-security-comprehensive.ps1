# IT Literature Shop - Comprehensive Security & Method Testing
# Tests ALL HTTP methods to ensure backend only accepts correct ones

$BASE_URL = "http://localhost:8080"
$JWT_TOKEN = ""

# Color output functions
function Write-Success { 
    param($message) 
    Write-Host "[PASS] $message" -ForegroundColor Green 
}

function Write-Fail { 
    param($message) 
    Write-Host "[FAIL] $message" -ForegroundColor Red 
}

function Write-Security { 
    param($message) 
    Write-Host "[SECURITY] $message" -ForegroundColor Yellow 
}

function Write-Info { 
    param($message) 
    Write-Host "[INFO] $message" -ForegroundColor Cyan 
}

function Write-Header { 
    param($message) 
    Write-Host "`n========================================" -ForegroundColor Magenta
    Write-Host $message -ForegroundColor Magenta
    Write-Host "========================================`n" -ForegroundColor Magenta 
}

# Test counter
$script:totalTests = 0
$script:passedTests = 0
$script:failedTests = 0
$script:securityPassed = 0
$script:securityFailed = 0

function Test-Endpoint {
    param(
        [string]$Method,
        [string]$Url,
        [string]$Description,
        [bool]$ShouldSucceed,
        [object]$Body = $null,
        [hashtable]$Headers = $null,
        [int[]]$ExpectedStatusCodes = @()
    )
    
    $script:totalTests++
    
    try {
        $params = @{
            Uri             = $Url
            Method          = $Method
            ErrorAction     = 'Stop'
            UseBasicParsing = $true
        }
        
        if ($Body) {
            $params.Body = ($Body | ConvertTo-Json)
            $params.ContentType = "application/json"
        }
        
        if ($Headers) {
            $params.Headers = $Headers
        }
        
        # Use Invoke-WebRequest to get actual status code
        $response = Invoke-WebRequest @params
        $statusCode = $response.StatusCode
        
        if ($ShouldSucceed) {
            if ($ExpectedStatusCodes.Count -eq 0 -or $ExpectedStatusCodes -contains $statusCode) {
                Write-Success "$Description - Status: $statusCode"
                $script:passedTests++
            }
            else {
                Write-Fail "$Description - Expected status codes: $($ExpectedStatusCodes -join ','), Got: $statusCode"
                $script:failedTests++
            }
        }
        else {
            Write-Fail "$Description - SECURITY ISSUE! Method should be rejected but got: $statusCode"
            $script:securityFailed++
        }
        
    }
    catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        
        if ($ShouldSucceed) {
            if ($ExpectedStatusCodes.Count -gt 0 -and $ExpectedStatusCodes -contains $statusCode) {
                Write-Success "$Description - Status: $statusCode (Expected)"
                $script:passedTests++
            }
            else {
                Write-Fail "$Description - Expected success but got: $statusCode - $($_.Exception.Message)"
                $script:failedTests++
            }
        }
        else {
            if ($statusCode -in @(404, 405, 401, 403)) {
                Write-Security "$Description - Correctly rejected with: $statusCode"
                $script:securityPassed++
            }
            else {
                Write-Fail "$Description - Should reject but got: $statusCode"
                $script:securityFailed++
            }
        }
    }
    
    Start-Sleep -Milliseconds 200
}

Write-Host "`n[SECURITY TEST] Starting Comprehensive Security & Method Testing...`n" -ForegroundColor Magenta

# ============================================
# PHASE 1: AUTHENTICATION (Public Endpoints)
# ============================================

Write-Header "PHASE 1: AUTHENTICATION ENDPOINTS"

Write-Info "Testing POST /auth/register (CORRECT METHOD)"
Test-Endpoint -Method "POST" -Url "$BASE_URL/auth/register" `
    -Description "Register with valid data" `
    -ShouldSucceed $true `
    -Body @{
    username = "testuser_$(Get-Random -Maximum 9999)"
    email    = "test_$(Get-Random -Maximum 9999)@example.com"
    password = "password123"
} `
    -ExpectedStatusCodes @(201, 409)

Write-Info "Testing POST /auth/register - Missing username (VALIDATION TEST)"
Test-Endpoint -Method "POST" -Url "$BASE_URL/auth/register" `
    -Description "Register without username should fail" `
    -ShouldSucceed $true `
    -Body @{
    email    = "test@example.com"
    password = "password123"
} `
    -ExpectedStatusCodes @(400)

Write-Info "Testing POST /auth/register - Missing email (VALIDATION TEST)"
Test-Endpoint -Method "POST" -Url "$BASE_URL/auth/register" `
    -Description "Register without email should fail" `
    -ShouldSucceed $true `
    -Body @{
    username = "testuser"
    password = "password123"
} `
    -ExpectedStatusCodes @(400)

Write-Info "Testing POST /auth/register - Short password (VALIDATION TEST)"
Test-Endpoint -Method "POST" -Url "$BASE_URL/auth/register" `
    -Description "Register with password < 6 chars should fail" `
    -ShouldSucceed $true `
    -Body @{
    username = "testuser"
    email    = "test@example.com"
    password = "12345"
} `
    -ExpectedStatusCodes @(400)

Write-Security "`nTesting WRONG methods on /auth/register (SECURITY TEST)"
Test-Endpoint -Method "GET" -Url "$BASE_URL/auth/register" `
    -Description "GET /auth/register should be rejected" `
    -ShouldSucceed $false

Test-Endpoint -Method "PUT" -Url "$BASE_URL/auth/register" `
    -Description "PUT /auth/register should be rejected" `
    -ShouldSucceed $false

Test-Endpoint -Method "PATCH" -Url "$BASE_URL/auth/register" `
    -Description "PATCH /auth/register should be rejected" `
    -ShouldSucceed $false

Test-Endpoint -Method "DELETE" -Url "$BASE_URL/auth/register" `
    -Description "DELETE /auth/register should be rejected" `
    -ShouldSucceed $false

Write-Info "`nTesting POST /auth/login (CORRECT METHOD)"
Test-Endpoint -Method "POST" -Url "$BASE_URL/auth/login" `
    -Description "Login with valid credentials" `
    -ShouldSucceed $true `
    -Body @{
    email    = "admin@example.com"
    password = "password123"
} `
    -ExpectedStatusCodes @(200)

# Get token for protected routes
try {
    $loginResponse = Invoke-RestMethod -Uri "$BASE_URL/auth/login" -Method POST `
        -Body (@{email = "admin@example.com"; password = "password123" } | ConvertTo-Json) `
        -ContentType "application/json"
    $JWT_TOKEN = $loginResponse.data.token
    Write-Success "JWT Token obtained for protected route testing"
}
catch {
    Write-Fail "Failed to get JWT token - some tests will fail"
}

Write-Info "Testing POST /auth/login - Invalid credentials (VALIDATION TEST)"
Test-Endpoint -Method "POST" -Url "$BASE_URL/auth/login" `
    -Description "Login with wrong password should fail" `
    -ShouldSucceed $true `
    -Body @{
    email    = "admin@example.com"
    password = "wrongpassword"
} `
    -ExpectedStatusCodes @(401)

Write-Info "Testing POST /auth/login - Missing email (VALIDATION TEST)"
Test-Endpoint -Method "POST" -Url "$BASE_URL/auth/login" `
    -Description "Login without email should fail" `
    -ShouldSucceed $true `
    -Body @{
    password = "password123"
} `
    -ExpectedStatusCodes @(400)

Write-Security "`nTesting WRONG methods on /auth/login (SECURITY TEST)"
Test-Endpoint -Method "GET" -Url "$BASE_URL/auth/login" `
    -Description "GET /auth/login should be rejected" `
    -ShouldSucceed $false

Test-Endpoint -Method "PUT" -Url "$BASE_URL/auth/login" `
    -Description "PUT /auth/login should be rejected" `
    -ShouldSucceed $false

Test-Endpoint -Method "DELETE" -Url "$BASE_URL/auth/login" `
    -Description "DELETE /auth/login should be rejected" `
    -ShouldSucceed $false

Write-Info "`nTesting GET /auth/me (CORRECT METHOD)"
$headers = @{
    "Authorization" = "Bearer $JWT_TOKEN"
}

Test-Endpoint -Method "GET" -Url "$BASE_URL/auth/me" `
    -Description "Get user profile with valid token" `
    -ShouldSucceed $true `
    -Headers $headers `
    -ExpectedStatusCodes @(200)

Write-Info "Testing GET /auth/me - No token (AUTH TEST)"
Test-Endpoint -Method "GET" -Url "$BASE_URL/auth/me" `
    -Description "Get profile without token should fail" `
    -ShouldSucceed $true `
    -ExpectedStatusCodes @(401)

Write-Info "Testing GET /auth/me - Invalid token (AUTH TEST)"
Test-Endpoint -Method "GET" -Url "$BASE_URL/auth/me" `
    -Description "Get profile with invalid token should fail" `
    -ShouldSucceed $true `
    -Headers @{"Authorization" = "Bearer invalidtoken123" } `
    -ExpectedStatusCodes @(401)

Write-Security "`nTesting WRONG methods on /auth/me (SECURITY TEST)"
Test-Endpoint -Method "POST" -Url "$BASE_URL/auth/me" `
    -Description "POST /auth/me should be rejected" `
    -ShouldSucceed $false `
    -Headers $headers

Test-Endpoint -Method "PUT" -Url "$BASE_URL/auth/me" `
    -Description "PUT /auth/me should be rejected" `
    -ShouldSucceed $false `
    -Headers $headers

Test-Endpoint -Method "DELETE" -Url "$BASE_URL/auth/me" `
    -Description "DELETE /auth/me should be rejected" `
    -ShouldSucceed $false `
    -Headers $headers

# ============================================
# PHASE 2: BOOKS ENDPOINTS
# ============================================

Write-Header "PHASE 2: BOOKS ENDPOINTS"

# Get a genre ID first
try {
    $genresResponse = Invoke-RestMethod -Uri "$BASE_URL/genre" -Method GET -Headers $headers
    $GENRE_ID = $genresResponse.data[0].id
    Write-Info "Using Genre ID: $GENRE_ID"
}
catch {
    Write-Fail "Failed to get genre ID"
    $GENRE_ID = "00000000-0000-0000-0000-000000000000"
}

Write-Info "Testing POST /books (CORRECT METHOD)"
Test-Endpoint -Method "POST" -Url "$BASE_URL/books" `
    -Description "Create book with valid data" `
    -ShouldSucceed $true `
    -Headers $headers `
    -Body @{
    title            = "Test Book $(Get-Random -Maximum 9999)"
    writer           = "Test Author"
    publisher        = "Test Publisher"
    publication_year = 2024
    description      = "Test description"
    price            = 29.99
    stock_quantity   = 100
    genre_id         = $GENRE_ID
} `
    -ExpectedStatusCodes @(201)

Write-Info "Testing POST /books - Duplicate title (VALIDATION TEST)"
Test-Endpoint -Method "POST" -Url "$BASE_URL/books" `
    -Description "Create book with duplicate title should fail" `
    -ShouldSucceed $true `
    -Headers $headers `
    -Body @{
    title            = "Clean Code"
    writer           = "Test Author"
    publisher        = "Test Publisher"
    publication_year = 2024
    description      = "Test"
    price            = 29.99
    stock_quantity   = 100
    genre_id         = $GENRE_ID
} `
    -ExpectedStatusCodes @(409)

Write-Info "Testing POST /books - Missing required field (VALIDATION TEST)"
Test-Endpoint -Method "POST" -Url "$BASE_URL/books" `
    -Description "Create book without title should fail" `
    -ShouldSucceed $true `
    -Headers $headers `
    -Body @{
    writer           = "Test Author"
    publisher        = "Test Publisher"
    publication_year = 2024
    price            = 29.99
    stock_quantity   = 100
    genre_id         = $GENRE_ID
} `
    -ExpectedStatusCodes @(400)

Write-Info "Testing POST /books - Invalid genre_id (VALIDATION TEST)"
Test-Endpoint -Method "POST" -Url "$BASE_URL/books" `
    -Description "Create book with invalid genre_id should fail" `
    -ShouldSucceed $true `
    -Headers $headers `
    -Body @{
    title            = "Test Book"
    writer           = "Test Author"
    publisher        = "Test Publisher"
    publication_year = 2024
    description      = "Test"
    price            = 29.99
    stock_quantity   = 100
    genre_id         = "00000000-0000-0000-0000-000000000000"
} `
    -ExpectedStatusCodes @(400)

Write-Info "Testing POST /books - No token (AUTH TEST)"
Test-Endpoint -Method "POST" -Url "$BASE_URL/books" `
    -Description "Create book without auth should fail" `
    -ShouldSucceed $true `
    -Body @{
    title            = "Test Book"
    writer           = "Test Author"
    publisher        = "Test Publisher"
    publication_year = 2024
    price            = 29.99
    stock_quantity   = 100
    genre_id         = $GENRE_ID
} `
    -ExpectedStatusCodes @(401)

Write-Security "`nTesting WRONG methods on /books (SECURITY TEST)"
Test-Endpoint -Method "PUT" -Url "$BASE_URL/books" `
    -Description "PUT /books should be rejected" `
    -ShouldSucceed $false `
    -Headers $headers

Test-Endpoint -Method "PATCH" -Url "$BASE_URL/books" `
    -Description "PATCH /books should be rejected" `
    -ShouldSucceed $false `
    -Headers $headers

Test-Endpoint -Method "DELETE" -Url "$BASE_URL/books" `
    -Description "DELETE /books should be rejected" `
    -ShouldSucceed $false `
    -Headers $headers

Write-Info "`nTesting GET /books (CORRECT METHOD)"
Test-Endpoint -Method "GET" -Url "$BASE_URL/books" `
    -Description "Get all books" `
    -ShouldSucceed $true `
    -Headers $headers `
    -ExpectedStatusCodes @(200)

Write-Info "Testing GET /books with pagination"
Test-Endpoint -Method "GET" -Url "$BASE_URL/books?page=1&limit=5" `
    -Description "Get books with pagination" `
    -ShouldSucceed $true `
    -Headers $headers `
    -ExpectedStatusCodes @(200)

Write-Info "Testing GET /books with search filter"
Test-Endpoint -Method "GET" -Url "$BASE_URL/books?search=code" `
    -Description "Get books with search filter" `
    -ShouldSucceed $true `
    -Headers $headers `
    -ExpectedStatusCodes @(200)

Write-Info "Testing GET /books - No token (AUTH TEST)"
Test-Endpoint -Method "GET" -Url "$BASE_URL/books" `
    -Description "Get books without auth should fail" `
    -ShouldSucceed $true `
    -ExpectedStatusCodes @(401)

# Get a book ID for testing
try {
    $booksResponse = Invoke-RestMethod -Uri "$BASE_URL/books" -Method GET -Headers $headers
    $BOOK_ID = $booksResponse.data[0].id
    Write-Info "Using Book ID: $BOOK_ID"
}
catch {
    Write-Fail "Failed to get book ID"
    $BOOK_ID = "00000000-0000-0000-0000-000000000000"
}

Write-Info "`nTesting GET /books/:id (CORRECT METHOD)"
Test-Endpoint -Method "GET" -Url "$BASE_URL/books/$BOOK_ID" `
    -Description "Get book by ID" `
    -ShouldSucceed $true `
    -Headers $headers `
    -ExpectedStatusCodes @(200)

Write-Info "Testing GET /books/:id - Invalid ID (VALIDATION TEST)"
Test-Endpoint -Method "GET" -Url "$BASE_URL/books/00000000-0000-0000-0000-000000000000" `
    -Description "Get book with invalid ID should return 404" `
    -ShouldSucceed $true `
    -Headers $headers `
    -ExpectedStatusCodes @(404)

Write-Security "`nTesting WRONG methods on /books/:id (SECURITY TEST)"
Test-Endpoint -Method "POST" -Url "$BASE_URL/books/$BOOK_ID" `
    -Description "POST /books/:id should be rejected" `
    -ShouldSucceed $false `
    -Headers $headers

Test-Endpoint -Method "PUT" -Url "$BASE_URL/books/$BOOK_ID" `
    -Description "PUT /books/:id should be rejected (should use PATCH)" `
    -ShouldSucceed $false `
    -Headers $headers

Write-Info "`nTesting PATCH /books/:id (CORRECT METHOD)"
Test-Endpoint -Method "PATCH" -Url "$BASE_URL/books/$BOOK_ID" `
    -Description "Update book with PATCH" `
    -ShouldSucceed $true `
    -Headers $headers `
    -Body @{
    description    = "Updated description"
    price          = 39.99
    stock_quantity = 50
} `
    -ExpectedStatusCodes @(200)

Write-Info "Testing PATCH /books/:id - No token (AUTH TEST)"
Test-Endpoint -Method "PATCH" -Url "$BASE_URL/books/$BOOK_ID" `
    -Description "Update book without auth should fail" `
    -ShouldSucceed $true `
    -Body @{
    price = 39.99
} `
    -ExpectedStatusCodes @(401)

Write-Info "`nTesting GET /books/genre/:id (CORRECT METHOD)"
Test-Endpoint -Method "GET" -Url "$BASE_URL/books/genre/$GENRE_ID" `
    -Description "Get books by genre" `
    -ShouldSucceed $true `
    -Headers $headers `
    -ExpectedStatusCodes @(200)

Write-Info "Testing GET /books/genre/:id with filters"
Test-Endpoint -Method "GET" -Url "$BASE_URL/books/genre/$GENRE_ID`?page=1&limit=5&search=code" `
    -Description "Get books by genre with filters" `
    -ShouldSucceed $true `
    -Headers $headers `
    -ExpectedStatusCodes @(200)

Write-Security "`nTesting WRONG methods on /books/genre/:id (SECURITY TEST)"
Test-Endpoint -Method "POST" -Url "$BASE_URL/books/genre/$GENRE_ID" `
    -Description "POST /books/genre/:id should be rejected" `
    -ShouldSucceed $false `
    -Headers $headers

Test-Endpoint -Method "PUT" -Url "$BASE_URL/books/genre/$GENRE_ID" `
    -Description "PUT /books/genre/:id should be rejected" `
    -ShouldSucceed $false `
    -Headers $headers

Test-Endpoint -Method "DELETE" -Url "$BASE_URL/books/genre/$GENRE_ID" `
    -Description "DELETE /books/genre/:id should be rejected" `
    -ShouldSucceed $false `
    -Headers $headers

# Create a test book for deletion
try {
    $createResponse = Invoke-RestMethod -Uri "$BASE_URL/books" -Method POST -Headers $headers `
        -Body (@{
            title            = "Delete Test Book $(Get-Random -Maximum 9999)"
            writer           = "Test Author"
            publisher        = "Test Publisher"
            publication_year = 2024
            description      = "To be deleted"
            price            = 19.99
            stock_quantity   = 10
            genre_id         = $GENRE_ID
        } | ConvertTo-Json) -ContentType "application/json"
    $DELETE_BOOK_ID = $createResponse.data.id
    Write-Info "Created test book for deletion: $DELETE_BOOK_ID"
}
catch {
    $DELETE_BOOK_ID = $BOOK_ID
}

Write-Info "`nTesting DELETE /books/:id (CORRECT METHOD)"
Test-Endpoint -Method "DELETE" -Url "$BASE_URL/books/$DELETE_BOOK_ID" `
    -Description "Delete book (soft delete)" `
    -ShouldSucceed $true `
    -Headers $headers `
    -ExpectedStatusCodes @(200)

Write-Info "Testing DELETE /books/:id - Already deleted (VALIDATION TEST)"
Test-Endpoint -Method "DELETE" -Url "$BASE_URL/books/$DELETE_BOOK_ID" `
    -Description "Delete same book again should fail" `
    -ShouldSucceed $true `
    -Headers $headers `
    -ExpectedStatusCodes @(404)

# ============================================
# PHASE 3: GENRE ENDPOINTS
# ============================================

Write-Header "PHASE 3: GENRE ENDPOINTS"

Write-Info "Testing POST /genre (CORRECT METHOD)"
Test-Endpoint -Method "POST" -Url "$BASE_URL/genre" `
    -Description "Create genre" `
    -ShouldSucceed $true `
    -Headers $headers `
    -Body @{
    name = "Test Genre $(Get-Random -Maximum 9999)"
} `
    -ExpectedStatusCodes @(201)

Write-Info "Testing POST /genre - Duplicate name (VALIDATION TEST)"
Test-Endpoint -Method "POST" -Url "$BASE_URL/genre" `
    -Description "Create genre with duplicate name should fail" `
    -ShouldSucceed $true `
    -Headers $headers `
    -Body @{
    name = "Programming"
} `
    -ExpectedStatusCodes @(409)

Write-Info "Testing POST /genre - Missing name (VALIDATION TEST)"
Test-Endpoint -Method "POST" -Url "$BASE_URL/genre" `
    -Description "Create genre without name should fail" `
    -ShouldSucceed $true `
    -Headers $headers `
    -Body @{} `
    -ExpectedStatusCodes @(400)

Write-Info "Testing POST /genre - No token (AUTH TEST)"
Test-Endpoint -Method "POST" -Url "$BASE_URL/genre" `
    -Description "Create genre without auth should fail" `
    -ShouldSucceed $true `
    -Body @{
    name = "Test Genre"
} `
    -ExpectedStatusCodes @(401)

Write-Security "`nTesting WRONG methods on /genre (SECURITY TEST)"
Test-Endpoint -Method "PUT" -Url "$BASE_URL/genre" `
    -Description "PUT /genre should be rejected" `
    -ShouldSucceed $false `
    -Headers $headers

Test-Endpoint -Method "PATCH" -Url "$BASE_URL/genre" `
    -Description "PATCH /genre should be rejected" `
    -ShouldSucceed $false `
    -Headers $headers

Test-Endpoint -Method "DELETE" -Url "$BASE_URL/genre" `
    -Description "DELETE /genre should be rejected" `
    -ShouldSucceed $false `
    -Headers $headers

Write-Info "`nTesting GET /genre (CORRECT METHOD)"
Test-Endpoint -Method "GET" -Url "$BASE_URL/genre" `
    -Description "Get all genres" `
    -ShouldSucceed $true `
    -Headers $headers `
    -ExpectedStatusCodes @(200)

Write-Info "Testing GET /genre - No token (AUTH TEST)"
Test-Endpoint -Method "GET" -Url "$BASE_URL/genre" `
    -Description "Get genres without auth should fail" `
    -ShouldSucceed $true `
    -ExpectedStatusCodes @(401)

Write-Info "`nTesting GET /genre/:id (CORRECT METHOD)"
Test-Endpoint -Method "GET" -Url "$BASE_URL/genre/$GENRE_ID" `
    -Description "Get genre by ID" `
    -ShouldSucceed $true `
    -Headers $headers `
    -ExpectedStatusCodes @(200)

Write-Info "Testing GET /genre/:id - Invalid ID (VALIDATION TEST)"
Test-Endpoint -Method "GET" -Url "$BASE_URL/genre/00000000-0000-0000-0000-000000000000" `
    -Description "Get genre with invalid ID should return 404" `
    -ShouldSucceed $true `
    -Headers $headers `
    -ExpectedStatusCodes @(404)

Write-Security "`nTesting WRONG methods on /genre/:id (SECURITY TEST)"
Test-Endpoint -Method "POST" -Url "$BASE_URL/genre/$GENRE_ID" `
    -Description "POST /genre/:id should be rejected" `
    -ShouldSucceed $false `
    -Headers $headers

Test-Endpoint -Method "PUT" -Url "$BASE_URL/genre/$GENRE_ID" `
    -Description "PUT /genre/:id should be rejected (should use PATCH)" `
    -ShouldSucceed $false `
    -Headers $headers

Write-Info "`nTesting PATCH /genre/:id (CORRECT METHOD)"
Test-Endpoint -Method "PATCH" -Url "$BASE_URL/genre/$GENRE_ID" `
    -Description "Update genre with PATCH" `
    -ShouldSucceed $true `
    -Headers $headers `
    -Body @{
    name = "Updated Genre $(Get-Random -Maximum 9999)"
} `
    -ExpectedStatusCodes @(200)

Write-Info "Testing PATCH /genre/:id - No token (AUTH TEST)"
Test-Endpoint -Method "PATCH" -Url "$BASE_URL/genre/$GENRE_ID" `
    -Description "Update genre without auth should fail" `
    -ShouldSucceed $true `
    -Body @{
    name = "Test"
} `
    -ExpectedStatusCodes @(401)

# Create a test genre for deletion
try {
    $createGenreResponse = Invoke-RestMethod -Uri "$BASE_URL/genre" -Method POST -Headers $headers `
        -Body (@{name = "Delete Test Genre $(Get-Random -Maximum 9999)" } | ConvertTo-Json) `
        -ContentType "application/json"
    $DELETE_GENRE_ID = $createGenreResponse.data.id
    Write-Info "Created test genre for deletion: $DELETE_GENRE_ID"
}
catch {
    $DELETE_GENRE_ID = $GENRE_ID
}

Write-Info "`nTesting DELETE /genre/:id (CORRECT METHOD)"
Test-Endpoint -Method "DELETE" -Url "$BASE_URL/genre/$DELETE_GENRE_ID" `
    -Description "Delete genre (soft delete)" `
    -ShouldSucceed $true `
    -Headers $headers `
    -ExpectedStatusCodes @(200)

Write-Info "Testing DELETE /genre/:id - Already deleted (VALIDATION TEST)"
Test-Endpoint -Method "DELETE" -Url "$BASE_URL/genre/$DELETE_GENRE_ID" `
    -Description "Delete same genre again should fail" `
    -ShouldSucceed $true `
    -Headers $headers `
    -ExpectedStatusCodes @(404)

# ============================================
# PHASE 4: TRANSACTION ENDPOINTS
# ============================================

Write-Header "PHASE 4: TRANSACTION ENDPOINTS"

Write-Info "Testing POST /transactions (CORRECT METHOD)"
Test-Endpoint -Method "POST" -Url "$BASE_URL/transactions" `
    -Description "Create transaction with multiple items" `
    -ShouldSucceed $true `
    -Headers $headers `
    -Body @{
    items = @(
        @{
            book_id  = $BOOK_ID
            quantity = 1
        }
    )
} `
    -ExpectedStatusCodes @(201)

Write-Info "Testing POST /transactions - Empty items (VALIDATION TEST)"
Test-Endpoint -Method "POST" -Url "$BASE_URL/transactions" `
    -Description "Create transaction with empty items should fail" `
    -ShouldSucceed $true `
    -Headers $headers `
    -Body @{
    items = @()
} `
    -ExpectedStatusCodes @(400)

Write-Info "Testing POST /transactions - Invalid book_id (VALIDATION TEST)"
Test-Endpoint -Method "POST" -Url "$BASE_URL/transactions" `
    -Description "Create transaction with invalid book_id should fail" `
    -ShouldSucceed $true `
    -Headers $headers `
    -Body @{
    items = @(
        @{
            book_id  = "00000000-0000-0000-0000-000000000000"
            quantity = 1
        }
    )
} `
    -ExpectedStatusCodes @(400)

Write-Info "Testing POST /transactions - No token (AUTH TEST)"
Test-Endpoint -Method "POST" -Url "$BASE_URL/transactions" `
    -Description "Create transaction without auth should fail" `
    -ShouldSucceed $true `
    -Body @{
    items = @(
        @{
            book_id  = $BOOK_ID
            quantity = 1
        }
    )
} `
    -ExpectedStatusCodes @(401)

Write-Security "`nTesting WRONG methods on /transactions (SECURITY TEST)"
Test-Endpoint -Method "PUT" -Url "$BASE_URL/transactions" `
    -Description "PUT /transactions should be rejected" `
    -ShouldSucceed $false `
    -Headers $headers

Test-Endpoint -Method "PATCH" -Url "$BASE_URL/transactions" `
    -Description "PATCH /transactions should be rejected" `
    -ShouldSucceed $false `
    -Headers $headers

Test-Endpoint -Method "DELETE" -Url "$BASE_URL/transactions" `
    -Description "DELETE /transactions should be rejected" `
    -ShouldSucceed $false `
    -Headers $headers

Write-Info "`nTesting GET /transactions (CORRECT METHOD)"
Test-Endpoint -Method "GET" -Url "$BASE_URL/transactions" `
    -Description "Get all transactions" `
    -ShouldSucceed $true `
    -Headers $headers `
    -ExpectedStatusCodes @(200)

Write-Info "Testing GET /transactions - No token (AUTH TEST)"
Test-Endpoint -Method "GET" -Url "$BASE_URL/transactions" `
    -Description "Get transactions without auth should fail" `
    -ShouldSucceed $true `
    -ExpectedStatusCodes @(401)

# Get a transaction ID
try {
    $transactionsResponse = Invoke-RestMethod -Uri "$BASE_URL/transactions" -Method GET -Headers $headers
    if ($transactionsResponse.data.Count -gt 0) {
        $TRANSACTION_ID = $transactionsResponse.data[0].id
        Write-Info "Using Transaction ID: $TRANSACTION_ID"
    }
    else {
        $TRANSACTION_ID = "00000000-0000-0000-0000-000000000000"
    }
}
catch {
    $TRANSACTION_ID = "00000000-0000-0000-0000-000000000000"
}

Write-Info "`nTesting GET /transactions/:id (CORRECT METHOD)"
Test-Endpoint -Method "GET" -Url "$BASE_URL/transactions/$TRANSACTION_ID" `
    -Description "Get transaction by ID" `
    -ShouldSucceed $true `
    -Headers $headers `
    -ExpectedStatusCodes @(200, 404)

Write-Security "`nTesting WRONG methods on /transactions/:id (SECURITY TEST)"
Test-Endpoint -Method "POST" -Url "$BASE_URL/transactions/$TRANSACTION_ID" `
    -Description "POST /transactions/:id should be rejected" `
    -ShouldSucceed $false `
    -Headers $headers

Test-Endpoint -Method "PUT" -Url "$BASE_URL/transactions/$TRANSACTION_ID" `
    -Description "PUT /transactions/:id should be rejected" `
    -ShouldSucceed $false `
    -Headers $headers

Test-Endpoint -Method "PATCH" -Url "$BASE_URL/transactions/$TRANSACTION_ID" `
    -Description "PATCH /transactions/:id should be rejected" `
    -ShouldSucceed $false `
    -Headers $headers

Test-Endpoint -Method "DELETE" -Url "$BASE_URL/transactions/$TRANSACTION_ID" `
    -Description "DELETE /transactions/:id should be rejected" `
    -ShouldSucceed $false `
    -Headers $headers

Write-Info "`nTesting GET /transactions/statistics (CORRECT METHOD)"
Test-Endpoint -Method "GET" -Url "$BASE_URL/transactions/statistics" `
    -Description "Get transaction statistics" `
    -ShouldSucceed $true `
    -Headers $headers `
    -ExpectedStatusCodes @(200)

Write-Security "`nTesting WRONG methods on /transactions/statistics (SECURITY TEST)"
Test-Endpoint -Method "POST" -Url "$BASE_URL/transactions/statistics" `
    -Description "POST /transactions/statistics should be rejected" `
    -ShouldSucceed $false `
    -Headers $headers

Test-Endpoint -Method "PUT" -Url "$BASE_URL/transactions/statistics" `
    -Description "PUT /transactions/statistics should be rejected" `
    -ShouldSucceed $false `
    -Headers $headers

Test-Endpoint -Method "DELETE" -Url "$BASE_URL/transactions/statistics" `
    -Description "DELETE /transactions/statistics should be rejected" `
    -ShouldSucceed $false `
    -Headers $headers

# ============================================
# FINAL SUMMARY
# ============================================

Write-Header "TEST SUMMARY"

$passPercentage = if ($script:totalTests -gt 0) { 
    [math]::Round(($script:passedTests / $script:totalTests) * 100, 2) 
}
else { 
    0 
}

$securityPercentage = if (($script:securityPassed + $script:securityFailed) -gt 0) {
    [math]::Round(($script:securityPassed / ($script:securityPassed + $script:securityFailed)) * 100, 2)
}
else {
    0
}

Write-Host "Total Tests Run: $($script:totalTests)" -ForegroundColor Cyan
Write-Host ""
Write-Host "Functional Tests:" -ForegroundColor Yellow
Write-Host "  [PASS] Passed: $($script:passedTests)" -ForegroundColor Green
Write-Host "  [FAIL] Failed: $($script:failedTests)" -ForegroundColor Red
Write-Host "  Pass Rate: $passPercentage%" -ForegroundColor $(if ($passPercentage -ge 80) { "Green" } else { "Red" })
Write-Host ""
Write-Host "Security Tests (Method Validation):" -ForegroundColor Yellow
Write-Host "  [PASS] Correctly Rejected: $($script:securityPassed)" -ForegroundColor Green
Write-Host "  [FAIL] Security Issues: $($script:securityFailed)" -ForegroundColor Red
Write-Host "  Security Rate: $securityPercentage%" -ForegroundColor $(if ($securityPercentage -ge 95) { "Green" } else { "Red" })
Write-Host ""

if ($script:failedTests -eq 0 -and $script:securityFailed -eq 0) {
    Write-Host "[SUCCESS] ALL TESTS PASSED! Your API is secure and working correctly!" -ForegroundColor Green
}
elseif ($script:securityFailed -eq 0) {
    Write-Host "[OK] Security is GOOD! But some functional tests failed." -ForegroundColor Yellow
}
elseif ($script:failedTests -eq 0) {
    Write-Host "[WARNING] Functional tests passed but SECURITY ISSUES FOUND!" -ForegroundColor Red
}
else {
    Write-Host "[ERROR] Issues found in both functional and security tests!" -ForegroundColor Red
}

Write-Host "`n[COMPLETE] Testing Complete!`n" -ForegroundColor Magenta
