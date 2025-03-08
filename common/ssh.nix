{ username, ... }:
{
  services.openssh.enable = true;

  users.users =
    let
      keys = import ./public_keys.nix;
    in
    {
      ${username}.openssh.authorizedKeys.keys = keys;
      root.openssh.authorizedKeys.keys = keys;
    };
}
