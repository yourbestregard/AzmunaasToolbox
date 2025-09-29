#!/system/bin/sh

# Directory and file locations
KEYBOX_DIR="/data/adb/tricky_store"
KEYBOX_FILE="$KEYBOX_DIR/keybox.xml"
KEYBOX_BACKUP_FILE="$KEYBOX_DIR/keybox_backup.xml"
KEYBOX_URL="https://raw.githubusercontent.com/yourbestregard/AzmunaasToolbox/refs/heads/WebUIX/config.xml"

# Function to record logs with timestamp format
log_message() {
    # Print logs to Magisk/KernelSU/Apatch logs
    echo "$(date +'%Y-%m-%d %H:%M:%S') [INSTALL_KEYBOX] $1"
}

# Function to find a working BusyBox executable
find_busybox() {
    # Jika variabel BUSYBOX sudah ada, tidak perlu mencari lagi
    [ -n "$BUSYBOX" ] && return 0
    
    # Mencari BusyBox di path umum modul root
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
    
    # Coba gunakan curl jika ada
    if command -v curl >/dev/null 2>&1; then
        log_message "Using curl to download..."
        curl -sL "$url" -o "$outfile"
        return $?
    fi
    
    # Coba gunakan wget jika ada
    if command -v wget >/dev/null 2>&1; then
        log_message "Using wget to download..."
        wget -qO "$outfile" "$url"
        return $?
    fi
    
    # Cari dan gunakan BusyBox jika curl/wget standar gagal
    if find_busybox; then
        log_message "Using BusyBox wget to download..."
        "$BUSYBOX" wget -qO "$outfile" "$url"
        return $?
    fi
    
    # Jika semua metode gagal
    return 127 # Command not found
}

# Backup existing keyboxes if found
if [ -f "$KEYBOX_FILE" ]; then
    log_message "Keybox.xml already exists, backing it up..."
    # Move existing files into backup files
    mv "$KEYBOX_FILE" "$KEYBOX_BACKUP_FILE"
    if [ $? -eq 0 ]; then
        log_message "Backup successful."
    else
        log_message "ERROR: Failed to backup keybox.xml. Aborting modification."
        # Sebaiknya tidak keluar, agar logika fallback tetap bisa berjalan
    fi
fi

# Try downloading the new keybox using the new download function
log_message "Processing keybox from URL..."
download "$KEYBOX_URL" "$KEYBOX_FILE"
DOWNLOAD_EXIT_CODE=$?

# Verify download results and apply fallback logic
if [ "$DOWNLOAD_EXIT_CODE" -eq 0 ] && [ -f "$KEYBOX_FILE" ] && [ -s "$KEYBOX_FILE" ]; then
    log_message "Keybox downloaded and verified successfully."
    chmod 0644 "$KEYBOX_FILE"
    log_message "Keybox permission set to 0644."
else
    # Jika GAGAL, berikan pesan error yang sesuai dan jalankan logika fallback
    log_message "ERROR: Failed to download or verify new keybox from URL."
    
    if [ "$DOWNLOAD_EXIT_CODE" -eq 127 ]; then
        log_message "Reason: curl, wget, or a working BusyBox was not found."
        log_message "Please install a BusyBox module to fix this. Recommended: https://github.com/Magisk-Modules-Repo/busybox-ndk"
    else
        log_message "Reason: Download command failed with exit code $DOWNLOAD_EXIT_CODE."
    fi
    
    # Check if any backup files can be restored
    if [ -f "$KEYBOX_BACKUP_FILE" ]; then
        log_message "Attempting to restore from backup..."
        mv "$KEYBOX_BACKUP_FILE" "$KEYBOX_FILE"
        if [ $? -eq 0 ]; then
            log_message "Backup keybox restored successfully."
        else
            log_message "CRITICAL: Failed to restore backup keybox. Module might not work."
        fi
    else
        log_message "CRITICAL: Download failed and no backup file was found."
    fi
fi