#!/bin/bash
# Uninstalls the clawd status line for Claude Code.
# Usage: curl -fsSL https://raw.githubusercontent.com/nghiatm-twendee/clawd-statusline/main/uninstall.sh | bash
set -euo pipefail

CLAUDE_DIR="$HOME/.claude"
SCRIPT_PATH="$CLAUDE_DIR/statusline-command.sh"
SETTINGS_PATH="$CLAUDE_DIR/settings.json"
STATE_PATH="$CLAUDE_DIR/.clawd-bubble-state"

command -v node >/dev/null 2>&1 || {
  echo "This needs Node.js on PATH to safely edit settings.json. Install Node and re-run, or remove the \"statusLine\" key from $SETTINGS_PATH by hand." >&2
  exit 1
}

if [ -f "$SETTINGS_PATH" ]; then
  echo "Removing the \"statusLine\" key from $SETTINGS_PATH (everything else is left alone) ..."
  node -e '
const fs = require("fs");
const path = process.argv[1];
const raw = fs.readFileSync(path, "utf8").trim();
if (!raw) process.exit(0);
let settings;
try {
  settings = JSON.parse(raw);
} catch (e) {
  console.error(`Could not parse ${path} as JSON — leaving it untouched. Remove the "statusLine" key manually instead.`);
  process.exit(1);
}
if (Object.prototype.hasOwnProperty.call(settings, "statusLine")) {
  delete settings.statusLine;
  fs.writeFileSync(path, JSON.stringify(settings, null, 2) + "\n");
  console.log("  done.");
} else {
  console.log("  no \"statusLine\" key found — nothing to remove there.");
}
' "$SETTINGS_PATH"
else
  echo "No $SETTINGS_PATH found — nothing to update there."
fi

for f in "$SCRIPT_PATH" "$STATE_PATH"; do
  if [ -f "$f" ]; then
    rm -f "$f"
    echo "Removed $f"
  fi
done

echo
echo "Done. Restart Claude Code (or start a new session) for the change to take effect."
