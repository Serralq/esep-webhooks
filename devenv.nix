{ pkgs, ... }:

{
  languages.dotnet = {
    enable = true;
    package = pkgs.dotnet-sdk_10;
  };

  packages = with pkgs; [
    awscli2
    gh
    zip
    curl
    csharpier
  ];

  env.AWS_REGION = "us-east-2";

  enterShell = ''
    export DOTNET_ROOT="$(dirname "$(readlink -f "$(command -v dotnet)")")"
    export PATH="$DEVENV_STATE/dotnet-tools:$PATH"
    command -v dotnet-lambda >/dev/null || dotnet tool install --tool-path "$DEVENV_STATE/dotnet-tools" Amazon.Lambda.Tools
    dotnet new list lambda.EmptyFunction >/dev/null 2>&1 || dotnet new install Amazon.Lambda.Templates
  '';

  scripts.fmt.exec = ''
    csharpier format .
    nixfmt devenv.nix
    prettier --write "**/*.json" "!**/{bin,obj}/**"
  '';

  git-hooks.hooks = {
    nixfmt.enable = true;
    prettier.enable = true;
    csharpier = {
      enable = true;
      name = "csharpier";
      entry = "${pkgs.csharpier}/bin/csharpier format";
      files = "\\.cs$";
    };
    no-slack-url = {
      enable = true;
      name = "no-slack-url";
      entry = "${pkgs.writeShellScript "no-slack-url" ''
        ! git diff --cached | grep "hooks[.]slack[.]com"
      ''}";
      pass_filenames = false;
    };
  };
}
