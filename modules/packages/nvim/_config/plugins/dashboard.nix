# This file designs the start screen that appears when you open Neovim.
{
  plugins.dashboard = {
    enable = true;
    settings = {
      theme = "doom";
      config = {
        header = [
          ""
          ""
          ""
          ""
          ""
          ""
          "                                                       "
          " ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗"
          " ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║"
          " ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║"
          " ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║"
          " ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║"
          " ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝"
          "                                                       "
        ];
        center = [
          {
            action = "enew";
            desc = " New File";
            icon = " ";
            key = "n";
          }
          {
            action = "AutoSession restore";
            desc = " Restore Session";
            icon = "󰦛 ";
            key = "s";
          }
          {
            action = "qa";
            desc = " Quit";
            icon = " ";
            key = "q";
          }
        ];
      };
    };
  };
}
