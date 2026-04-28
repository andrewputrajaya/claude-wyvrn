# CLAUDE.md

This project uses the **Wyvrn Claude harness** — a standardized structure for autonomous agent work. The harness governs how you read context, produce artifacts, and verify your own work. Do not deviate from it.

The harness is installed globally at `~/.claude-wyvrn/` (which resolves to the user's home directory, e.g. `/home/user/.claude-wyvrn/` on Unix or `C:\Users\user\.claude-wyvrn\` on Windows).

## Required reading (in order)

1. `~/.claude-wyvrn/HARNESS.md` — harness rules. Non-negotiable.
2. `.claude-wyvrn-local/PROJECT.md` if it exists, otherwise `README.md` — project context.
3. `~/.claude-wyvrn/INDEX.md` — navigation map. Use this to find the right workflow, skill, or template for your task.

Do not begin work until all three have been read.

If `~/.claude-wyvrn/` does not exist or is missing required files, halt. The harness is not installed on this machine. Report to the human via the active session: "Wyvrn harness not installed at `~/.claude-wyvrn/`. Install with `curl -fsSL https://raw.githubusercontent.com/andrewputrajaya/claude-wyvrn/main/install.sh | bash` (Unix) or `iwr -useb https://raw.githubusercontent.com/andrewputrajaya/claude-wyvrn/main/install.ps1 | iex` (Windows PowerShell), then retry."
