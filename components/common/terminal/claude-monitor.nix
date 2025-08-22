{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config.hostCfg) username;

  claude-monitor = pkgs.python3.pkgs.buildPythonApplication rec {
    pname = "claude-monitor";
    version = "3.1.0";
    pyproject = true;

    src = pkgs.fetchFromGitHub {
      owner = "Maciek-roboblog";
      repo = "Claude-Code-Usage-Monitor";
      tag = "v${version}";
      hash = "sha256-v5ooniaN1iVerBW77/00SpghIVE1j8cl2WENcPnS66M=";
    };

    build-system = with pkgs.python3.pkgs; [ setuptools ];

    dependencies = with pkgs.python3.pkgs; [
      numpy
      pydantic
      pydantic-settings
      pytz
      pyyaml
      rich
      tomli
      tzdata
    ];

    nativeCheckInputs = with pkgs.python3.pkgs; [
      pytest-asyncio
      pytest-benchmark
      pytest-cov
      pytest-mock
      pytestCheckHook
    ];

    preCheck = ''
      export HOME=$(mktemp -d)
    '';

    pytestFlags = [ "--no-cov" ];

    disabledTests = [
      "test_get_timezone_windows"
      "test_successful_main_execution"
    ];

    pythonImportsCheck = [ "claude_monitor" ];

    meta = {
      description = "Real-time terminal monitoring tool for Claude AI token usage";
      longDescription = ''
        A beautiful real-time terminal monitoring tool for Claude AI token usage with advanced analytics,
        machine learning-based predictions, and Rich UI. Track your token consumption, burn rate, cost
        analysis, and get intelligent predictions about session limits.
      '';
      mainProgram = "claude-monitor";
      homepage = "https://github.com/Maciek-roboblog/Claude-Code-Usage-Monitor";
      license = lib.licenses.mit;
      platforms = lib.platforms.unix;
    };
  };
in
{
  home-manager.users.${username}.home.packages = [ claude-monitor ];
}
