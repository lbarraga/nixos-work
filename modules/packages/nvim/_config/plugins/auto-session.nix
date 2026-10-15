# This file manages session saving and restoration automatically.
{
  plugins.auto-session = {
    enable = true;
    settings = {
      auto_restore = false;
      auto_save = true;
      bypass_session_save_target_types = ["neo-tree"];
      pre_save_cmds = ["Neotree close"];
    };
  };
}
