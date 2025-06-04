{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    devshell.url = "github:numtide/devshell";
    nixpkgs-python.url = "github:cachix/nixpkgs-python";
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
            name = "uvTemplate";
            startup = {
              ensure-git-repository.text = ''
                if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
                  echo "❌ Git repository not found! Initializing..."
                  git init
                  git add flake.nix flake.lock # Add these files so Nix can detect the flake and its lockfile, now that we're in a git repository
                  echo "✅ Git repo initialized."
                fi
              '';
              bootstrap-project = {
                text = ''
                  set -euo pipefail

                  echo "🔧 Bootstrapping Python environment..."

                  has_pyproject=false
                  has_requirements=false
                  venv_exists=false

                  if [[ -d ".venv" ]]; then
                    venv_exists=true
                  fi

                  if [[ -f "pyproject.toml" ]]; then
                    echo "📦 Found pyproject.toml"
                    has_pyproject=true
                  else
                    echo "🚫 pyproject.toml not found."
                  fi

                  requirements_files=(
                    "requirements.txt"
                    "requirements-dev.txt"
                    "requirements.dev.txt"
                    "dev-requirements.txt"
                    "dev.txt"
                    "test-requirements.txt"
                    "requirements_test.txt"
                  )

                  for file in "''${requirements_files[@]}"; do
                    if [[ -f "$file" ]]; then
                      echo "✅ Found: $file"
                      if [[ "$venv_exists" = false ]]; then
                        uv venv
                        venv_exists=true
                      fi
                      uv pip install -r "$file"
                      has_requirements=true
                    fi
                  done

                  mapfile -t wildcard_matches < <(find . -maxdepth 1 -type f -iname "requirements*.txt")

                  for match in "''${wildcard_matches[@]}"; do
                    if [[ ! " ''${requirements_files[*]} " =~ " ''${match##./} " ]]; then
                      echo "✅ Found (wildcard): $match"
                      if [[ "$venv_exists" = false ]]; then
                        uv venv
                        venv_exists=true
                      fi
                      uv pip install -r "$match"
                      has_requirements=true
                    fi
                  done

                  if [[ "$has_pyproject" = false && "$has_requirements" = false ]]; then
                    echo "🧪 No pyproject.toml or requirements files found. Creating bare uv project..."
                    uv init --bare --name=change-me
                  fi

                  if [[ ! -f "uv.lock" && "$has_requirements" = false ]]; then
                    echo "🔒 uv.lock not found. Generating lockfile..."
                    uv sync --all-groups --all-extras
                  elif [[ "$has_requirements" = false ]]; then
                    echo "🔒 uv.lock found. Syncing with lockfile..."
                    uv sync --all-groups --all-extras --locked
                  fi

                  source .venv/bin/activate
                  export PATH="${pkgs.ruff}/bin:${pkgs.basedpyright}/bin:$PATH"
                '';
                deps = [ "ensure-git-repository" ];
              };
              ensure-data-dir-exists.text = ''mkdir -p "$PRJ_DATA_DIR"'';
            };
          };

          commands = with pkgs; [
            { package = uv; }
            { package = ruff; } # the ruff pip package installs a dynamically linked binary that cannot run on NixOS
            { package = basedpyright; } # same as ruff
            { package = typos; }
            {
              name = "mkdocs";
              command = ''mkdocs "$@"'';
              help = "Project documentation with Markdown / static website generator";
            }
          ];

          packages = with pkgs; [
            stdenv.cc.cc
            inputs.nixpkgs-python.packages.${system}."3.9"
            git
            # Material for MkDocs dependencies
            cairo
            pngquant
          ];

          env = [
            {
              name = "CPPFLAGS";
              eval = "-I$DEVSHELL_DIR/include";
            }
            {
              name = "LDFLAGS";
              eval = "-L$DEVSHELL_DIR/lib";
            }
            {
              name = "LD_LIBRARY_PATH";
              eval = "$DEVSHELL_DIR/lib:$LD_LIBRARY_PATH";
            }
            {
              name = "UV_PYTHON_PREFERENCE";
              value = "only-system";
            }
            {
              name = "UV_PYTHON_DOWNLOADS";
              value = "never";
            }
          ];

          motd = ''
            {33}🔨 Welcome to the {208}uvTemplate{33} Devshell!{reset}
            $(type -p menu &>/dev/null && menu)
          '';
        };
      }
    );
}
