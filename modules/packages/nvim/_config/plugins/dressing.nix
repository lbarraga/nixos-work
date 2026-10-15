# This file improves the appearance of input prompts and select menus.
{
  plugins.dressing = {
    enable = true;
    settings.select = {
      backend = ["builtin"];
      builtin.relative = "cursor";
    };
  };
}
