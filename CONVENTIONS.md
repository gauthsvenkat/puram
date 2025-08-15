# Conventions

## Architecture Principles

- **Components must not import other components**. They are self-contained building blocks designed for reuse across different bases and hosts.
- If a component's configuration doesn't apply to all hosts, consider splitting it into multiple files within its own subdirectory. This allows bases or hosts to selectively import the relevant parts.

## Code Style

- Use **kebab-case** for all filenames (e.g., `graphics-drivers.nix`, `development-tools.nix`)
- Use **2-space indentation**
- **Align attribute assignments** within logical groups for readability
- **Collapse single-definition attribute sets** using dot notation:

  ```nix
  # Prefer this:
  services.openssh.enable = true;

  # Over this:
  services = {
    openssh = {
      enable = true;
    };
  };
  ```

- **Group multiple definitions** with common prefixes into a single attribute set:

  ```nix
  # Prefer this:
  services = {
    openssh.enable = true;
    tailscale.enable = true;
  };

  # Over this:
  services.openssh.enable = true;
  services.tailscale.enable = true;
  ```

- Use **lexicographical sorting** where it enhances readability and maintenance, particularly for:
  - Package lists
  - Service configurations
  - Import statements
  - Attribute definitions within logical groups
- **Use `lib.getExe` and `lib.getExe'` for executable paths** instead of manual `${pkg}/bin/executable` syntax:

  ```nix
  # Prefer this:
  lib.getExe pkgs.firefox          # Uses meta.mainProgram
  lib.getExe' pkgs.tofi "tofi-drun" # Specific executable name

  # Over this:
  "${pkgs.firefox}/bin/firefox"
  "${pkgs.tofi}/bin/tofi-drun"
  ```
