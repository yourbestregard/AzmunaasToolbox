#!/system/bin/sh

MODPATH=/data/adb/modules/playintegrityfix 
KEYBOX_DIR="/data/adb/tricky_store"
KEYBOX_FILE="$KEYBOX_DIR/keybox.xml"
KEYBOX_BACKUP_FILE="$KEYBOX_DIR/keybox_backup.xml"
KEYBOX_URL="https://raw.githubusercontent.com/yourbestregard/AzmunaasToolbox/refs/heads/WebUIX/config.xml"

log_message() {
    echo "$(date +%Y-%m-%d\ %H:%M:%S) [KEYBOX] $1"
}

if [ -f "$KEYBOX_FILE" ]; then
    log_message “Keybox.xml already exists, back it up to keybox_backup.xml”
    mv "$KEYBOX_FILE" "$KEYBOX_BACKUP_FILE"
    if [ $? -eq 0 ]; then
        log_message “Backup successful.”
    else
        log_message "Failed to backup keybox.xml. Aborting."
        #exit 1
    fi
fi

log_message “Processing keybox...”
# Menggunakan curl jika tersedia, jika tidak wget
if command -v curl >/dev/null 2>&1; then
    curl -sL "$KEYBOX_URL" -o "$KEYBOX_FILE"
elif command -v wget >/dev/null 2>&1; then
    wget -qO "$KEYBOX_FILE" "$KEYBOX_URL"
else
    log_message "Error: curl or wget not found. Unable to process keybox."
    #exit 1
fi

if [ $? -eq 0 ] && [ -f "$KEYBOX_FILE" ] && [ -s "$KEYBOX_FILE" ]; then
    log_message “Keybox processed successfully.”
    chmod 0644 "$KEYBOX_FILE"
    log_message “Keybox permission set to 0644.”
else
    log_message "Error: Failed to verify keybox."
    #exit 1
fi
