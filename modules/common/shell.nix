{ config, ... }:
{
  programs.fish.enable = true;
  programs.zsh.enable = true;

  users.motd = ''
    ⠀⠀⠀⠀⠀⢀⣴⣶⣦⡄⢀⣀⣀⣀⣀⣀⢀⣴⣶⣦⣄⠀⠀⠀⠀⠀
    ⠀⠀⠀⠀⠀⣿⣿⣿⠟⠉⠀⠀⠀⠀⠀⠀⠉⠛⢿⣿⣿⡄⠀⠀⠀⠀
    ⠀⠀⠀⠀⠀⠙⠿⠁⠀⣠⣤⡄⠀⠀⢠⣤⣄⠀⠈⢿⠟⠀⠀⠀⠀⠀
    ⠀⠀⠀⠀⠀⠀⠇⠀⢸⣿⣿⠳⣶⣶⡞⢿⣿⡇⢠⣼⢶⢶⣤⡀⠀⠀
    ⠀⠀⢀⣾⣿⣿⣿⣦⠈⠛⠋⠐⠤⠣⠀⠘⠛⠁⢿⡽⠛⠛⣼⡇⠀ 
    ⠉⠉⠙⠿⢿⣿⡿⠟⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉

    You are connected to: ${config.networking.hostName}

    This machine is managed via colmena. Only apply changes through that.

    Config repository: https://github.com/fnsh/nixos-config
    Monitoring: https://stats.as62028.de/d/hostmetrics-exporter/host-metrics?orgId=1&var-host=${config.networking.hostName}

    These are the available shells:
     - bash
     - zsh
     - fish
  '';
}
