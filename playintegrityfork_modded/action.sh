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
sleep 1
sh $MODPATH/mod/redirect.sh
sleep 19
