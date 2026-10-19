set working-directory := '..'

out := "/tmp/puram"

build:
    rm -rf {{ out }}
    git clone --no-local --branch main . {{ out }}
    cd {{ out }} && git filter-repo --invert-paths \
        --paths-from-file {{ justfile_directory() }}/redact/rules/paths.txt \
        --replace-text {{ justfile_directory() }}/redact/rules/text-replacements.txt \
        --replace-message {{ justfile_directory() }}/redact/rules/commit-messages.txt

push:
    cd {{ out }} && git push git@github.com:gauthsvenkat/puram.git main:main
