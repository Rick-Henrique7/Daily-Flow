# accept_licenses.ps1
# Aceita todas as licenças do Android SDK automaticamente.

$env:ANDROID_HOME = "C:\dev\projects\app-gestao-pessoal\.android-sdk"
$env:ANDROID_SDK_ROOT = $env:ANDROID_HOME
$env:Path = "$env:ANDROID_HOME\cmdline-tools\latest\bin;$env:Path"

# Confirma todas as licenças em loop
for ($i = 0; $i -lt 10; $i++) {
    Write-Host "=== Licenças, tentativa $i ===" -ForegroundColor Yellow
    $output = "y`ny`ny`ny`ny`ny`ny`ny`ny" | & "$env:ANDROID_HOME\cmdline-tools\latest\bin\sdkmanager.bat" --licenses 2>&1
    $output | Select-Object -Last 5
    if ($output -match "All SDK package licenses accepted") {
        Write-Host "Todas aceitas!" -ForegroundColor Green
        break
    }
}

# Confirma
& "$env:ANDROID_HOME\cmdline-tools\latest\bin\sdkmanager.bat" --licenses 2>&1 | Select-Object -Last 2
