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

## How it works

A few things here might be interesting if you're into this kind of thing.

### It's a stateless script, refreshed by events, not a clock

Claude Code re-runs `statusline-command.sh` as a **brand-new process** every time something happens — a new assistant message, `/compact`, a permission-mode change, a vim-mode toggle — not on a fixed timer. There's no daemon, no background loop, and it never calls the model (this is [documented](https://code.claude.com/docs/en/statusline) as not consuming API tokens). Claude Code passes one JSON blob on stdin, and whatever the script prints to stdout becomes the status line. That's the entire contract.

The three bars are read straight out of that JSON: `rate_limits.five_hour.used_percentage`, `rate_limits.seven_day.used_percentage`, and `context_window.used_percentage`. `node -e` (rather than `jq`, which isn't guaranteed to be installed) does the parsing.

### clawd is reverse-engineered, not invented

The pose art, the animation names (`jump`, `look`, `celebrate`, `skip`, `spin`), and the exact color (`rgb(215,119,87)`, with `ansi:redBright` as its own documented non-truecolor fallback) all came from `strings`-ing the installed Claude Code binary and grepping for the render logic. The real component draws each pose from a small set of Unicode "block element" characters (`▛ ▟ ▜ ▝ ▘ ▗ ▄ █`) — each character is a quadrant/half-cell glyph, so a handful of them stacked in a 9-column × 3-row grid is enough to fake a tiny bitmap sprite without any image support. Same trick this script uses.

### Why 256-color and not truecolor

The first version used 24-bit truecolor (`\033[38;2;215;119;87m`) for clawd and broke — one terminal reliably corrupted the render. The [statusline docs](https://code.claude.com/docs/en/statusline) only show basic ANSI colors in their examples and warn that "multi-line status lines with escape codes are more prone to rendering issues." Dropping to the 256-color palette (`\033[38;5;173m` — picked by mapping the real RGB onto the nearest xterm 6×6×6 color-cube index) got close to the real color using an escape-code format that's been standard since the 90s, rather than a newer one some terminals still handle inconsistently.

### The line-3 clipping bug hunt

While adding the `ctx` bar, one terminal kept clipping the 3rd line whenever it contained clawd's own characters — but never when line 3 was plain text, and never when it reused the same `█`/`░` bar characters as lines 1-2. Isolating that took toggling one variable at a time: line count, truecolor vs. basic ANSI, then Unicode content with color stripped out entirely. It came down to those specific quadrant characters on the *last* line of the output, independent of color — which is why `ctx` is a plain bar and clawd's legs only sit on lines that aren't last. If you hit similar clipping while customizing, that's the first thing to check.

### Faking a timer in a process with no memory

Since every refresh is a fresh process, "show the bubble for ~5 seconds" can't just be a `sleep` — there's nothing to sleep *in*. Instead, when a bubble triggers, the script writes an expiry timestamp (`$EPOCHSECONDS + 5`) plus the chosen pose/message to a small state file (`~/.claude/.clawd-bubble-state`). Every later invocation reads that file first: if `$EPOCHSECONDS` hasn't passed the stored expiry yet, it just keeps showing the same bubble instead of re-rolling. It's a one-line poor-man's TTL cache, and it's the only thing that persists between runs.

## Customizing

Everything lives in one file, `statusline-command.sh`:

- `BUBBLE_HOLD_SECONDS` — how long a triggered speech bubble stays up (default `5`)
- `MESSAGES=(...)` — the pool of speech-bubble lines; add, remove, or edit freely (emoji work fine)
- `RANDOM % 6` — the bubble's trigger chance (currently ~1-in-6 per refresh); lower the `6` for more frequent bubbles
- `color_for_pct()` — the green/yellow/red thresholds for the bars

## Uninstall

```
curl -fsSL https://raw.githubusercontent.com/nghiatm-twendee/clawd-statusline/main/uninstall.sh | bash
```

Removes just the `"statusLine"` key from `~/.claude/settings.json` (everything else is left alone), and deletes `~/.claude/statusline-command.sh` and its small state file. Or by hand: remove the `"statusLine"` key from `~/.claude/settings.json` and delete `~/.claude/statusline-command.sh`.
