{
  description = "GDRETools gdsdecomp game asset decompiler";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default-linux";
  };

  outputs = { self, nixpkgs, systems, ... }:
    let
      eachSystem = nixpkgs.lib.genAttrs (import systems);
    in {
      packages = eachSystem (system:
        let
          pkgs = import nixpkgs { inherit system; };
          
          runtimeLibs = with pkgs; [
            stdenv.cc.cc.lib
            libx11
            libxcursor
            libxrandr
            libxi
            libxinerama
            libxext
            libxrender
            wayland
            libGL
            zlib
          ];
        in {
          default = pkgs.stdenv.mkDerivation rec {
            pname = "gdsdecomp";
            version = "2.6.4";

            src = pkgs.fetchurl {
              url = "https://github.com/GDRETools/gdsdecomp/releases/download/v${version}/GDRE_tools-v${version}-linux.zip";
              sha256 = "sha256-7ajLCeZKBgco+jcaqArhSNPFWEp94vVTaZk22qhOe04=";
            };

            dontUnpack = true;

            nativeBuildInputs = with pkgs; [ 
              unzip 
              makeWrapper 
              copyDesktopItems
            ];

            desktopItems = [
              (pkgs.makeDesktopItem {
                name = "gdsdecomp";
                exec = "gdsdecomp";
                icon = "gdsdecomp";
                desktopName = "GDRETools gdsdecomp";
                comment = "Godot Engine game asset decompiler";
                categories = [ "Development" "Utility" ];
              })
            ];

            installPhase = ''
              runHook preInstall
              
              mkdir -p $out/bin $out/libexec/gdsdecomp
              
              unzip $src -d $out/libexec/gdsdecomp/
              chmod +x $out/libexec/gdsdecomp/gdre_tools.x86_64
              
              makeWrapper $out/libexec/gdsdecomp/gdre_tools.x86_64 $out/bin/gdsdecomp \
                --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath runtimeLibs}" \
                --add-flags "--main-pack $out/libexec/gdsdecomp/gdre_tools.pck"
              
              runHook postInstall
            '';

            meta.mainProgram = "gdsdecomp";
          };
        });
    };
}