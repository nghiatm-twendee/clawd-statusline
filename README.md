# clawd-statusline

A [Claude Code](https://claude.com/claude-code) status line with three live progress bars — 5-hour usage, 7-day usage, and context window usage — plus **clawd**, Claude Code's own real mascot, hanging out on the right. clawd is quiet most of the time, but every now and then he strikes a random pose and pops up a short speech bubble.

![screenshot](./screenshot.png)

## Install

```
curl -fsSL https://raw.githubusercontent.com/nghiatm-twendee/clawd-statusline/main/install.sh | bash
```

This downloads `statusline-command.sh` into `~/.claude/` and adds a `statusLine` entry to `~/.claude/settings.json`. It only touches that one key — anything else already in your `settings.json` is left alone. Restart Claude Code (or start a new session) afterward to see it.

Prefer not to pipe a script straight into bash? Fair — [read `install.sh`](./install.sh) first, or just do it by hand:

1. Copy [`statusline-command.sh`](./statusline-command.sh) to `~/.claude/statusline-command.sh`
2. Add this to `~/.claude/settings.json`:
   ```json
   "statusLine": {
     "type": "command",
     "command": "bash ~/.claude/statusline-command.sh"
   }
   ```

## Requirements

- `bash`
- `node` on your `PATH` (used to parse the JSON Claude Code passes in — no packages, just `node -e`)

## What's on it

- **`5h`** and **`7d`** — your Claude.ai rate-limit usage, from `rate_limits.five_hour` / `rate_limits.seven_day` in the status line payload. Green under 50%, yellow under 80%, bright red at 80%+.
- **`ctx`** — live context window usage for the current session, from `context_window.used_percentage`.
- **clawd** — sits next to the first two bars. About 1-in-6 refreshes, he'll strike one of 4 random poses and show a short message in a speech bubble for a few seconds before going quiet again.

All three bars show `n/a` gracefully until the first API response of a session populates that data (this is normal — see the [statusline docs](https://code.claude.com/docs/en/statusline)).

## Where clawd comes from

clawd is Claude Code's actual internal mascot — this was reverse-engineered from the installed CLI binary (its real pose data, and its real color, `rgb(215,119,87)`), not invented. It's an unofficial fan-recreation for a personal status line, not an official Anthropic asset, and isn't affiliated with or endorsed by Anthropic.

## Customizing

Everything lives in one file, `statusline-command.sh`:

- `BUBBLE_HOLD_SECONDS` — how long a triggered speech bubble stays up (default `5`)
- `MESSAGES=(...)` — the pool of speech-bubble lines; add, remove, or edit freely (emoji work fine)
- `RANDOM % 6` — the bubble's trigger chance (currently ~1-in-6 per refresh); lower the `6` for more frequent bubbles
- `color_for_pct()` — the green/yellow/red thresholds for the bars

## Notes on line count

The status line only ever prints 3 lines. In testing, a terminal reliably clipped a 3rd line whenever it contained clawd's specific block-drawing characters on their own — but a 3rd line built from plain progress-bar characters (`█`/`░`, same as lines 1-2) rendered fine, which is why `ctx` looks the way it does. If you run into similar clipping when customizing, that's the thing to check first.

## Uninstall

Remove the `"statusLine"` key from `~/.claude/settings.json` and delete `~/.claude/statusline-command.sh`.
