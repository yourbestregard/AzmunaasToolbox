#!/system/bin/sh
# clear_apps_data.sh
#
# Skrip ini bertanggung jawab untuk menghapus data pengguna (cache dan data aplikasi)
# dari Google Play Store dan Google Play Services. Tindakan ini seringkali diperlukan
# untuk mengatasi masalah terkait Play Integrity, akun Google, atau pembaharuan aplikasi yang bermasalah.
# Menghapus data akan memaksa aplikasi untuk memulai dari 'bersih' seolah-olah baru diinstal.

# ================================================
#  Fungsi Logging
# ================================================

# Fungsi `log_message` digunakan untuk mencatat pesan status ke stdout.
# Pesan ini akan ditangkap oleh `executor.sh` dan kemudian ditampilkan di WebUI.
log_message() {
    # Menggunakan `echo` dengan format waktu dan tag spesifik untuk operasi penghapusan data.
    echo "$(date +%Y-%m-%d\ %H:%M:%S) [Clear Data] $1"
}

# ================================================
#  Logika Utama Skrip
# ================================================

log_message "Memulai penghapusan data aplikasi Play Store dan Play Services..."

# --- Menghapus Data Google Play Store ---
# Google Play Store memiliki package name `com.android.vending`.
log_message "Menghapus data Google Play Store (com.android.vending)..."
# Perintah `pm clear <package_name>` digunakan untuk menghapus semua data pengguna
# dari aplikasi yang ditentukan, termasuk cache dan data pengguna.
pm clear com.android.vending

# --- Menghapus Data Google Play Services ---
# Google Play Services memiliki package name `com.google.android.gms`.
log_message "Menghapus data Google Play Services (com.google.android.gms)..."
# Menghapus data Google Play Services juga akan mempengaruhi banyak aplikasi lain
# yang bergantung padanya, dan mungkin memerlukan beberapa waktu untuk sistem
# membangun kembali cache dan datanya.
pm clear com.google.android.gms

log_message "Penghapusan data aplikasi selesai."
