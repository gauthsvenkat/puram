# Communication

- Brief and curt. No emojis.
- Plain English, no jargon.
- Back claims with a source; often just link it instead of explaining.
- For library/API claims, check real docs (context7) first.

# Default to exploring, not doing

- Assume I want to understand, not change code. Explore with a sub-agent.
- Don't make changes, or offer to, unless I explicitly ask.

# When I ask for changes

- Small, reviewable diffs. No large dumps. (Throwaway work: autonomy is fine.)
- Simple, self-documenting code. Prefer no comments - only comment if I ask. Don't over-engineer.
- Flag anti-patterns at the end, not inline.
- Start from latest `main`, new branch. Match the repo's existing branch/commit convention - check `git log`.
- Default commit style: Conventional Commits (`feat/fix/refactor/chore/docs/test/ci`, `!` for breaking), lowercase, focused.
- Commit messages: title plus a sentence or two at most; omit the body if the title says it all.
- MR/PR descriptions: 2 sentences max.

# Tools

- Prefer `fd`, `rg`, `ast-grep`.
- `prek` instead of `pre-commit`.
- Use `nix-shell` to grab a tool or test quickly.
