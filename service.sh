#!/system/bin/sh
# service.sh
#
# Skrip ini dijalankan lebih lambat dalam proses boot Android dibandingkan `post-fs-data.sh`.
# Ini dieksekusi setelah sebagian besar layanan sistem Android dimulai, membuatnya cocok untuk:
#   - Modifikasi yang membutuhkan layanan sistem yang sudah berjalan penuh.
#   - Tugas yang tidak bisa dilakukan di tahap `post-fs-data` karena keterbatasan waktu atau lingkungan.
# Pada modul Azmunaa's Toolbox, skrip ini sebelumnya digunakan untuk memulai server web `busybox httpd`
# untuk WebUI lama. Dengan adopsi WebUI X, server web kini ditangani langsung oleh KernelSU,
# sehingga skrip ini sekarang lebih minimalis dan berfokus pada logging.

# Define MODPATH (jalur instalasi modul) yang disediakan oleh Magisk/KernelSU.
# Ini adalah jalur absolut ke direktori tempat modul diinstal (`/data/adb/modules/<module_id>`).
MODPATH=/data/adb/modules/azmunaas_toolbox
# Tentukan tag log untuk pesan logcat, membantu identifikasi sumber pesan.
LOG_TAG="AzmunaasToolbox"

# ================================================
#  Fungsi Logging
# ================================================

# Fungsi `log_message` digunakan untuk mencatat pesan ke logcat Android.
# Ini membantu dalam debugging dan pemantauan eksekusi skrip selama boot.
log_message() {
    # Menggunakan perintah `log -t` untuk menulis pesan ke logcat dengan tag spesifik.
    log -t "$LOG_TAG" "$1"
}

# ================================================
#  Logika Utama Skrip
# ================================================

log_message "Memulai eksekusi service.sh..."

# Informasi Penting Mengenai WebUI:
# Server WebUI sebelumnya (menggunakan busybox httpd) telah dihapus dari skrip ini.
# KernelSU sekarang secara otomatis akan melayani antarmuka WebUI X dari direktori `webroot` modul.
# Oleh karena itu, tidak ada lagi proses server web yang perlu dimulai secara manual di sini.
log_message "Server WebUI sekarang dikelola oleh KernelSU WebUI X. service.sh tidak lagi memulai httpd."

log_message "Eksekusi service.sh selesai."
