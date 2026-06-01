MODDIR="/data/adb/modules/oh_my_keymint"

su -c "sh $MODDIR/mod/set_scope.sh 2>&1"
su -c "sh $MODDIR/mod/install_keybox.sh 2>&1"
su -c "sh $MODDIR/mod/restart_omk.sh 2>&1"
su -c "sh $MODDIR/mod/kill_gms_process.sh 2>&1"
# su -c "sh $MODDIR/mod/update_checker.sh 2>&1"

echo -e "$(date +%Y-%m-%d\ %H:%M:%S) Closing dialog in 5 seconds.."
echo -e "$(date +%Y-%m-%d\ %H:%M:%S) (⁠*⁠＾⁠3⁠＾⁠)⁠/⁠～⁠♡ Happy Meets Strong Integrity!"
echo -e "$(date +%Y-%m-%d\ %H:%M:%S) Did you fail the integrity test? Try clicking the action button again and see the results. Thank you for using this module! <3"
sleep 5
su -c "sh $MODDIR/mod/redirect.sh 2>&1"

