#!/system/bin/sh
# kill_apps.sh
#
# Skrip ini bertujuan untuk menghentikan paksa (force stop) aplikasi Google Play Services
# dan Google Play Store. Tindakan ini seringkali berguna untuk mengatasi masalah terkait
# background activity, error Play Integrity, atau untuk memaksa aplikasi memuat ulang keadaannya.
# Perintah `killall` digunakan untuk menghentikan semua proses yang terkait dengan nama paket aplikasi.

# ================================================
#  Fungsi Logging
# ================================================

# Fungsi `log_message` digunakan untuk mencatat pesan status ke stdout.
# Pesan ini akan ditangkap oleh `executor.sh` dan kemudian ditampilkan di WebUI.
log_message() {
    # Menggunakan `echo` dengan format waktu dan tag spesifik untuk operasi penghentian aplikasi.
    echo "$(date +%Y-%m-%d\ %H:%M:%S) [Kill Apps] $1"
}

# ================================================
#  Logika Utama Skrip
# ================================================

log_message "Memulai penghentian paksa aplikasi Google Play Services dan Play Store..."

# --- Menghentikan Google Play Services ---
# Package name untuk Google Play Services adalah `com.google.android.gms`.
# Namun, ada beberapa proses yang terkait dengan GMS, termasuk `com.google.android.gms.unstable`
# yang seringkali merupakan proses utama atau yang menyebabkan masalah.
log_message "Menghentikan com.google.android.gms.unstable..."
# Perintah `killall -v` akan menghentikan proses berdasarkan nama dan menampilkan pesan verbose.
# Menghentikan GMS dapat mempengaruhi banyak fungsi sistem yang bergantung padanya.
killall -v com.google.android.gms.unstable

# --- Menghentikan Google Play Store ---
# Package name untuk Google Play Store adalah `com.android.vending`.
log_message "Menghentikan com.android.vending..."
killall -v com.android.vending

log_message "Penghentian paksa aplikasi selesai."
