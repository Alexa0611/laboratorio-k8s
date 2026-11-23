
param(
    [Parameter(Mandatory=$true)]
    [string]$OutputFile
)

# Script reutilizable para medir disponibilidad
# Uso: .\test-availability.ps1 -OutputFile <nombre_archivo_salida>
# Ejemplo para Lab 1.1: .\test-availability.ps1 -OutputFile "availability-baseline.txt"
# Ejemplo para Lab 1.2: .\test-availability.ps1 -OutputFile "resilience-sample.txt"

# 1. Validar que se proporcionó el parámetro
if ([string]::IsNullOrWhiteSpace($OutputFile)) {
    Write-Host "Error: Debes proporcionar el nombre del archivo de salida" -ForegroundColor Red
    Write-Host "Uso: .\test-availability.ps1 -OutputFile <nombre_archivo>"
    Write-Host ""
    Write-Host "Ejemplos:"
    Write-Host '  Lab 1.1: .\test-availability.ps1 -OutputFile "availability-baseline.txt"'
    Write-Host '  Lab 1.2: .\test-availability.ps1 -OutputFile "resilience-sample.txt"'
    exit 1
}

$ENDPOINT_URL = "http://localhost:8080/v1/products"
$NUM_REQUESTS = 200

# 2. Limpiar archivo de salida
Set-Content -Path $OutputFile -Value "" -NoNewline

Write-Host "Ejecutando $NUM_REQUESTS solicitudes a $ENDPOINT_URL..."

# 3. Loop de solicitudes
for ($i = 1; $i -le $NUM_REQUESTS; $i++) {

    $responseFile = [System.IO.Path]::GetTempFileName()

    try {
        $metadata = curl.exe -sS -o $responseFile -w "%{http_code} %{time_total}" $ENDPOINT_URL

        $body = Get-Content -Path $responseFile -Raw -ErrorAction SilentlyContinue
        $body = $body -replace "`r?`n", " "

        $line = "{0:D3} {1} {2}" -f $i, $metadata, $body

        Add-Content -Path $OutputFile -Value $line

        Write-Host $line
    }
    finally {
        Remove-Item -Path $responseFile -Force -ErrorAction SilentlyContinue
    }
}

Write-Host ""
Write-Host "Resultados guardados en: $OutputFile"
Write-Host ""

# 4. Procesar métricas
$lines = @(Get-Content -Path $OutputFile)

$SUCCESS = @($lines | Where-Object { $_ -match '"status":"SUCCESS"' }).Count

$HTTP_200 = @($lines | Where-Object { $_ -match '^\d+\s+200\s+' }).Count

$HTTP_ERRORS = @($lines | Where-Object { $_ -notmatch '^\d+\s+200\s+' }).Count

$TOTAL = $lines.Count

if ($TOTAL -gt 0) {

    $AVAILABILITY = [math]::Floor(($HTTP_200 / $TOTAL) * 10000) / 10000

    Write-Host "Respuestas SUCCESS: $SUCCESS"
    Write-Host "Respuestas HTTP 200: $HTTP_200"
    Write-Host "Respuestas HTTP distintas de 200: $HTTP_ERRORS"
    Write-Host "Solicitudes totales: $TOTAL"
    Write-Host "Disponibilidad observada: $("{0:F4}" -f $AVAILABILITY)"
}
