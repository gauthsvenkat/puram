{ inputs, ... }:
{

  imports = [ inputs.agenix.nixosModules.default ];

  age.secrets = {
    ".env".file = ../.env;
  };

  virtualisation.oci-containers.backend = "docker";
}
