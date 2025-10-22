# JJ Conventional Commit

Create a jj commit using conventional commit style.

## Instructions

1. Run `jj status` to check current changes
1. Run `jj diff` to view all changes (with appropriate timeout for large diffs)
1. Run `jj log -r @- -n 5` to check recent commit message style
1. Analyze all changes carefully:
   - Determine the appropriate type (feat, fix, docs, style, refactor, test, chore)
   - Identify the scope based on affected components
   - Draft a clear, concise summary
   - Include bullet points in the body describing key changes
1. Display the proposed commit message to the user for confirmation
1. Commit atomically using heredoc format:
   ```bash
   jj commit -m "$(cat <<'EOF'
   <type>(<scope>): <summary>
   
   <body with bullet points>
   EOF
   )"
   ```
1. Print the output of the `commit` command so the user can see what happened
1. Clean up any temporary files created during the diff process

## Conventional Commit Types

- `feat`: new feature
- `fix`: bug fix
- `docs`: documentation changes
- `ci`: improvements to continuous integration tasks
- `style`: formatting changes
- `refactor`: code refactoring
- `test`: adding tests
- `chore`: maintenance tasks

## Notes

- Use scope to indicate affected component (e.g., bash, jj, nushell, helix)
- Summary should be present tense, lowercase, no period
- Body should explain what and why, not how
- Include context for future maintainers
