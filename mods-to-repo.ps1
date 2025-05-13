# Path to Minecraft Server mods folder
$serverModsPath = "D:\xampp\htdocs\Mohist-Server-1.19.2\mods"

# Path to cloned GitHub repo mods folder
$repoModsPath = "D:\xampp\htdocs\Mohist-Server-1.19.2\Minecraft-Server\mods"

# Path to server-only-mods.txt file
$serverOnlyModsFile = "server-only-mods.txt"
$excludedMods = @()

# Check for server-only-mods.txt and load it
if (Test-Path -Path $serverOnlyModsFile) {
    $excludedMods = Get-Content -Path $serverOnlyModsFile | Where-Object { $_.Trim() -ne "" }
    Write-Host "`nExcluding server-only mods listed in ${serverOnlyModsFile}:`n" -ForegroundColor Yellow
    $excludedMods | ForEach-Object { Write-Host "- $_" }
} else {
    Write-Host "`n$serverOnlyModsFile not found. Creating a blank one..." -ForegroundColor Cyan
    New-Item -ItemType File -Path $serverOnlyModsFile -Force | Out-Null
}

# Navigate to the repo folder
Set-Location -Path "D:\xampp\htdocs\Mohist-Server-1.19.2\Minecraft-Server"

# Check if server mods folder exists and list contents
if (Test-Path -Path $serverModsPath) {
    Write-Host "`nServer mods folder found. Contents:"
    Get-ChildItem -Path $serverModsPath
} else {
    Write-Host "Server mods folder does not exist."
    exit
}

# Ensure the mods folder exists in the cloned repo; if not, create it
if (-not (Test-Path -Path $repoModsPath)) {
    Write-Host "Creating mods folder in the repo."
    New-Item -ItemType Directory -Path $repoModsPath
} else {
    Write-Host "Mods folder already exists in the repo."
}

# Show repo mods folder contents before cleanup
Write-Host "`nRepo mods folder contents before cleanup:"
Get-ChildItem -Path $repoModsPath

# Remove outdated mods from the repo mods folder
Write-Host "`nRemoving outdated .jar files from repo..."
Get-ChildItem -Path $repoModsPath -Filter *.jar | Remove-Item -Force

# Copy current mods from server to repo excluding server-only mods
Write-Host "`nCopying mods from server to repo (excluding server-only)..."
Get-ChildItem -Path $serverModsPath -Filter *.jar | ForEach-Object {
    if ($excludedMods -notcontains $_.Name) {
        Copy-Item -Path $_.FullName -Destination $repoModsPath -Force
    } else {
        Write-Host "Excluded (server-only): $($_.Name)" -ForegroundColor DarkYellow
    }
}

# Create or update server-mod-list.txt in the repo's mods folder
$modListPath = Join-Path $repoModsPath "server-mod-list.txt"
Get-ChildItem -Path $repoModsPath -Filter *.jar | Select-Object -ExpandProperty Name | Set-Content -Path $modListPath

Write-Host "`nGenerated server-mod-list.txt with mod filenames:"
Get-Content -Path $modListPath

# Git operations
git status
git add .
git commit -m "Sync new mods with server and update server-mod-list.txt"
git push origin main

Write-Host "`nMods synced and pushed to GitHub successfully!"
pause
