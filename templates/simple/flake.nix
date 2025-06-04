{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    devshell.url = "github:numtide/devshell";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }@inputs:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = with inputs; [
            devshell.overlays.default
          ];
        };
      in
      {
        devShells.default = pkgs.devshell.mkShell {
          devshell = {
            name = "SimpleTemplate";
            startup = {
              ensure-data-dir-exists.text = ''mkdir -p "$PRJ_DATA_DIR"'';
            };
          };

          commands = with pkgs; [
            { package = typos; }
            {
              name = "example";
              command = ''
                echo "Hello World!"
              '';
              help = "Example script.";
              category = "scripts";
            }
          ];

          packages = with pkgs; [
            stdenv.cc.cc
          ];

          motd = ''
            {33}🔨 Welcome to the {208}SimpleTemplate{33} Devshell!{reset}
            $(type -p menu &>/dev/null && menu)
          '';
        };
      }
    );
}
