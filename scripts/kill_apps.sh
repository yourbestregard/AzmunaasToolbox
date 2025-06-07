#!/system/bin/sh
# kill_apps.sh (Fitur 6)

log_message() {
    echo "$(date +%Y-%m-%d\ %H:%M:%S) [Kill Apps] $1"
}

log_message "Memulai penghentian paksa aplikasi Google Play Services dan Play Store..."

# Kill Google Play Services (unstable process, might be different based on ROM)
log_message "Menghentikan com.google.android.gms.unstable..."
killall -v com.google.android.gms.unstable

# Kill Google Play Store
log_message "Menghentikan com.android.vending..."
killall -v com.android.vending

log_message "Penghentian paksa aplikasi selesai."
