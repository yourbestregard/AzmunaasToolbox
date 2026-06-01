#!/system/bin/sh

# Directory list, target URL, and Temporary Download Location
TARGET_DIRS="/data/misc/keystore/omk /data/adb/modules/oh_my_keymint"
KEYBOX_URL="https://raw.githubusercontent.com/yourbestregard/AzmunaasToolbox/refs/heads/WebUIX/config.xml"
TMP_KEYBOX="/data/local/tmp/new_keybox_tmp.xml"

# Function to record logs with timestamp format
log_message() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') [INSTALL_KEYBOX] $1"
}

# Function to find a working BusyBox executable
find_busybox() {
    [ -n "$BUSYBOX" ] && return 0
    
    local path
    for path in \
        /data/adb/modules/busybox-ndk/system/bin/busybox \
        /data/adb/modules/busybox-ndk/system/xbin/busybox \
        /data/adb/magisk/busybox \
        /data/adb/ksu/bin/busybox \
        /data/adb/ap/bin/busybox; do
        
        if [ -x "$path" ]; then
            BUSYBOX="$path"
            log_message "BusyBox found at: $BUSYBOX"
            return 0
        fi
    done
    
    log_message "BusyBox executable not found in common paths."
    return 1
}

# Function to download files using the best available tool
download() {
    local url="$1"
    local outfile="$2"
    
    if command -v curl >/dev/null 2>&1; then
        log_message "Using curl to download..."
        curl -sL "$url" -o "$outfile"
        return $?
    fi
    
    if command -v wget >/dev/null 2>&1; then
        log_message "Using wget to download..."
        wget -qO "$outfile" "$url"
        return $?
    fi
    
    if find_busybox; then
        log_message "Using BusyBox wget to download..."
        "$BUSYBOX" wget -qO "$outfile" "$url"
        return $?
    fi
    
    return 127 # Command not found
}

log_message "======================================="
log_message "Starting keybox update process..."

# Donglod
log_message "Downloading new keybox from URL to temporary location..."
download "$KEYBOX_URL" "$TMP_KEYBOX"
DOWNLOAD_EXIT_CODE=$?

# Verifikasi apakah unduhan berhasil dan berkas tidak kosong (-s)
if [ "$DOWNLOAD_EXIT_CODE" -eq 0 ] && [ -f "$TMP_KEYBOX" ] && [ -s "$TMP_KEYBOX" ]; then
    log_message "New keybox downloaded and verified successfully."

    # Eksekusi
    for KEYBOX_DIR in $TARGET_DIRS; do
        log_message "---------------------------------------"
        log_message "Processing directory: $KEYBOX_DIR"
        
        KEYBOX_FILE="$KEYBOX_DIR/keybox.xml"
        KEYBOX_BACKUP_FILE="$KEYBOX_DIR/keybox_backup.xml"

        # Buat direktori jika belum ada
        if [ ! -d "$KEYBOX_DIR" ]; then
            log_message "Creating directory $KEYBOX_DIR..."
            mkdir -p "$KEYBOX_DIR"
        fi

        # Backup
        if [ -f "$KEYBOX_FILE" ]; then
            log_message "Backing up existing keybox.xml..."
            # Menggunakan 'cat' untuk menyalin agar terhindar dari masalah permission/SELinux
            cat "$KEYBOX_FILE" > "$KEYBOX_BACKUP_FILE"
            log_message "Backup created at $KEYBOX_BACKUP_FILE."
        else
            # Jika sebelumnya file asli tidak ada, buat file kosong dulu
            touch "$KEYBOX_FILE"
        fi

        # Ganti isi keybox asli dengan isi dari keybox baru
        log_message "Injecting new keybox content into $KEYBOX_FILE..."
        cat "$TMP_KEYBOX" > "$KEYBOX_FILE"
        chmod 0644 "$KEYBOX_FILE"
        log_message "Keybox updated and permissions set to 0644."
    done

    # Bebersih
    log_message "---------------------------------------"
    log_message "Cleaning up temporary downloaded keybox..."
    rm -f "$TMP_KEYBOX"
    log_message "All keybox updates completed successfully."

else
    # Elol
    log_message "ERROR: Failed to download or verify new keybox from URL."
    
    if [ "$DOWNLOAD_EXIT_CODE" -eq 127 ]; then
        log_message "Reason: curl, wget, or a working BusyBox was not found."
        log_message "Please install a BusyBox module to fix this. Recommended: https://github.com/Magisk-Modules-Repo/busybox-ndk"
    else
        log_message "Reason: Download command failed with exit code $DOWNLOAD_EXIT_CODE or file is empty."
    fi
    
    log_message "CRITICAL: Update aborted. Existing keybox files were not touched and are still working normally."
fi