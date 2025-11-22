MODPATH="${0%/*}"

# ensure not running in busybox ash standalone shell
set +o standalone
unset ASH_STANDALONE

sh $MODPATH/mod/set_target.sh 2>&1
sh $MODPATH/mod/install_keybox.sh 2>&1
sh $MODPATH/autopif2.sh -m || exit 1

echo -e "$(date +%Y-%m-%d\ %H:%M:%S) Closing dialog in 5 seconds.."
echo -e "$(date +%Y-%m-%d\ %H:%M:%S) (⁠*⁠＾⁠3⁠＾⁠)⁠/⁠～⁠♡ Happy Meets Strong Integrity!"
echo -e "$(date +%Y-%m-%d\ %H:%M:%S) Are you not pass strong integrity? try changing the spoof settings in /data/adb/modules/playintegrityfix/custom.pif.json"

# warn since KernelSU/APatch's implementation automatically closes if successful
if [ "$KSU" = "true" -o "$APATCH" = "true" ] && [ "$KSU_NEXT" != "true" ] && [ "$WKSU" != "true" ] && [ "$MMRL" != "true" ]; then
    sleep 20
fi
