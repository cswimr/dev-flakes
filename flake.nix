{
  inputs = { };
  outputs =
    { self }:
    {
      templates = {
        simple = {
          path = ./templates/simple;
          description = "A simple template for a devshell";
          welcomeText = ''
            # `.data` and `.direnv` should be added to `.gitignore`
            ```sh
              echo .data >> .gitignore
              echo .direnv >> .gitignore
            ```
          '';
        };
        uv = {
          path = ./templates/uv;
          description = "A simple template for a uv devshell";
          welcomeText = ''
            # `.data`, `.direnv`, and `.venv` should be added to `.gitignore`
            ```sh
              echo .data >> .gitignore
              echo .direnv >> .gitignore
              echo .venv >> .gitignore
            ```
          '';
        };
        default = self.templates.simple;
      };
    };
}
