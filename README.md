# Nix Flake Templates

## Simple

This template has all the batteries included to get you started with dev-shell. Use the following command to add it to your project:

```bash
nix flake init -t "git+https://c.csw.im/cswimr/dev-flakes#simple"
```

## uv

This template offers a Python environment, sporting uv as the package manager and some example packages. It also automatically handles installing your dependencies, whether they're from a `pyproject.toml` file or from an older `requirements.txt` file. Use the following command to add it to your project:

```bash
nix flake init -t "git+https://c.csw.im/cswimr/dev-flakes#uv"
```

### Avoiding Python Compilation

This template uses [`nixpkgs-python`](https://github.com/cachix/nixpkgs-python) to retrieve Python builds. You can use Cachix to add their binary cache to your user configuration. This will avoid lengthy Python compilation times. Their [README](https://github.com/cachix/nixpkgs-python?tab=readme-ov-file#cachix-optional) has more information on this topic.
