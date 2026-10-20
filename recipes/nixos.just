set working-directory := '..'

apply action='switch':
    nh os {{ action }} .

# NOTE: The target needs to be reachable on the LAN.
deploy hostname action='boot':
    nh os {{ action }} . --hostname {{ hostname }} --target-host {{ hostname }}-root
