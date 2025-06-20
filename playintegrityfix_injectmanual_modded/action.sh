MODDIR="/data/adb/modules/playintegrityfix"

set +o standalone
unset ASH_STANDALONE

sh $MODDIR/mod/set_target.sh
sh $MODDIR/mod/set_security_patch.sh
sh $MODDIR/mod/install_keybox.sh
sh $MODDIR/mod/kill_gms_process.sh
echo -e "$(date +%Y-%m-%d\ %H:%M:%S) (⁠*⁠＾⁠3⁠＾⁠)⁠/⁠～⁠♡ Happy Meets Strong Integrity!"
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
