#!/system/bin/sh
# replace_charging_sound.sh
log_message() {
    TIMESTAMP=$(date +%Y-%m-%d\ %H:%M:%S)
    MESSAGE="$1"
    echo "$TIMESTAMP [SCRIPT] $MESSAGE"
    echo "$TIMESTAMP [SCRIPT] $MESSAGE" >> "/data/adb/modules/azmunaas_toolbox/executor_log.txt" 2>&1
}
log_message "Loading...."
#!/system/bin/sh
# replace_charging_sound.sh
#
# Skrip ini bertujuan untuk mengganti suara default ChargingStarted.ogg sistem Android
# dengan file suara kustom yang disediakan di dalam modul. Ini dapat digunakan untuk
# personalisasi pengalaman pengisian daya perangkat.
# Skrip akan mencoba membackup suara asli sebelum menggantinya dan memerlukan akses tulis
# ke partisi /system.

# ================================================
#  Definisi Variabel
# ================================================

# Jalur instalasi modul, disediakan oleh lingkungan Magisk/KernelSU.
MODPATH=/data/adb/modules/azmunaas_toolbox
# Jalur absolut ke file suara pengisian daya asli di partisi /system.
ORIGINAL_SOUND_PATH="/system/product/media/audio/ui/ChargingStarted.ogg"
# Jalur untuk menyimpan backup file suara asli di dalam direktori sound modul.
BACKUP_SOUND_PATH="$MODPATH/sound/backup_ChargingStarted_backup.ogg"
# Jalur ke file suara baru yang akan menggantikan suara asli. Pengguna diharapkan
# menempatkan file kustom mereka dengan nama new.ogg di $MODPATH/sound/.
NEW_SOUND_PATH="$MODPATH/sound/new.ogg"

# ================================================
#  Fungsi Logging
# ================================================

# Fungsi log_message digunakan untuk mencatat pesan status ke stdout.
# Pesan ini akan ditangkap oleh executor.sh dan kemudian ditampilkan di WebUI.
log_message() {
    # Menggunakan echo dengan format waktu dan tag spesifik untuk operasi penggantian suara.
    echo "$(date +%Y-%m-%d\ %H:%M:%S) [Sound Replace] $1"
}

# ================================================
#  Logika Utama Skrip
# ================================================

log_message "Memulai penggantian suara ChargingStarted.ogg..."

# --- Backup File Suara Asli ---
# Penting untuk membackup file asli agar bisa dikembalikan di kemudian hari jika diperlukan.
if [ -f "$ORIGINAL_SOUND_PATH" ]; then # Memeriksa apakah file suara asli ada
    log_message "Membackup suara asli ke $BACKUP_SOUND_PATH..."
    # Menyalin (cp -f) file suara asli ke jalur backup.
    cp -f "$ORIGINAL_SOUND_PATH" "$BACKUP_SOUND_PATH"
    if [ $? -eq 0 ]; then # Memeriksa kode keluar dari perintah cp
        log_message "Backup suara asli berhasil."
    else
        log_message "Gagal membackup suara asli. Lanjutkan mencoba mengganti tanpa backup yang berhasil."
    fi
else
    log_message "Suara asli ($ORIGINAL_SOUND_PATH) tidak ditemukan. Melanjutkan tanpa backup."
fi

# --- Verifikasi dan Penggantian Suara Baru ---
# Memeriksa apakah file suara kustom (new.ogg) ada di direktori modul sound.
if [ -f "$NEW_SOUND_PATH" ]; then
    log_message "Menyalin suara baru dari $NEW_SOUND_PATH ke $ORIGINAL_SOUND_PATH..."
    # mount -o remount,rw /system: Mengulang mount partisi /system sebagai read-write (baca-tulis).
    # Ini diperlukan karena partisi /system biasanya di-mount sebagai read-only (baca-saja) secara default.
    mount -o remount,rw /system
    
    # Menyalin (cp -f) file suara baru ke lokasi suara asli di /system.
    cp -f "$NEW_SOUND_PATH" "$ORIGINAL_SOUND_PATH"
    if [ $? -eq 0 ]; then
        # Mengatur izin (chmod) dan kepemilikan (chown) yang benar untuk file suara yang baru disalin.
        # Izin 0644 (rw-r--r--) memungkinkan root membaca dan menulis, lainnya hanya membaca.
        # Kepemilikan 0:0 berarti root user dan root group.
        chmod 0644 "$ORIGINAL_SOUND_PATH"
        chown 0:0 "$ORIGINAL_SOUND_PATH"
        log_message "Suara ChargingStarted.ogg berhasil diganti."
    else
        log_message "Error: Gagal menyalin suara baru. Pastikan partisi /system bisa ditulis dan ada cukup ruang."
    fi
    # mount -o remount,ro /system: Mengembalikan mount partisi /system ke read-only setelah operasi selesai.
    # Ini penting untuk keamanan sistem dan stabilitas.
    mount -o remount,ro /system
else
    log_message "Error: File suara baru ($NEW_SOUND_PATH) tidak ditemukan. Harap letakkan file new.ogg Anda di sana setelah instalasi modul."
fi

log_message "Penggantian suara ChargingStarted.ogg selesai."