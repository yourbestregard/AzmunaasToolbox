#!/system/bin/sh
# replace_charging_sound.sh (Fitur 7)

MODPATH=/data/adb/modules/azmunaas_toolbox
ORIGINAL_SOUND_PATH="/system/product/media/audio/ui/ChargingStarted.ogg"
BACKUP_SOUND_PATH="$MODPATH/ChargingStarted_backup.ogg"
NEW_SOUND_PATH="$MODPATH/sound/new_charging_sound.ogg"

log_message() {
    echo "$(date +%Y-%m-%d\ %H:%M:%S) [Sound Replace] $1"
}

log_message "Memulai penggantian suara ChargingStarted.ogg..."

# Backup original sound file
if [ -f "$ORIGINAL_SOUND_PATH" ]; then
    log_message "Membackup suara asli ke $BACKUP_SOUND_PATH..."
    cp -f "$ORIGINAL_SOUND_PATH" "$BACKUP_SOUND_PATH"
    if [ $? -eq 0 ]; then
        log_message "Backup suara asli berhasil."
    else
        log_message "Gagal membackup suara asli. Lanjutkan mencoba mengganti."
    fi
else
    log_message "Suara asli ($ORIGINAL_SOUND_PATH) tidak ditemukan. Melanjutkan tanpa backup."
fi

# Check if new sound file exists in the module's sound directory
if [ -f "$NEW_SOUND_PATH" ]; then
    log_message "Menyalin suara baru dari $NEW_SOUND_PATH ke $ORIGINAL_SOUND_PATH..."
    mount -o remount,rw /system
    cp -f "$NEW_SOUND_PATH" "$ORIGINAL_SOUND_PATH"
    if [ $? -eq 0 ]; then
        chmod 0644 "$ORIGINAL_SOUND_PATH"
        chown 0:0 "$ORIGINAL_SOUND_PATH"
        log_message "Suara ChargingStarted.ogg berhasil diganti."
    else
        log_message "Error: Gagal menyalin suara baru. Pastikan partisi /system bisa ditulis."
    fi
    mount -o remount,ro /system
else
    log_message "Error: File suara baru ($NEW_SOUND_PATH) tidak ditemukan. Harap letakkan file .ogg Anda di sana setelah instalasi modul."
fi

log_message "Penggantian suara ChargingStarted.ogg selesai."
