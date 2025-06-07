#!/system/bin/sh
# clear_apps_data.sh (Fitur 5)

log_message() {
    echo "$(date +%Y-%m-%d\ %H:%M:%S) [Clear Data] $1"
}

log_message "Memulai penghapusan data aplikasi Play Store dan Play Services..."

# Clear Google Play Store data
log_message "Menghapus data Google Play Store (com.android.vending)..."
pm clear com.android.vending

# Clear Google Play Services data
log_message "Menghapus data Google Play Services (com.google.android.gms)..."
pm clear com.google.android.gms

log_message "Penghapusan data aplikasi selesai."
