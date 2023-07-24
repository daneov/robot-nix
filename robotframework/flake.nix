{
  description = "Robotframework 6.1";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, mach-nix }:
    flake-utils.lib.eachDefaultSystem (system:
    let 
        pkgs = nixpkgs.legacyPackages.${system};
        python = pkgs.python310;

        robotframework = python.pkgs.buildPythonApplication rec {
          pname = "robotframework";
          version = "6.1";
          format = "setuptools";

          src = (fetchTarball {
            url = "https://github.com/robotframework/${pname}/archive/refs/tags/v${version}.tar.gz";
            sha256 = "sha256:0q9m6p9n2vqmk2vixi66fy3yjxanh8yv28lkm0b6brx22aj6wmcp";
          });

          meta = with nixpkgs.lib; {
            license = nixpkgs.lib.licenses.asl20;
          };
        };
    in {
        packages.robotframework = robotframework;
        packages.${system}.default = robotframework;
    }
  );
}
