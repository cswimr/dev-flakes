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
        name = "SimpleTemplate";
      in
      {
        devShells.default = pkgs.devshell.mkShell {
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
            git
          ];

          motd = ''
            {33}🔨 Welcome to the {208}${name}{33} Devshell!{reset}
            $(type -p menu &>/dev/null && menu)
          '';

          devshell = {
            name = name;
            startup = {
              ensure-git-repository.text = ''
                if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
                  echo "❌ Git repository not found! Initializing..."
                  git init
                  git add flake.nix flake.lock # Add these files so Nix can detect the flake and its lockfile, now that we're in a git repository
                  echo "✅ Git repo initialized."
                fi
              '';
              ensure-data-dir-exists.text = ''mkdir -p "$PRJ_DATA_DIR"'';
            };
          };
        };
      }
    );
}
