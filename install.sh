#!/bin/bash
# Installs the clawd status line for Claude Code.
# Usage: curl -fsSL https://raw.githubusercontent.com/nghiatm-twendee/clawd-statusline/main/install.sh | bash
set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/nghiatm-twendee/clawd-statusline/main"
CLAUDE_DIR="$HOME/.claude"
SCRIPT_PATH="$CLAUDE_DIR/statusline-command.sh"
SETTINGS_PATH="$CLAUDE_DIR/settings.json"

command -v node >/dev/null 2>&1 || {
  echo "This status line needs Node.js on PATH (used to parse the JSON Claude Code sends it). Install Node and re-run." >&2
  exit 1
}

mkdir -p "$CLAUDE_DIR"

echo "Downloading statusline-command.sh to $SCRIPT_PATH ..."
curl -fsSL "$REPO_RAW/statusline-command.sh" -o "$SCRIPT_PATH"
chmod +r "$SCRIPT_PATH"

echo "Updating $SETTINGS_PATH (adding/replacing only the statusLine key, everything else is preserved) ..."
node -e '
const fs = require("fs");
const path = process.argv[1];
let settings = {};
if (fs.existsSync(path)) {
  const raw = fs.readFileSync(path, "utf8").trim();
  if (raw) {
    try {
      settings = JSON.parse(raw);
    } catch (e) {
      console.error(`Could not parse existing ${path} as JSON — leaving it untouched. Add this manually instead:`);
      console.error(JSON.stringify({ statusLine: { type: "command", command: "bash ~/.claude/statusline-command.sh" } }, null, 2));
      process.exit(1);
    }
  }
}
settings.statusLine = { type: "command", command: "bash ~/.claude/statusline-command.sh" };
fs.writeFileSync(path, JSON.stringify(settings, null, 2) + "\n");
' "$SETTINGS_PATH"

echo
echo "Done! Restart Claude Code (or start a new session) to see it."
echo "Uninstall any time: remove the \"statusLine\" key from $SETTINGS_PATH and delete $SCRIPT_PATH."
