MODDIR="/data/adb/modules/playintegrityfix"

su -c "sh $MODDIR/mod/set_target.sh 2>&1"
su -c "sh $MODDIR/mod/install_keybox.sh 2>&1"
su -c "sh $MODDIR/mod/kill_gms_process.sh 2>&1"
su -c "sh $MODDIR/mod/update_checker.sh 2>&1"

echo -e "$(date +%Y-%m-%d\ %H:%M:%S) Closing dialog in 5 seconds.."
echo -e "$(date +%Y-%m-%d\ %H:%M:%S) (⁠*⁠＾⁠3⁠＾⁠)⁠/⁠～⁠♡ Happy Meets Strong Integrity!"
echo -e "$(date +%Y-%m-%d\ %H:%M:%S) Are you not pass strong integrity? try changing the spoof settings (without reboot) in /data/adb/pif.prop or via WebUI"
echo -e "$(date +%Y-%m-%d\ %H:%M:%S) 1) spoofBuild = true, spoofProps = true, spoofProvider = false, spoofSignature = false, spoofVendingBuild = false, spoofVendingSdk = false, DEBUG = false."
echo -e "$(date +%Y-%m-%d\ %H:%M:%S) 2) spoofBuild = true, spoofProps = true, spoofProvider = false, spoofSignature = false, spoofVendingBuild = true, spoofVendingSdk = false, DEBUG = false."
echo -e "$(date +%Y-%m-%d\ %H:%M:%S) 3) spoofBuild = true, spoofProps = true, spoofProvider = false, spoofSignature = true, spoofVendingBuild = true, spoofVendingSdk = false, DEBUG = false."
echo -e "$(date +%Y-%m-%d\ %H:%M:%S) 4) spoofBuild = true, spoofProps = true, spoofProvider = true, spoofSignature = false, spoofVendingBuild = true, spoofVendingSdk = false, DEBUG = false."
echo -e "$(date +%Y-%m-%d\ %H:%M:%S) 5) spoofBuild = true, spoofProps = true, spoofProvider = true, spoofSignature = true, spoofVendingBuild = true, spoofVendingSdk = false, DEBUG = false."
echo -e "$(date +%Y-%m-%d\ %H:%M:%S) 6) spoofBuild = true, spoofProps = true, spoofProvider = true, spoofSignature = true, spoofVendingBuild = true, spoofVendingSdk = true, DEBUG = false."
sleep 5
su -c "sh $MODDIR/mod/redirect.sh 2>&1"

if [ -z "$MMRL" ] && [ ! -z "$MAGISKTMP" ]; then
    pm path io.github.a13e300.ksuwebui > /dev/null 2>&1 && {
        echo "- Launching WebUI in KSUWebUIStandalone..."
        am start -n "io.github.a13e300.ksuwebui/.WebUIActivity" -e id "playintegrityfix"
        exit 0
    }
    pm path com.dergoogler.mmrl.wx > /dev/null 2>&1 && {
        echo "- Launching WebUI in WebUI X..."
        am start -n "com.dergoogler.mmrl.wx/.ui.activity.webui.WebUIActivity" -e MOD_ID "playintegrityfix"
        exit 0
    }
fi

sh $MODDIR/autopif_ota.sh || true
sh $MODDIR/autopif.sh
