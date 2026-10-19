# How to redact

How to build the public repo with [`git filter-repo`](https://github.com/newren/git-filter-repo). This page and everything in [`redact/`](../redact/) stay private; a new file there must be added to `redact/rules/paths.txt`.

Markers remove what is between them: `# BEGIN-PRIVATE` / `# END-PRIVATE` in any file with `#` comments, `<!-- BEGIN-PRIVATE -->` / `<!-- END-PRIVATE -->` in Markdown prose.

- `redact/rules/paths.txt`: paths to drop. `#` comments allowed. The stubs rename stays last.
- `redact/rules/text-replacements.txt`: `old==>new` or `regex:pattern==>new`. NOTE: No comments allowed in `text-replacements.txt`: a `#` line is a rule. Literals run before regexes; put specific before general.
- `redact/rules/commit-messages.txt`: the same format, for messages. A `BEGIN-PRIVATE` / `END-PRIVATE` block (no `#`) is removed.
- `redact/stubs/`: dummy `.sops.yaml` and `secrets/*.yaml` with throwaway keys. They replace the real files. A new secret file needs a stub at the same path, or it is dropped.
