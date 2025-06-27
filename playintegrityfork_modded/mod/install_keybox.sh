#!/system/bin/sh

# Directory and file locations
KEYBOX_DIR="/data/adb/tricky_store"
KEYBOX_FILE="$KEYBOX_DIR/keybox.xml"
KEYBOX_BACKUP_FILE="$KEYBOX_DIR/keybox_backup.xml"
KEYBOX_URL="https://raw.githubusercontent.com/yourbestregard/AzmunaasToolbox/refs/heads/WebUIX/config.xml"

# Function to record logs with timestamp format
log_message() {
    # Print logs to Magisk/KernelSU/Apatch logs
    echo "$(date +'%Y-%m-%d %H:%M:%S') [KEYBOX] $1"
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
        # exit 1 
    fi
fi

# Try downloading the new keybox
log_message "Processing keybox from URL..."
# Use curl if available, otherwise wget
if command -v curl >/dev/null 2>&1; then
    curl -sL "$KEYBOX_URL" -o "$KEYBOX_FILE"
    CURL_EXIT_CODE=$?
elif command -v wget >/dev/null 2>&1; then
    wget -qO "$KEYBOX_FILE" "$KEYBOX_URL"
    CURL_EXIT_CODE=$?
else
    log_message "ERROR: curl or wget not found. Cannot download keybox. Join @azmunaashome group on telegram to get the latest keybox then install the keybox manually."
    CURL_EXIT_CODE=1
fi

# Verify download results and apply fallback logic
# Success condition: the download was successful AND the file exists AND the file is not empty
if [ "$CURL_EXIT_CODE" -eq 0 ] && [ -f "$KEYBOX_FILE" ] && [ -s "$KEYBOX_FILE" ]; then
    log_message "Keybox downloaded and verified successfully."
    chmod 0644 "$KEYBOX_FILE"
    log_message "Keybox permission set to 0644."
else
    # If it FAILS, apply fallback logic
    log_message "ERROR: Failed to download or verify new keybox from URL."
    
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