---
description: Format code and create a jj commit with an AI-generated message
---

Please help me commit the current changes using jj:

1. First, run `make format` to format the code in this project
2. Then, analyze the current changes by running `jj diff`
3. Based on the changes, generate a concise and descriptive commit message that:
   - Follows conventional commit format (e.g., "feat:", "fix:", "refactor:", "docs:", etc.)
   - Summarizes what was changed and why
   - Is clear and specific
4. Finally, execute `jj commit -m "<generated-message>"` to create the commit

Important:
- If `make format` fails, stop and report the error
- If there are no changes to commit, let me know
- Show me the generated commit message before executing the commit for confirmation
