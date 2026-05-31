#!/system/bin/sh

log_message() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') [RESTART_OMK] $1"
}
log_message "Start restarting OhMyKeymint."
touch /data/adb/omk/restart.keymint
touch /data/adb/omk/restart.injector
touch /data/adb/omk/restart.all
log_message "Finish restarting OhMyKeymint."