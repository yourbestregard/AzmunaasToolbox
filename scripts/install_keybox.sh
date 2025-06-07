#!/system/bin/sh
# install_keybox.sh (Fitur 3)

MODPATH=/data/adb/modules/azmunaas_toolbox
KEYBOX_DIR="/data/adb/trickystore"
KEYBOX_FILE="$KEYBOX_DIR/keybox.xml"
KEYBOX_BACKUP_FILE="$KEYBOX_DIR/keybox_backup.xml"
KEYBOX_URL="https://raw.githubusercontent.com/yourbestregard/android_modules/refs/heads/main/azmunaastoolbox/valid.xml"

log_message() {
    echo "$(date +%Y-%m-%d\ %H:%M:%S) [Keybox] $1"
}

log_message "Memulai instalasi Keybox Valid..."

mkdir -p "$KEYBOX_DIR"

if [ -f "$KEYBOX_FILE" ]; then
    log_message "Keybox.xml sudah ada, membackupnya ke keybox_backup.xml"
    mv "$KEYBOX_FILE" "$KEYBOX_BACKUP_FILE"
    if [ $? -eq 0 ]; then
        log_message "Backup berhasil."
    else
        log_message "Gagal membackup keybox.xml. Aborting."
        exit 1
    fi
fi

log_message "Mengunduh keybox.xml dari $KEYBOX_URL..."
# Menggunakan curl jika tersedia, jika tidak wget
if command -v curl >/dev/null 2>&1; then
    curl -sL "$KEYBOX_URL" -o "$KEYBOX_FILE"
elif command -v wget >/dev/null 2>&1; then
    wget -qO "$KEYBOX_FILE" "$KEYBOX_URL"
else
    log_message "Error: curl atau wget tidak ditemukan. Tidak dapat mengunduh keybox.xml."
    exit 1
fi

if [ $? -eq 0 ] && [ -f "$KEYBOX_FILE" ] && [ -s "$KEYBOX_FILE" ]; then
    log_message "Keybox.xml berhasil diunduh dan disimpan di $KEYBOX_FILE."
    chmod 0644 "$KEYBOX_FILE"
    log_message "Izin keybox.xml diatur ke 0644."
else
    log_message "Error: Gagal mengunduh atau memverifikasi keybox.xml."
    exit 1
}

log_message "Instalasi Keybox Valid selesai."
