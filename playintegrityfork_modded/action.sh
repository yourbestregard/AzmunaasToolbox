MODPATH="${0%/*}"

# ensure not running in busybox ash standalone shell
set +o standalone
unset ASH_STANDALONE

sh $MODPATH/mod/set_target.sh
sh $MODPATH/mod/set_security_patch.sh
sh $MODPATH/mod/install_keybox.sh
sh $MODPATH/mod/kill_gms_process.sh
sh $MODPATH/autopif2.sh -a -m -p || exit 1

echo -e "$(date +%Y-%m-%d\ %H:%M:%S) Closing dialog in 20 seconds.."
echo -e "$(date +%Y-%m-%d\ %H:%M:%S) (⁠*⁠＾⁠3⁠＾⁠)⁠/⁠～⁠♡ Happy Meets Strong Integrity!"
echo -e "$(date +%Y-%m-%d\ %H:%M:%S) Are you not pass strong integrity? try changing the spoof settings (without reboot) in /data/adb/modules/playintegrityfix/custom.pif.json"
echo -e "$(date +%Y-%m-%d\ %H:%M:%S) True = 1, False = 0"
echo -e "$(date +%Y-%m-%d\ %H:%M:%S) 1) Spoof Build: True, Spoof Props: True, Spoof Provider: True, Spoof Signature: False, Spoof Vending Sdk: False."
echo -e "$(date +%Y-%m-%d\ %H:%M:%S) 2) Spoof Build: True, Spoof Props: True, Spoof Provider: True, Spoof Signature: True, Spoof Vending Sdk: False."
echo -e "$(date +%Y-%m-%d\ %H:%M:%S) 3) Spoof Build: True, Spoof Props: True, Spoof Provider: True, Spoof Signature: True, Spoof Vending Sdk: True."
echo -e "$(date +%Y-%m-%d\ %H:%M:%S) 4) Spoof Build: False, Spoof Props: False, Spoof Provider: False, Spoof Signature: False, Spoof Vending Sdk: False."
sleep 1
sh $MODPATH/mod/redirect.sh
sleep 19