# Nix Flake Templates

## Simple

This template has all the batteries included to get you started with [numtide](https://github.com/numtide)'s [`devshell`](https://github.com/numtide/devshell). Use the following command to add it to your project:

```bash
nix flake init -t "git+https://c.csw.im/cswimr/dev-flakes#simple"
```

## uv

This template offers a Python environment, sporting [`uv`](https://github.com/astral-sh/uv) as the package manager and some example packages. It also automatically handles installing your dependencies, whether they're from a `pyproject.toml` file or from an older `requirements.txt` file. Use the following command to add it to your project:

```bash
nix flake init -t "git+https://c.csw.im/cswimr/dev-flakes#uv"
```

### Avoiding Python Compilation

This template uses [`nixpkgs-python`](https://github.com/cachix/nixpkgs-python) to retrieve Python builds. You can use [Cachix](https://www.cachix.org/) to add their binary cache to your user configuration. This will avoid lengthy Python compilation times. Their [README](https://github.com/cachix/nixpkgs-python?tab=readme-ov-file#cachix-optional) has more information on this topic.  
You can use the following command to add the binary cache to your user's `nix.conf` file:

```bash
nix-shell -p cachix --run cachix add nixpkgs-python
```

Here's an example NixOS configuration that configures this binary cache:

```nix
{
    nix = {
        substituters = [
            "https://nixpkgs-python.cachix.org"
        ];
        trusted-public-keys = [
            "nixpkgs-python.cachix.org-1:hxjI7pFxTyuTHn2NkvWCrAUcNZLNS3ZAvfYNuYifcEU="
        ];
    };
};
```
