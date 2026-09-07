{
    inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    outputs =
        { self, nixpkgs }:
        let
            mkTheme =
                {
                    black ? "#412853",
                    red ? "#f08533",
                    magenta ? "#9768b6",
                    l_red ? "#d07271",
                    l_green ? "#9fd356",
                    l_white ? "#ece3d5",
                }:

                # TODO: add dynamic color support

                nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (
                    system:
                    let
                        pkgs = nixpkgs.legacyPackages.${system};
                    in
                    pkgs.stdenv.mkDerivation {
                        pname = "qogir-theme-fork";
                        version = "2026-09-06";
                        src = ./.;

                        nativeBuildInputs = [
                            pkgs.sassc
                            pkgs.which
                        ];

                        propagatedBuildInputs = [
                            pkgs.gtk_engines
                            pkgs.gtk-engine-murrine
                        ];

                        buildPhase = ''
                            patchShebangs .
                            ./parse-sass.sh
                            cd release
                            ./make-release.sh
                            cd ..
                        '';

                        installPhase = ''
                            mkdir -p $out/share/themes
                            cp -r release/$name-Dark $out/share/themes/Qogir-Dark
                            cp -r release/$name-Light $out/share/themes/Qogir-Light
                            cp -r release/$name $out/share/themes/Qogir
                            sed -i "s/$name/Qogir/g" $out/share/themes/*/index.theme
                        '';
                    }
                );

        in

        {
            lib.mkTheme = mkTheme;

            packages = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (system: {
                default = (mkTheme { }).${system};
            });
        };
}
