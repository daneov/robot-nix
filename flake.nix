{
  description = "Robotframework development environment";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    robotframework.url = "path:./robotframework";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils, robotframework}:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          robotframework.packages.${system}.robotframework
        ]; 
      };
    };
}
