#!/system/bin/sh
# executor.sh

MODPATH=/data/adb/modules/azmunaas_toolbox
FLAGS_DIR="$MODPATH/flags"
SCRIPTS_DIR="$MODPATH/scripts"
LOG_FILE="$MODPATH/executor_log.txt"

# Redirect all output to log file and stdout/stderr
exec > >(tee -a "$LOG_FILE") 2>&1

log_message() {
    echo "$(date +%Y-%m-%d\ %H:%M:%S) [EXECUTOR] $1"
}

log_message "Executor.sh dipanggil dengan argumen: $@"

ACTION=$1
FEATURE=$2

case "$ACTION" in
    "toggle")
        case "$FEATURE" in
            "xiaomi_15_spoof")
                FLAG_FILE="$FLAGS_DIR/xiaomi_15_spoof_enabled"
                if [ -f "$FLAG_FILE" ]; then
                    rm "$FLAG_FILE"
                    log_message "Fitur Xiaomi 15 Spoof dinonaktifkan."
                else
                    touch "$FLAG_FILE"
                    log_message "Fitur Xiaomi 15 Spoof diaktifkan."
                fi
                log_message "Perhatian: Fitur ini memerlukan reboot agar perubahan dapat diterapkan."
                ;;
            "user_build_spoof")
                FLAG_FILE="$FLAGS_DIR/user_build_spoof_enabled"
                if [ -f "$FLAG_FILE" ]; then
                    rm "$FLAG_FILE"
                    log_message "Fitur User Build Spoof dinonaktifkan."
                else
                    touch "$FLAG_FILE"
                    log_message "Fitur User Build Spoof diaktifkan."
                fi
                log_message "Perhatian: Fitur ini memerlukan reboot agar perubahan dapat diterapkan."
                ;;
            "pif_spoof_disable")
                FLAG_FILE="$FLAGS_DIR/pif_spoof_disable_enabled"
                if [ -f "$FLAG_FILE" ]; then
                    rm "$FLAG_FILE"
                    log_message "Fitur Matikan PIF Spoof dinonaktifkan."
                else
                    touch "$FLAG_FILE"
                    log_message "Fitur Matikan PIF Spoof diaktifkan."
                fi
                log_message "Perhatian: Fitur ini memerlukan reboot agar perubahan dapat diterapkan."
                ;;
            *)
                log_message "Fitur toggle tidak dikenal: $FEATURE"
                exit 1
                ;;
        esac
        ;; 
    "execute")
        case "$FEATURE" in
            "install_keybox")
                log_message "Menjalankan Fitur: Memasang Keybox Valid..."
                sh "$SCRIPTS_DIR/install_keybox.sh"
                ;;
            "clear_apps_data")
                log_message "Menjalankan Fitur: Menghapus data aplikasi Play Store dan Play Services..."
                sh "$SCRIPTS_DIR/clear_apps_data.sh"
                ;;
            "kill_apps")
                log_message "Menjalankan Fitur: Mematikan aplikasi Google Play Services dan Play Store..."
                sh "$SCRIPTS_DIR/kill_apps.sh"
                ;;
            "replace_charging_sound")
                log_message "Menjalankan Fitur: Mengganti suara ChargingStarted.ogg..."
                sh "$SCRIPTS_DIR/replace_charging_sound.sh"
                ;;
            *)
                log_message "Fitur eksekusi tidak dikenal: $FEATURE"
                exit 1
                ;;
        esac
        ;; 
    "get_status")
        # Return status of toggle features for WebUI
        echo "xiaomi_15_spoof_enabled:$( [ -f "$FLAGS_DIR/xiaomi_15_spoof_enabled" ] && echo "true" || echo "false" )"
        echo "user_build_spoof_enabled:$( [ -f "$FLAGS_DIR/user_build_spoof_enabled" ] && echo "true" || echo "false" )"
        echo "pif_spoof_disable_enabled:$( [ -f "$FLAGS_DIR/pif_spoof_disable_enabled" ] && echo "true" || echo "false" )"
        ;; 
    *)
        log_message "Aksi tidak dikenal: $ACTION. Gunakan 'toggle', 'execute', atau 'get_status'."
        exit 1
        ;;
esac

log_message "Executor.sh selesai."
