#!/bin/bash
set -e

# --- Helper Functions ---
log() {
    echo "[cleanup-linux] $1"
}

remove_item() {
    local path="$1"
    if [ -z "$path" ]; then return; fi

    if [ -e "$path" ]; then
        if [ "$INPUT_DRY_RUN" == "true" ]; then
            log "DRY RUN: Would remove $path"
        else
            log "Removing $path..."
            sudo rm -rf "$path"
        fi
    else
        log "Skipping $path (not found)"
    fi
}

# --- Main Logic ---

log "Starting Linux cleanup..."

# 1. Android
if [ "$INPUT_REMOVE_ANDROID" == "true" ]; then
    remove_item "/usr/local/lib/android"
    remove_item "$ANDROID_HOME"
    remove_item "$ANDROID_SDK_ROOT"
fi

# 2. .NET
if [ "$INPUT_REMOVE_DOTNET" == "true" ]; then
    remove_item "/usr/share/dotnet"
    remove_item "$DOTNET_ROOT"
fi

# 3. Haskell
if [ "$INPUT_REMOVE_HASKELL" == "true" ]; then
    remove_item "/opt/ghc"
    remove_item "/usr/local/.ghcup"
fi

# 4. CodeQL
if [ "$INPUT_REMOVE_CODEQL" == "true" ]; then
    remove_item "/opt/hostedtoolcache/CodeQL"
fi

# 5. Browsers
if [ "$INPUT_REMOVE_BROWSERS" == "true" ]; then
    remove_item "/opt/google/chrome"
    remove_item "/opt/microsoft/msedge"
    remove_item "/usr/lib/firefox"
fi

# 6. Docker
if [ "$INPUT_REMOVE_DOCKER_IMAGES" == "true" ]; then
    if command -v docker &> /dev/null; then
        if [ "$INPUT_DRY_RUN" == "true" ]; then
            log "DRY RUN: Would run 'docker system prune -af'"
        else
            log "Pruning Docker images..."
            sudo docker system prune -af || true
        fi
    else
        log "Docker not found, skipping prune."
    fi
fi

# 7. Swap
if [ "$INPUT_REMOVE_SWAP" == "true" ]; then
    SWAP_FILE="/mnt/swapfile" # Common path on GitHub runners
    if [ -f "$SWAP_FILE" ]; then
        if [ "$INPUT_DRY_RUN" == "true" ]; then
            log "DRY RUN: Would disable swap and remove $SWAP_FILE"
        else
            log "Disabling and removing swap..."
            sudo swapoff -a || true
            sudo rm -f "$SWAP_FILE"
        fi
    else
        log "Swap file not found at $SWAP_FILE"
    fi
fi

# 8. Apt Clean
if [ "$INPUT_DRY_RUN" == "true" ]; then
    log "DRY RUN: Would run 'sudo apt-get clean'"
else
    log "Running apt-get clean..."
    sudo apt-get clean || true
fi

log "Linux cleanup complete."
