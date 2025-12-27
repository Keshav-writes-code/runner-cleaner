$ErrorActionPreference = "Stop"

function Log-Message {
    param([string]$Message)
    Write-Host "[cleanup-windows] $Message"
}

function Remove-Item-Safe {
    param([string]$Path)
    
    if (Test-Path -Path $Path) {
        if ($env:INPUT_DRY_RUN -eq 'true') {
            Log-Message "DRY RUN: Would remove $Path"
        } else {
            Log-Message "Removing $Path..."
            Remove-Item -Path $Path -Recurse -Force -ErrorAction SilentlyContinue
        }
    } else {
        Log-Message "Skipping $Path (not found)"
    }
}

Log-Message "Starting Windows cleanup..."

# 1. Android
if ($env:INPUT_REMOVE_ANDROID -eq 'true') {
    Remove-Item-Safe "C:\Program Files (x86)\Android"
    if ($env:ANDROID_HOME) { Remove-Item-Safe $env:ANDROID_HOME }
    if ($env:ANDROID_SDK_ROOT) { Remove-Item-Safe $env:ANDROID_SDK_ROOT }
}

# 2. .NET
if ($env:INPUT_REMOVE_DOTNET -eq 'true') {
    Remove-Item-Safe "C:\Program Files\dotnet"
    if ($env:DOTNET_ROOT) { Remove-Item-Safe $env:DOTNET_ROOT }
}

# 3. Haskell
if ($env:INPUT_REMOVE_HASKELL -eq 'true') {
    Remove-Item-Safe "C:\ghcup"
}

# 4. Docker
if ($env:INPUT_REMOVE_DOCKER_IMAGES -eq 'true') {
    if (Get-Command "docker" -ErrorAction SilentlyContinue) {
        if ($env:INPUT_DRY_RUN -eq 'true') {
            Log-Message "DRY RUN: Would run 'docker system prune -af'"
        } else {
            Log-Message "Pruning Docker images..."
            docker system prune -af
        }
    } else {
        Log-Message "Docker not found, skipping prune."
    }
}

Log-Message "Windows cleanup complete."
