#!/system/bin/sh
# executor.sh
#
# Skrip ini berfungsi sebagai pengelola terpusat (central dispatcher) untuk modul Azmunaa's Toolbox.
# Ia menerima perintah (actions) dari WebUI (melalui `module.execute()`) untuk:
#   1. Mengaktifkan/menonaktifkan fitur-fitur `build.prop` atau properti runtime dengan memanipulasi file bendera (flags).
#   2. Mengeksekusi skrip-skrip fitur lainnya yang berada di direktori `scripts/`.
#   3. Memberikan status fitur-fitur yang bisa di-toggle kembali ke WebUI.
# Semua output dari skrip ini (stdout dan stderr) dialihkan ke file log khusus (`executor_log.txt`)
# dan juga ditampilkan di konsol, sehingga WebUI dapat menangkap dan menampilkan lognya.

# ================================================
#  Definisi Variabel
# ================================================

# Jalur instalasi modul, disediakan oleh lingkungan Magisk/KernelSU.
MODPATH=/data/adb/modules/azmunaas_toolbox
# Direktori tempat file bendera (flags) disimpan, yang menentukan status fitur.
FLAGS_DIR="$MODPATH/flags"
# Direktori tempat skrip-skrip fitur lainnya berada.
SCRIPTS_DIR="$MODPATH/scripts"
# Jalur lengkap untuk file log khusus `executor.sh`.
LOG_FILE="$MODPATH/executor_log.txt"

# ================================================
#  Pengalihan Output dan Fungsi Logging
# ================================================

# Mengalihkan semua output (stdout dan stderr) dari skrip ini ke file log DAN ke konsol.
# `exec > >(tee -a "$LOG_FILE") 2>&1`:
#   - `exec >(...)`: Mengganti stdout shell saat ini dengan proses di dalam kurung.
#   - `tee -a "$LOG_FILE"`: Perintah `tee` akan membaca dari input standar dan menulisnya
#     ke output standar (konsol) dan juga ke file (`-a` untuk append, bukan menimpa).
#   - `2>&1`: Mengalihkan stderr (file descriptor 2) ke stdout (file descriptor 1).
# Ini memastikan bahwa semua pesan log dari skrip ini akan disimpan ke `$LOG_FILE`
# dan juga dapat ditangkap oleh `module.execute()` di WebUI.
exec > >(tee -a "$LOG_FILE") 2>&1

# Fungsi `log_message` digunakan untuk mencatat pesan status.
# Karena `exec` di atas, pesan ini akan otomatis masuk ke file log dan konsol.
log_message() {
    # Menggunakan `echo` dengan format waktu dan tag spesifik untuk `executor`.
    echo "$(date +%Y-%m-%d\ %H:%M:%S) [EXECUTOR] $1"
}

# ================================================
#  Parsing Argumen dan Logika Aksi
# ================================================

log_message "Executor.sh dipanggil dengan argumen: $@" # Log semua argumen yang diterima

# Ambil aksi (perintah) dan fitur dari argumen yang diberikan ke skrip.
# `$1` adalah argumen pertama, `$2` adalah argumen kedua.
ACTION=$1
FEATURE=$2

# Struktur `case` digunakan untuk menjalankan blok kode yang berbeda berdasarkan nilai `ACTION`.
case "$ACTION" in
    "toggle") # Aksi untuk mengaktifkan atau menonaktifkan fitur toggle (props)
        log_message "Menerima aksi 'toggle' untuk fitur: $FEATURE"
        case "$FEATURE" in
            "xiaomi_15_spoof") # Fitur: Spoof Perangkat Xiaomi 15
                FLAG_FILE="$FLAGS_DIR/xiaomi_15_spoof_enabled"
                if [ -f "$FLAG_FILE" ]; then # Jika file bendera ada, berarti fitur aktif
                    rm "$FLAG_FILE" # Hapus file untuk menonaktifkan fitur
                    log_message "Fitur Xiaomi 15 Spoof dinonaktifkan."
                else # Jika file bendera tidak ada, berarti fitur nonaktif
                    touch "$FLAG_FILE" # Buat file untuk mengaktifkan fitur
                    log_message "Fitur Xiaomi 15 Spoof diaktifkan."
                fi
                log_message "Perhatian: Perubahan pada properti ini memerlukan reboot agar diterapkan sepenuhnya."
                ;;
            "user_build_spoof") # Fitur: Spoof ROM Userdebug ke User
                FLAG_FILE="$FLAGS_DIR/user_build_spoof_enabled"
                if [ -f "$FLAG_FILE" ]; then
                    rm "$FLAG_FILE"
                    log_message "Fitur User Build Spoof dinonaktifkan."
                else
                    touch "$FLAG_FILE"
                    log_message "Fitur User Build Spoof diaktifkan."
                fi
                log_message "Perhatian: Perubahan pada properti ini memerlukan reboot agar diterapkan sepenuhnya."
                ;;
            "pif_spoof_disable") # Fitur: Matikan Spoof PIF Bawaan ROM
                FLAG_FILE="$FLAGS_DIR/pif_spoof_disable_enabled"
                if [ -f "$FLAG_FILE" ]; then
                    rm "$FLAG_FILE"
                    log_message "Fitur Matikan PIF Spoof dinonaktifkan."
                else
                    touch "$FLAG_FILE"
                    log_message "Fitur Matikan PIF Spoof diaktifkan."
                fi
                log_message "Perhatian: Perubahan pada properti ini memerlukan reboot agar diterapkan sepenuhnya."
                ;;
            *)
                log_message "Fitur toggle tidak dikenal: '$FEATURE'." # Pesan error jika fitur tidak dikenali
                exit 1 # Keluar dengan kode error
                ;;
        esac
        ;;
    "execute") # Aksi untuk mengeksekusi skrip fitur lainnya
        log_message "Menerima aksi 'execute' untuk skrip: $FEATURE.sh"
        case "$FEATURE" in
            "install_keybox") # Skrip: Memasang Keybox Valid
                log_message "Menjalankan Skrip: Memasang Keybox Valid..."
                # Eksekusi skrip terkait. Menggunakan `sh` untuk memastikan dieksekusi oleh shell.
                sh "$SCRIPTS_DIR/install_keybox.sh"
                ;;
            "clear_apps_data") # Skrip: Menghapus Data Play Store & Play Services
                log_message "Menjalankan Skrip: Menghapus data aplikasi Play Store dan Play Services..."
                sh "$SCRIPTS_DIR/clear_apps_data.sh"
                ;;
            "kill_apps") # Skrip: Mematikan Play Services & Play Store
                log_message "Menjalankan Skrip: Mematikan aplikasi Google Play Services dan Play Store..."
                sh "$SCRIPTS_DIR/kill_apps.sh"
                ;;
            "replace_charging_sound") # Skrip: Mengganti Suara ChargingStarted.ogg
                log_message "Menjalankan Skrip: Mengganti suara ChargingStarted.ogg..."
                sh "$SCRIPTS_DIR/replace_charging_sound.sh"
                ;;
            *)
                log_message "Skrip eksekusi tidak dikenal: '$FEATURE'." # Pesan error jika skrip tidak dikenali
                exit 1 # Keluar dengan kode error
                ;;
        esac
        ;;
    "get_status") # Aksi untuk mengembalikan status fitur toggle ke WebUI
        log_message "Menerima aksi 'get_status'. Mengirim status fitur toggle..."
        # Mengembalikan status setiap fitur sebagai pasangan key:value (misal: `feature_name:true/false`).
        # `[ -f "$FLAG_FILE" ] && echo "true" || echo "false"` adalah cara shell untuk mengevaluasi
        # kondisi dan mencetak "true" jika file ada, "false" jika tidak.
        echo "xiaomi_15_spoof_enabled:$( [ -f "$FLAGS_DIR/xiaomi_15_spoof_enabled" ] && echo "true" || echo "false" )"
        echo "user_build_spoof_enabled:$( [ -f "$FLAGS_DIR/user_build_spoof_enabled" ] && echo "true" || echo "false" )"
        echo "pif_spoof_disable_enabled:$( [ -f "$FLAGS_DIR/pif_spoof_disable_enabled" ] && echo "true" || echo "false" )"
        ;;
    *)
        log_message "Aksi tidak dikenal: '$ACTION'. Gunakan 'toggle', 'execute', atau 'get_status'." # Pesan error jika aksi tidak dikenali
        exit 1 # Keluar dengan kode error
        ;;
esac

log_message "Executor.sh selesai."
