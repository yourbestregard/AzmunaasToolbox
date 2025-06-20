log_message() {
    echo "$(date +%Y-%m-%d\ %H:%M:%S) [REDIRECT] $1"
}
log_message “Opening author page...”
nohup am start -a android.intent.action.VIEW -d https://t.me/azmunaashome >/dev/null 2>&1 &
log_message “Program completed.”
