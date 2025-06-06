{username, ...}: {
  users.users.${username} = {
    isNormalUser = true;
    initialHashedPassword = "$y$j9T$bMnmlfdolqHvFHCCQm7aE1$QzfD0SLE2pLNjNHpdDgYDDKxqR249Un05EZBb/Bbeo3";
    extraGroups = ["wheel"];
  };
}
