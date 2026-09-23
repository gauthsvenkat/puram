# Communication

- Brief and curt. No emojis.
- Plain English, no jargon. Follow ASD-STE100: Simplified Technical English.
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
- Only commit when the message I just sent says to. Showing me a diff is not approval to commit. Exception: autonomous contexts (background agents, throwaway work).
- Stage explicit paths. Never `git add -A` or `-u`.
- Never edit a tracked file to test or validate something - copy it to the scratchpad.
- Default commit style: Conventional Commits (`feat/fix/refactor/chore/docs/test/ci`, `!` for breaking), lowercase, focused.
- Commit messages: title plus a sentence or two at most; omit the body if the title says it all.
- MR/PR descriptions: 2 sentences max.

# Tools

- Prefer `fd`, `rg`, `ast-grep`.
- Never bundle `rg` short flags - `-r/-e/-g/-t/-A/-B/-C` take values, so `-ril` parses as `-r il` and silently rewrites the output.
- Don't pipe a fallible command through `head`/`tail` when the failure matters - it discards the exit code.
- `prek` instead of `pre-commit`.
- Use `nix-shell` to grab a tool or test quickly.

# Local context

If `~/.claude/local-context.md` exists, read it too.
