{ inputs, ... }: {
  perSystem = { pkgs, ... }: {
    packages.hyprlock = inputs.wrapper-modules.wrappers.hyprlock.wrap {
      inherit pkgs;
      # Blue Hour palette -- see CLAUDE.md. hyprlock wants rgba(rrggbbaa).
      settings = {
        general = {
          hide_cursor = true;
          ignore_empty_input = true;
        };

        # blurs whatever was on screen, rather than a flat color
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
          {
            monitor = "";
            text = "$TIME";
            color = "rgba(e9f4faff)";
            font_size = 92;
            font_family = "monospace";
            position = "0, 120";
            halign = "center";
            valign = "center";
          }
          {
            monitor = "";
            text = ''cmd[update:60000] date +"%A %-d %B"'';
            color = "rgba(7d9cc2ff)";
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

            outer_color = "rgba(24406bff)";
            inner_color = "rgba(121d36d0)";
            font_color = "rgba(e9f4faff)";
            check_color = "rgba(4fb0f8ff)";
            fail_color = "rgba(ec7a8cff)";

            placeholder_text = "";
            fail_text = "$FAIL";
          }
        ];
      };
    };
  };

  flake.modules.nixos.hyprlock = {
    # without this PAM file hyprlock rejects every password, silently
    security.pam.services.hyprlock = { };
  };
}
