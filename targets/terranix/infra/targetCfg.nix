let
  email = "gauthsvenkat@gmail.com";
in
{
  alertEmail = email;
  cloudflare.accountId = "00000000000000000000000000000000";
  oci = {
    region = "eu-amsterdam-1";
    tenancyOcid = "ocid1.tenancy.oc1..aaaaaaaa0000000000000000000000000000000000000000000000000000";
  };
  pocketId = {
    inherit email;
    firstName = "Gautham";
    lastName = "Venkataraman";
  };
  scaleway = {
    # single-project org: the organization and its default project "Backup" share this id
    orgId = "00000000-0000-0000-0000-000000000000";
    ownerEmail = email;
  };
}
