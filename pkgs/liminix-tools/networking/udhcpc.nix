{
  liminix
, busybox
, writeShellScript
} :
let
  inherit (liminix.services) longrun;
  script = writeShellScript "udhcp-notify" ''
action=$1
env > /run/udhcp.values

set_address() {
    ip address replace $ip/$mask dev $interface
    mkdir -p data/outputs
    for i in lease mask ip router siaddr dns serverid subnet opt53 interface ; do
        echo ''${!i} > data/outputs/$i
    done
}
case $action in
  deconfig)
    ip address flush $interface
    ip link set up dev $interface
    ;;
  bound)
    # this doesn't actually replace, it adds a new address.
    set_address
    ;;
  renew)
    set_address
    ;;
  nak)
    echo "received NAK on $interface"
    ;;
esac
'';

in
interface: { ... } @ args: longrun {
  name = "${interface.device}.udhcp";
  run = "${busybox}/bin/udhcpc -f -i ${interface.device} -s ${script}";
}

# lease=86400
# mask=24
# ip=10.0.2.15
# router=10.0.2.2
# siaddr=10.0.2.2
# dns=10.0.2.3
# serverid=10.0.2.2
# subnet=255.255.255.0
# SHLVL=2
# opt53=05
# interface=eth0
# PATH=/nix/store/npy692wik809z3vdwrkrj2wixjkr33kp-busybox-mips-unknown-linux-musl-1.35.0/bin:/nix/store/
# pj0b27l5728cypa5mmagz0q8ibzpik0h-execline-mips-unknown-linux-musl-2.9.0.1-bin/bin:/nix/store/rfjiw4dnv29daqc9971qmica1h86l0s0-s6-linux-init-mips-unknown-linux-musl-1.0.8.0-bin/bin:/nix/store/4wn3jm7yy2gfi0is0yy75lifbq5zjwz7-s6-rc-mips-unknown-linux-musl-0.5.3.2-bin/bin:/usr/bin:/bin
# _=/nix/store/npy692wik809z3vdwrkrj2wixjkr33kp-busybox-mips-unknown-linux-musl-1.35.0/bin/env
# /