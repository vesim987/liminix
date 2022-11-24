{
  inputs = { nixpkgs.url = "github:nixos/nixpkgs"; };

  outputs = { self, nixpkgs }: {
      packages.x86_64-linux.default = (import ./default.nix {
        nixpkgs_ = nixpkgs;
        liminix-config = ./tests/wlan/configuration.nix;
        device_file = ./devices/qemu/default.nix;
      }).outputs.kernel;
   };
}
