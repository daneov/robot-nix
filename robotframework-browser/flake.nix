{
  description = "Robotframework Browser Library";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    # flake-utils.url = "github:numtide/flake-utils";
    robotframework.url = "path:../robotframework";
  };

  outputs = { self, nixpkgs, robotframework }:
    let
        system = "x86_64-linux";
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;
        python = pkgs.python310;

        robotframework-pythonlibcore = python.pkgs.robotframework-pythonlibcore.overridePythonAttrs(old: rec {
          pname = "robotframework-pythonlibcore";
          version = "4.2.0";

          src = python.pkgs.fetchPypi {
            inherit pname version;
            hash = "sha256-9G2KSyH/oV+QcUgXOjQL/3D9v9vRYJebj5DWhuQPsa4=";
          };

          propagatedBuildInputs = [
            robotframework.packages.${system}.robotframework
          ];
          doCheck = false;
        });

        protobuf = pkgs.protobuf.overrideAttrs(old: rec {
          pname = "protobuf";
          version = "4.23.4";
          sha256 = "sha256-eI+mrsZAOLEsdyTC3B+K+GjD3r16CmPx1KJ2KhCwFdg=";

          src = pkgs.fetchFromGitHub {
            inherit version;
            owner = "protocolbuffers";
            repo = "protobuf";
            rev = "v${version}";
            inherit sha256;
          };

          buildInputs = [
            pkgs.abseil-cpp
            pkgs.zlib
          ];

          cmakeFlags = [
            "-Dprotobuf_ABSL_PROVIDER=package"
            "-Dprotobuf_BUILD_SHARED_LIBS=ON"
            "-Dprotobuf_BUILD_TESTS=OFF"
          ];

          patches = [];
          cmakeDir = "..";
          postFixup = ''
            touch $out/bin/daneo
            '';
        });

        protobuf-python = python.pkgs.protobuf.overridePythonAttrs(rec {
          inherit protobuf;

          pname = "protobuf";
          version = "4.23.4";
          src = protobuf.src;

          postPatch = ''
            ls -hal $PWD/
            '';

          setupPyGlobalFlags = [ "--cpp_implementation" ];
          propagatedBuildInputs = [protobuf];
          pythonImportsCheck = [
            "google.protobuf"
            "google.protobuf.internal._api_implementation" # Verify that --cpp_implementation worked
          ];

          doCheck = false; # starting without
        });

        robotframework-browser = python.pkgs.buildPythonApplication rec {
          pname = "robotframework-browser";
          version = "17.1.0";
          format = "setuptools";

          src = python.pkgs.fetchPypi {
            inherit pname version;
            hash = "sha256-zO9a3phdy72tB5C8LoXX/OvRsQth1klImoelO9XJpUA=";
          };

          propagatedBuildInputs = [
            python.pkgs.overrides
            python.pkgs.typing-extensions
            robotframework-pythonlibcore
            protobuf-python
            robotframework.packages.${system}.robotframework
          ];

          meta = with nixpkgs.lib; {
            license = nixpkgs.lib.licenses.asl20;
          };
        };
    in {
        packages.robotframework-browser = robotframework-browser;
        packages.${system}.default = robotframework-browser;
        defaultPackage.${system} = robotframework-browser;
        devShells.${system}.default = pkgs.mkShell {
          buildInputs = [
            protobuf-python
          ];
        };
    };
}
