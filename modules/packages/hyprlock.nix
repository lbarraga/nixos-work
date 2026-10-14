{inputs, ...}: {
  perSystem = {pkgs, ...}: {
    packages.hyprlock = inputs.wrapper-modules.wrappers.hyprlock.wrap {
      inherit pkgs;
      # Charing Cross palette -- see CLAUDE.md. hyprlock wants rgba(rrggbbaa).
      settings = {
        general = {
          hide_cursor = true;
          ignore_empty_input = true;
        };

        # "screenshot" blurs whatever was on screen, so the lock inherits the
        # painting and whatever windows were open rather than a flat color.
        background = [
          {
            monitor = "";
            path = "screenshot";
            blur_passes = 3;
            blur_size = 8;
            brightness = "0.6";
            vibrancy = "0.2";
          }
        ];

        label = [
          # Time.
          {
            monitor = "";
            text = "$TIME";
            color = "rgba(deeaf2ff)";
            font_size = 92;
            font_family = "monospace";
            position = "0, 120";
            halign = "center";
            valign = "center";
          }
          # Date, quieter, underneath.
          {
            monitor = "";
            text = ''cmd[update:60000] date +"%A %-d %B"'';
            color = "rgba(7fa2aeff)";
            font_size = 20;
            font_family = "monospace";
            position = "0, 50";
            halign = "center";
            valign = "center";
          }
        ];

        input-field = [
          {
            monitor = "";
            size = "320, 52";
            position = "0, -60";
            halign = "center";
            valign = "center";

            outline_thickness = 2;
            rounding = 10;
            dots_center = true;
            dots_size = "0.25";
            dots_spacing = "0.3";

            outer_color = "rgba(23424dff)";
            inner_color = "rgba(14262ed0)";
            font_color = "rgba(deeaf2ff)";
            check_color = "rgba(f3a48eff)";
            fail_color = "rgba(e0705aff)";

            placeholder_text = "";
            fail_text = "$FAIL";
          }
        ];
      };
    };
  };
}
