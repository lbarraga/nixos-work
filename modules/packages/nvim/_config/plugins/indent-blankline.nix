# This file draws vertical lines to show code indentation levels.
{
  plugins.indent-blankline = {
    enable = true;
    settings = {
      scope.enabled = false;
      exclude.filetypes = ["dashboard"];
    };
  };
}
