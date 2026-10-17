set working-directory := '..'

apply action='switch':
    nh os {{ action }} .

# NOTE: The target needs to already be on the tailnet.
deploy hostname action='boot':
    nh os {{ action }} . --hostname {{ hostname }} --target-host {{ hostname }}-root
