{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      version = "0.4";

      catchfire =
        with pkgs;
        stdenv.mkDerivation {
          name = "catchfire";
          inherit version;

          src = ./.;

          buildInputs = [
            sdl3
          ];

          nativeBuildInputs = [
            zig
            pkg-config
            libGL

	    glslang
	    renderdoc
          ];

	  shellHook = ''
	    export ZIG_GLOBAL_CACHE_DIR=$(mktemp -d)
	  '';
        };
    in
    {
      packages.${system} = {
        default = catchfire;
      };
    };
}
