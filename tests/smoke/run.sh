set -e
NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nix-build '<liminix>' -I liminix-config=./configuration.nix --arg device "import <liminix/devices/$DEVICE.nix>" -A outputs.squashfs -o smoke.img $*

TESTS=$(cat <<"EOF"

trap 'echo "command $(eval echo $BASH_COMMAND) failed with exit code $?"; exit $?' ERR
dest_path=${TMPDIR}/smoke.img-$$
echo $dest_path
unsquashfs -q -d $dest_path -excludes smoke.img  /dev
cd $dest_path;
db=nix/store/*-s6-rc-db/compiled/
test -d $db
chmod -R +w $db
# check we have closure of config.services (lo.link.service exists only
# as a dependency)
test "$(s6-rc-db -c $db type lo.link.service)" = "oneshot"
test "$(s6-rc-db -c $db type ntp.service)" = "longrun"
echo OK
EOF
     )


nix-shell -p s6-rc -p squashfsTools --run "$TESTS" || exit 1
