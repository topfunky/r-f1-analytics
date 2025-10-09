---
title: Commit with Jujutsu
description: Commit changes using jj with guided message formatting
authors:
  - F1 Analytics Team
tags:
  - git
  - version-control
  - jujutsu
---

# Commit with Jujutsu

## Details

You are helping commit changes using Jujutsu (jj) version control.

Follow these steps carefully:

1. Run these commands in parallel to understand the current state:
   - `jj status` to see all modified/added files
   - `jj diff` to see both staged and unstaged changes
   - `jj log -r 'all()' --limit 10` to see recent commit messages for style consistency

2. Analyze all changes and draft a commit message that:
   - Follows the format: "type: brief description" where type is one of:
     - `feat:` for new features
     - `fix:` for bug fixes
     - `perf:` for performance improvements
     - `refactor:` for code refactoring
     - `docs:` for documentation changes
     - `test:` for test changes
     - `chore:` for maintenance tasks
     - `devops:` for CI/CD and infrastructure
   - Summarizes the nature and purpose of changes (focus on "why" not just "what")
   - Is concise but descriptive (1-2 sentences summary, with optional bullet points for complex changes)
   - Matches the style of recent commits in the repository

3. Run these commands in sequence:
   - Run `make format` to format all R script files consistently
   - Create the commit and a new empty change with one command: `jj commit -m "$(cat <<'EOF'\nCommit message here\nEOF\n)"`

4. Trust that the commit was created successfully; do not run verification commands afterwards.

IMPORTANT:
- ALWAYS use the HEREDOC format for commit messages to ensure proper formatting
- DO NOT ask the user for confirmation - analyze the changes and create the commit
- Keep commit messages focused and meaningful

Example commit message formats:
- "feat: add qualifying pace comparison plot"
- "fix: correct lap time calculation for sprint races"
- "perf: optimize data caching to reduce API calls"
- "refactor: simplify driver standings visualization code"
