{
  description = "Gfx with Zig";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    with nixpkgs.legacyPackages."x86_64-linux";
    let
      catchfire = stdenv.mkDerivation {
        name = "catchfire";
        version = "v24.11.07";
        src = lib.cleanSource ./.;

        buildInputs = [ SDL2 ];
        nativeBuildInputs = [
          zig
          pkg-config
        ];

        buildPhase = ''
          export HOME=$(mktemp -d)
          	    
          zig build native -p $out
        '';
      };

      # emscripten wasm build
      catchfireWeb = stdenv.mkDerivation rec {
        name = "catchfireWeb";
        version = "v24.11.07";
        src = lib.cleanSource ./.;

        nativeBuildInputs = [
          zig
          pkg-config
          emscripten
        ];

        SDL2 = fetchFromGitHub {
          owner = "libsdl-org";
          repo = "SDL";
          rev = "release-2.28.4";
          hash = "sha256-1+1m0s3pBCTu924J/4aIu4IHk/N88x2djWDEsDpAJn4=";
        };

        buildPhase = ''
          export HOME=$(mktemp -d)
          export EMCC_LOCAL_PORTS="sdl2=${SDL2}"

          mkdir -p $out/web
          zig build web -p $out
        '';
      };

      webServer = writeShellApplication {
        name = "webServer";
        runtimeInputs = [
          catchfireWeb
          emscripten
        ];
        text = ''
          emrun ${catchfireWeb}/web/index.html
        '';
      };
    in
    {
      packages."x86_64-linux" = {
        default = catchfire;
        inherit catchfireWeb;
        inherit webServer;
      };

      devShells."x86_64-linux".default = mkShell {
        inputsFrom = [
          catchfire
          catchfireWeb
        ];
      };
    };
}
