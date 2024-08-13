{
  description = "Gfx with Zig";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs @ { self, nixpkgs }: {
    packages."x86_64-linux" = with nixpkgs.legacyPackages."x86_64-linux"; rec {
    default = catchfire;

    catchfire = stdenv.mkDerivation rec {
        name = "catchfire";
        version = "v0.1";
        src = lib.cleanSource ./.;
  
        buildInputs = [ SDL2 ];
        nativeBuildInputs = [ zig pkg-config emscripten ];
	
	SDL2_2_28_4 = fetchFromGitHub {
	  owner = "libsdl-org";
	  repo = "SDL";
	  rev = "release-2.28.4";
	  hash = "sha256-1+1m0s3pBCTu924J/4aIu4IHk/N88x2djWDEsDpAJn4=";  
	};

        buildPhase = ''
	  export HOME=$(mktemp -d)
	  export EM_CACHE=$(mktemp -d)
	  export EMCC_LOCAL_PORTS="sdl2=${SDL2_2_28_4}";
	  mkdir zig-out
	  zig build web
        '';
  
        installPhase = ''
          cp -r zig-out/bin $out
        '';
      };
    };
  };
}
