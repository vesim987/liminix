{
  stdenv
, squashfsTools
, closureInfo
, busybox
, buildPackages
, callPackage
, pseudofile
, runCommand
, writeText
} : filesystem :
let
  pseudofiles = pseudofile.write "files.pf" filesystem;

  storefs = stdenv.mkDerivation {
    name = "squashfs.img";

    nativeBuildInputs = [ buildPackages.squashfsTools ];

    buildCommand =
      ''
        closureInfo=${closureInfo { rootPaths = pseudofiles; }}

        # Also include a manifest of the closures in a format suitable
        # for nix-store --load-db.
        cp $closureInfo/registration nix-path-registration

        # 64 cores on i686 does not work
        # fails with FATAL ERROR: mangle2:: xz compress failed with error code 5
        if ((NIX_BUILD_CORES > 48)); then
          NIX_BUILD_CORES=48
        fi

        # Generate the squashfs image.
        mksquashfs nix-path-registration $(cat $closureInfo/store-paths) $out \
          -no-hardlinks -keep-as-directory -all-root -b 1048576 -comp xz -Xdict-size 100% \
          -processors $NIX_BUILD_CORES
      '';
  };
  in runCommand "frob-squashfs" {
      nativeBuildInputs = with buildPackages; [ squashfsTools qprint ];
  } ''
    echo ${pseudofiles}
    cp ${storefs} ./store.img
    chmod +w store.img
    mksquashfs - store.img -exit-on-error -no-recovery -quiet -no-progress  -root-becomes store -p "/ d 0755 0 0"
    mksquashfs - store.img -exit-on-error -no-recovery -quiet -no-progress  -root-becomes nix  -p "/ d 0755 0 0" -pf ${pseudofiles}
    cp store.img $out
''
