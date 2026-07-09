$body = '{"phone":"0501234567","password":"password"}'
$headers = @{ Accept = 'application/json' }

Write-Output "=== Testing POST /api/login with ACTUAL admin phone ==="
try {
    $r = Invoke-WebRequest -Uri 'http://127.0.0.1:8000/api/login' `
        -Method POST `
        -ContentType 'application/json' `
        -Headers $headers `
        -Body $body
    Write-Output ("STATUS: " + $r.StatusCode)
    Write-Output $r.Content
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    Write-Output ("STATUS: " + $statusCode)
    $stream = $_.Exception.Response.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($stream)
    Write-Output $reader.ReadToEnd()
}
