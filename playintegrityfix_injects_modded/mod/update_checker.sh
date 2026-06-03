#!/system/bin-sh

# Lokasi File dan URL
LOCAL_VERSION_FILE="/data/adb/modules/playintegrityfix/mod/versioncode.txt"
REMOTE_VERSION_URL="https://raw.githubusercontent.com/yourbestregard/AzmunaasToolbox/refs/heads/WebUIX/playintegrityfix_injects_update.txt"

# Lokasi folder Download di memori internal (/storage/emulated/0/Download)
DOWNLOAD_FOLDER="/sdcard/Download"

# Fungsi Bantuan

log_message() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') [UPDATE_CHECKER] $1"
}

find_busybox() {
    [ -n "$BUSYBOX" ] && return 0
    local path
    for path in /data/adb/modules/busybox-ndk/system/bin/busybox /data/adb/modules/busybox-ndk/system/xbin/busybox /data/adb/magisk/busybox /data/adb/ksu/bin/busybox /data/adb/ap/bin/busybox; do
        if [ -x "$path" ]; then BUSYBOX="$path"; return 0; fi
    done
    return 1
}

download() {
    local url="$1"; local outfile="$2"
    if command -v curl >/dev/null 2>&1; then curl -sL --connect-timeout 15 "$url" -o "$outfile"; return $?; fi
    if command -v wget >/dev/null 2>&1; then wget -qO "$outfile" --timeout=15 "$url"; return $?; fi
    if find_busybox; then "$BUSYBOX" wget -qO "$outfile" -T 15 "$url"; return $?; fi
    return 127
}

# Logika Utama Skrip

log_message "Starting update check..."

# Baca versi yang terinstal
if [ -f "$LOCAL_VERSION_FILE" ]; then
    VERSION_INSTALLED=$(cat "$LOCAL_VERSION_FILE")
else
    log_message "Local version file not found, assuming version 0."
    VERSION_INSTALLED="0"
fi
case $VERSION_INSTALLED in ''|*[!0-9]*) VERSION_INSTALLED="0" ;; esac

# Ambil versi terbaru dari server
log_message "Retrieving the latest version information from the server..."
VERSION_LATEST=$(download "$REMOTE_VERSION_URL" -); DOWNLOAD_STATUS=$?
if [ "$DOWNLOAD_STATUS" -ne 0 ] || [ -z "$VERSION_LATEST" ]; then log_message "ERROR: Failed to download the version file. Cancel."; exit 1; fi
case $VERSION_LATEST in ''|*[!0-9]*) log_message "ERROR: Content from the server is not a valid number."; exit 1 ;; esac

log_message "Installed Version: $VERSION_INSTALLED"
log_message "Latest Version:    $VERSION_LATEST"

# Bandingkan versi dan lakukan tindakan
if [ "$VERSION_LATEST" -gt "$VERSION_INSTALLED" ]; then
    log_message "Update available! Starting download process..."
    
    # Siapkan nama file dan path tujuan di folder Download
    MODULE_FILENAME="PlayIntegrityFix_injects_Moddedv${VERSION_LATEST}.zip"
    DESTINATION_FILE="$DOWNLOAD_FOLDER/$MODULE_FILENAME"
    MODULE_URL="https://github.com/yourbestregard/AzmunaasToolbox/raw/refs/heads/WebUIX/$MODULE_FILENAME"
    
    # Pastikan folder Download ada
    mkdir -p "$DOWNLOAD_FOLDER"

    log_message "Downloading to: $DESTINATION_FILE"
    download "$MODULE_URL" "$DESTINATION_FILE"
    
    if [ $? -eq 0 ] && [ -s "$DESTINATION_FILE" ]; then
        log_message "-----------------------------------------------------"
        log_message "SUCCESS! New module has been downloaded."
        log_message "LOCATION: $DESTINATION_FILE"
        log_message "ACTION: Open root manager and install this file manually."
        log_message "-----------------------------------------------------"
    else
        log_message "ERROR: Failed to download module file. Please try again."
    fi
else
    log_message "You are already using the latest version. No action is required."
fi

log_message "Update check complete."