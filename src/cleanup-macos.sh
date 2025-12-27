#!/bin/bash
set -e

# --- Helper Functions ---
log() {
    echo "[cleanup-macos] $1"
}

remove_item() {
    local path="$1"
    local use_sudo="$2"
    if [ -z "$path" ]; then return; fi

    if [ -e "$path" ]; then
        if [ "$INPUT_DRY_RUN" == "true" ]; then
            log "DRY RUN: Would remove $path"
        else
            log "Removing $path..."
            if [ "$use_sudo" == "true" ]; then
                sudo rm -rf "$path"
            else
                rm -rf "$path"
            fi
        fi
    else
        log "Skipping $path (not found)"
    fi
}

# --- Main Logic ---

log "Starting macOS cleanup..."

# 1. Android (User dir)
if [ "$INPUT_REMOVE_ANDROID" == "true" ]; then
    remove_item "/Users/runner/Library/Android/sdk" "false"
    remove_item "$ANDROID_HOME" "false"
    remove_item "$ANDROID_SDK_ROOT" "false"
fi

# 2. Haskell (User dir)
if [ "$INPUT_REMOVE_HASKELL" == "true" ]; then
    remove_item "/Users/runner/.ghcup" "false"
fi

# 3. Xcode (System dir - needs sudo)
if [ "$INPUT_REMOVE_XCODE" == "true" ]; then
    log "Checking for unused Xcode versions..."
    if command -v xcode-select &> /dev/null; then
        CURRENT_XCODE=$(xcode-select -p)
        log "Current Xcode: $CURRENT_XCODE"
        
        # We need to find the .app bundle that contains this path.
        # Usually /Applications/Xcode_13.2.1.app/Contents/Developer -> /Applications/Xcode_13.2.1.app
        
        # List all Xcode apps in /Applications
        # Using nullglob to handle case where no matches found
        shopt -s nullglob
        for xcode_app in /Applications/Xcode*.app; do
            # Check if the current selected path is inside this app
            if [[ "$CURRENT_XCODE" == "$xcode_app"* ]]; then
                log "Keeping active Xcode: $xcode_app"
            else
                if [ "$INPUT_DRY_RUN" == "true" ]; then
                    log "DRY RUN: Would remove unused Xcode: $xcode_app"
                else
                    log "Removing unused Xcode: $xcode_app"
                    sudo rm -rf "$xcode_app"
                fi
            fi
        done
        shopt -u nullglob
    else
        log "xcode-select not found, skipping Xcode cleanup."
    fi
fi

# 4. Browsers (System dir - needs sudo)
if [ "$INPUT_REMOVE_BROWSERS" == "true" ]; then
    remove_item "/Applications/Google Chrome.app" "true"
    remove_item "/Applications/Firefox.app" "true"
    remove_item "/Applications/Microsoft Edge.app" "true"
fi

log "macOS cleanup complete."
