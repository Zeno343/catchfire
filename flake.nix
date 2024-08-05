{
  description = "Gfx with Zig";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs @ { self, nixpkgs }: {
    packages."x86_64-linux".default = with nixpkgs.legacyPackages."x86_64-linux"; stdenv.mkDerivation {
      name = "catchfire";
      version = "v0.1";
      src = lib.cleanSource ./.;
      buildInputs = [ SDL2 ];
      nativeBuildInputs = [ zig pkg-config emscripten wabt python3 ];

      EMSCRIPTEN_SYSROOT = "${emscripten}/share/emscripten/cache/sysroot";
      buildPhase = ''
        zig build --global-cache-dir $(mktemp -d) -p $out
      '';
    };
  };
}
