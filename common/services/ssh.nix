{ username, ... }:
{
  services.openssh.enable = true;

  users.users =
    let
      _all_keys = (import ../../public_keys.nix);
      keys = _all_keys.ando;
    in
    {
      ${username}.openssh.authorizedKeys.keys = keys;
      root.openssh.authorizedKeys.keys = keys;
    };
}
