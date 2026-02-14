# General Rules

## Communication

- Be concise. Maximize information, minimize text.
- No emojis.
- When asked to explore or gather context, spawn a sub-agent for exploration.

## Code

- Keep code simple, readable, and maintainable.
- Code should be self-documenting. Only add comments for genuinely complex logic.
- Don't over-engineer. No unnecessary abstractions, wrappers, or indirection.
- Flag anti-patterns at the end of a response, not inline.

## Tools

- Use `fd` instead of `find`.
- Use `rg` instead of `grep`.
- Look up relevant documentation using `ref`. Fall back to `context7` if ref is unavailable.
- Use `markitdown` MCP to read content from websites.

# Git Conventions

## Commits

Follow Conventional Commits

- No emojis in commit messages.
- Prefer small, focused commits — one logical change per commit.
- Format:
  ```
  <type>[optional scope]: <title>

  <brief description>
  ```
- Title should be concise and lowercase.
- Description should be 1-2 sentences at most. Omit if the title is self-explanatory.

### Types

- `feat` — new feature
- `fix` — bug fix
- `refactor` — restructuring without behavior change
- `chore` — maintenance, dependencies, tooling
- `docs` — documentation only
- `test` — adding or updating tests
- `ci` — CI/CD changes
- `perf` — performance improvement

### Scope

Use a scope when it adds clarity (e.g. `fix(auth): ...`). Skip it when the change is broad or the scope is obvious from context.
