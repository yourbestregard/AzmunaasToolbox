#!/system/bin/sh

# Lokasi File dan URL
MOD_DIR="/data/adb/playintegrityfix"
LOCAL_VERSION_FILE="$MOD_DIR/mod/versioncode.txt"
UPDATE_VERSION_FILE="https://raw.githubusercontent.com/yourbestregard/AzmunaasToolbox/refs/heads/WebUIX/playintegrityfix_injects_update.json"

DOWNLOAD_DIR="$MOD_DIR/tmp"
DOWNLOAD_FILE="$DOWNLOAD_DIR/update.zip"
EXTRACT_DIR="/data/adb/modules_update/playintegrityfix/"

# Fungsi untuk mencatat pesan dengan timestamp
log_message() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') [UPDATE_CHECKER] $1"
}

# Fungsi untuk mencari BusyBox yang berfungsi
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
            return 0
        fi
    done
    return 1
}

# Fungsi untuk mengunduh file
download() {
    local url="$1"
    local outfile="$2"
    
    if command -v curl >/dev/null 2>&1; then
        curl -sL --connect-timeout 15 "$url" -o "$outfile"
        return $?
    fi
    if command -v wget >/dev/null 2>&1; then
        wget -qO "$outfile" --timeout=15 "$url"
        return $?
    fi
    if find_busybox; then
        "$BUSYBOX" wget -qO "$outfile" -T 15 "$url"
        return $?
    fi
    return 127 # Command not found
}

log_message "Starting update check..."

# Pastikan direktori yang dibutuhkan ada
mkdir -p "$DOWNLOAD_DIR"
mkdir -p "$EXTRACT_DIR"

# Baca versi yang terinstal saat ini
if [ -f "$LOCAL_VERSION_FILE" ]; then
    VERSION_INSTALLED=$(cat "$LOCAL_VERSION_FILE")
else
    log_message "Local version file not found. Assuming version 0."
    VERSION_INSTALLED="0"
fi

# Pastikan versi yang terbaca adalah angka
# Jika kosong atau bukan angka, set ke 0
case $VERSION_INSTALLED in
    ''|*[!0-9]*) VERSION_INSTALLED="0" ;;
esac

# Ambil informasi versi terbaru dari remote JSON
log_message "Retrieving the latest version information from the server..."
JSON_CONTENT=$(download "$UPDATE_VERSION_FILE" -)
if [ $? -ne 0 ] || [ -z "$JSON_CONTENT" ]; then
    log_message "ERROR: Failed to download the update JSON file. Canceling."
    exit 1
fi

# Ekstrak VERSION_CODE_LATEST dari konten JSON menggunakan grep
VERSION_LATEST=$(echo "$JSON_CONTENT" | grep -o '"VERSION_CODE_LATEST": *"[0-9]*"' | grep -o '[0-9]*')

if [ -z "$VERSION_LATEST" ]; then
    log_message "ERROR: Failed to extract VERSION_CODE_LATEST from JSON. Canceling."
    exit 1
fi

log_message "Installed Version: $VERSION_INSTALLED"
log_message "New Version:    $VERSION_LATEST"

# Bandingkan versi
if [ "$VERSION_LATEST" -gt "$VERSION_INSTALLED" ]; then
    log_message "Update available! Starting download process..."
    
    # Buat URL unduhan modul
    MODULE_URL="https://github.com/yourbestregard/AzmunaasToolbox/raw/refs/heads/WebUIX/PlayIntegrityFix_injects_Moddedv${VERSION_LATEST}.zip"
    
    # Unduh modul
    log_message "Downloading module from: $MODULE_URL"
    download "$MODULE_URL" "$DOWNLOAD_FILE"
    
    if [ $? -ne 0 ] || [ ! -s "$DOWNLOAD_FILE" ]; then
        log_message "ERROR: Failed to download module file (.zip). Canceling."
        rm -f "$DOWNLOAD_FILE"
        exit 1
    fi
    
    # Ekstrak modul
    if ! find_busybox; then
        log_message "ERROR: BusyBox not found, unable to extract files. Delete download."
        rm -f "$DOWNLOAD_FILE"
        exit 1
    fi
    
    log_message "Cleaning target directory: $EXTRACT_DIR"
    rm -rf "$EXTRACT_DIR"*
    
    log_message "Extracting files to the target directory..."
    "$BUSYBOX" unzip -o -q "$DOWNLOAD_FILE" -d "$EXTRACT_DIR"
    
    if [ $? -eq 0 ]; then
        log_message "Extraction successful."
        # Perbarui file versi lokal ke versi yang baru
        echo "$VERSION_LATEST" > "$LOCAL_VERSION_FILE"
        log_message "Local version has been updated to $VERSION_LATEST."
    else
        log_message "ERROR: Failed to extract zip file."
    fi
    
    # Bersihkan file zip yang sudah diunduh
    log_message "Cleaning up download files..."
    rm -f "$DOWNLOAD_FILE"
    
else
    log_message "You are already using the latest version. No action is required."
fi

log_message "Update check complete. REMEMBER! Do not perform updates using the button on the root manager."