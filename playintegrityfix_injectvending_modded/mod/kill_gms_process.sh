#!/system/bin/sh

log_message() {
    echo "$(date +%Y-%m-%d\ %H:%M:%S) [KILL_GMS_PROCESS] $1"
}
log_message “Start killing process.”
killall -v com.google.android.gms.unstable;
killall -v com.android.vending;
log_message “Finish killing process.”