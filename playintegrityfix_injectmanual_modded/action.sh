MODDIR="/data/adb/modules/playintegrityfix"

set +o standalone
unset ASH_STANDALONE

sh $MODDIR/mod/set_target.sh
sh $MODDIR/mod/set_security_patch.sh
sh $MODDIR/mod/install_keybox.sh
sh $MODDIR/mod/kill_gms_process.sh
echo -e "$(date +%Y-%m-%d\ %H:%M:%S) (⁠*⁠＾⁠3⁠＾⁠)⁠/⁠～⁠♡ Happy Meets Strong Integrity!"
echo -e "$(date +%Y-%m-%d\ %H:%M:%S) Are you not pass strong integrity? try changing the spoof settings (without reboot) in /data/adb/pif.json or use WebUI to do it"
echo -e "$(date +%Y-%m-%d\ %H:%M:%S) 1) Spoof Props: True, Spoof Provider: True, Spoof Signature: False, Spoof Vending Sdk: False."
echo -e "$(date +%Y-%m-%d\ %H:%M:%S) 2) Spoof Props: True, Spoof Provider: True, Spoof Signature: True, Spoof Vending Sdk: False."
echo -e "$(date +%Y-%m-%d\ %H:%M:%S) 3) Spoof Props: True, Spoof Provider: True, Spoof Signature: True, Spoof Vending Sdk: True."
echo -e "$(date +%Y-%m-%d\ %H:%M:%S) 4) Spoof Props: False, Spoof Provider: False, Spoof Signature: False, Spoof Vending Sdk: False."
sleep 1
if [ -z "$MMRL" ] && [ ! -z "$MAGISKTMP" ]; then
    pm path io.github.a13e300.ksuwebui > /dev/null 2>&1 && {
        echo -e "$(date +%Y-%m-%d\ %H:%M:%S) Launching WebUI in KSUWebUIStandalone.."
        am start -n "io.github.a13e300.ksuwebui/.WebUIActivity" -e id "playintegrityfix"
        exit 0
    }
    pm path com.dergoogler.mmrl.wx > /dev/null 2>&1 && {
        echo -e "$(date +%Y-%m-%d\ %H:%M:%S) Launching WebUI in WebUI X.."
        am start -n "com.dergoogler.mmrl.wx/.ui.activity.webui.WebUIActivity" -e MOD_ID "playintegrityfix"
        exit 0
    }
fi

sh $MODDIR/autopif_ota.sh || true
sh $MODDIR/autopif.sh -p
sh $MODDIR/mod/redirect.sh
