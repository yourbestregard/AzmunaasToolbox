MODDIR="/data/adb/modules/playintegrityfix"

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

sh $MODDIR/mod/set_target.sh
sh $MODDIR/mod/set_security_patch.sh
sh $MODDIR/mod/install_keybox.sh
sh $MODDIR/mod/kill_gms_process.sh
sh $MODDIR/autopif_ota.sh || true
sh $MODDIR/autopif.sh

echo -e "$(date +%Y-%m-%d\ %H:%M:%S) Closing dialog in 5 seconds.."
echo -e "$(date +%Y-%m-%d\ %H:%M:%S) (⁠*⁠＾⁠3⁠＾⁠)⁠/⁠～⁠♡ Happy Meets Strong Integrity!"
echo -e "$(date +%Y-%m-%d\ %H:%M:%S) Are you not pass strong integrity? try changing the spoof settings (without reboot) in /data/adb/pif.prop or via WebUI"
echo -e "$(date +%Y-%m-%d\ %H:%M:%S) 1) Spoof Build: True, Spoof Props: True, Spoof Provider: False, Spoof Signature: False, spoofVendingBuild: False, Spoof Vending Sdk: False, DEBUG=false."
echo -e "$(date +%Y-%m-%d\ %H:%M:%S) 1) Spoof Build: True, Spoof Props: True, Spoof Provider: False, Spoof Signature: False, spoofVendingBuild: True, Spoof Vending Sdk: False, DEBUG=false."
echo -e "$(date +%Y-%m-%d\ %H:%M:%S) 1) Spoof Build: True, Spoof Props: True, Spoof Provider: True, Spoof Signature: False, spoofVendingBuild: True, Spoof Vending Sdk: False, DEBUG=false."
echo -e "$(date +%Y-%m-%d\ %H:%M:%S) 1) Spoof Build: True, Spoof Props: True, Spoof Provider: True, Spoof Signature: True, spoofVendingBuild: True, Spoof Vending Sdk: False, DEBUG=false."
echo -e "$(date +%Y-%m-%d\ %H:%M:%S) 1) Spoof Build: True, Spoof Props: True, Spoof Provider: True, Spoof Signature: True, spoofVendingBuild: True, Spoof Vending Sdk: True, DEBUG=false."
sleep 5
sh $MODDIR/mod/redirect.sh

