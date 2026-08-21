#!/bin/bash
# Claude Code status line: 5-hour / 7-day (weekly) Claude.ai rate limit usage and
# live context-window usage, each a progress bar, plus "clawd" (Claude Code's real
# mascot, reverse-engineered from the installed binary) sitting to the right of the
# first two lines. clawd is quiet by default; every now and then it shows a random
# pose + a short speech bubble instead.
#
# Line 3 is plain-bar style only (same █/░ characters as lines 1-2), no clawd
# content — testing showed the user's terminal reliably clips a 3rd line whenever
# it contains clawd's specific quadrant-block characters, independent of color.
input=$(cat)

RESET='\033[0m'
DIM='\033[2m'
YELLOW='\033[2;33m'
GREEN='\033[2;32m'
RED='\033[91m'   # bright, not dim — dim red on a dark background is hard to read
CLAWD_COLOR='\033[38;5;173m'   # 256-color approximation of clawd's real rgb(215,119,87)

# Pick a color by usage percentage: green under 50, yellow under 80, red at/above.
color_for_pct() {
  awk -v p="$1" -v g="$GREEN" -v y="$YELLOW" -v r="$RED" 'BEGIN{
    if (p < 50) printf "%s", g;
    else if (p < 80) printf "%s", y;
    else printf "%s", r;
  }'
}

five_pct=$(echo "$input" | node -e '
let d="";process.stdin.on("data",c=>d+=c).on("end",()=>{
  try{const j=JSON.parse(d);const v=j.rate_limits&&j.rate_limits.five_hour&&j.rate_limits.five_hour.used_percentage;
  if(typeof v==="number")process.stdout.write(String(v));}catch(e){}
});')
week_pct=$(echo "$input" | node -e '
let d="";process.stdin.on("data",c=>d+=c).on("end",()=>{
  try{const j=JSON.parse(d);const v=j.rate_limits&&j.rate_limits.seven_day&&j.rate_limits.seven_day.used_percentage;
  if(typeof v==="number")process.stdout.write(String(v));}catch(e){}
});')
ctx_pct=$(echo "$input" | node -e '
let d="";process.stdin.on("data",c=>d+=c).on("end",()=>{
  try{const j=JSON.parse(d);const v=j.context_window&&j.context_window.used_percentage;
  if(typeof v==="number")process.stdout.write(String(v));}catch(e){}
});')

BAR_WIDTH=20

repeat_char() {
  local ch="$1" n="$2" out="" i
  for ((i = 0; i < n; i++)); do out="${out}${ch}"; done
  echo "$out"
}

# Build a filled/empty progress bar for a 0-100 percentage.
make_bar() {
  local pct="$1"
  local filled empty
  filled=$(awk -v p="$pct" -v w="$BAR_WIDTH" 'BEGIN{
    v=(p*w/100)+0.5;
    if (v>w) v=w;
    if (v<0) v=0;
    printf "%d", v
  }')
  empty=$((BAR_WIDTH - filled))
  echo "$(repeat_char "█" "$filled")$(repeat_char "░" "$empty")"
}

if [ -n "$five_pct" ]; then
  bar=$(make_bar "$five_pct")
  pct_str=$(printf "%.0f%%" "$five_pct")
  color=$(color_for_pct "$five_pct")
  line1="${color}5h  [${bar}] ${pct_str}${RESET}"
else
  line1="${DIM}5h  [--------------------] n/a${RESET}"
fi

if [ -n "$week_pct" ]; then
  bar=$(make_bar "$week_pct")
  pct_str=$(printf "%.0f%%" "$week_pct")
  color=$(color_for_pct "$week_pct")
  line2="${color}7d  [${bar}] ${pct_str}${RESET}"
else
  line2="${DIM}7d  [--------------------] n/a${RESET}"
fi

if [ -n "$ctx_pct" ]; then
  bar=$(make_bar "$ctx_pct")
  pct_str=$(printf "%.0f%%" "$ctx_pct")
  color=$(color_for_pct "$ctx_pct")
  line3="${color}ctx [${bar}] ${pct_str}${RESET}"
else
  line3="${DIM}ctx [--------------------] n/a${RESET}"
fi

# clawd's 4 poses, 3 rows each (head, body, legs)
pose_r1=(" ▐▛███▛█" " ▐▟███▟█" " ▐█▟███▟" "▗▟▛███▛█▄")
pose_r2=("▝▜██████▀" "▝▜██████▀" "▝▜██████▀" " ▜██████▘")
clawd_r3="  ▝▝ ▝▝  "

MESSAGES=(
  "keep going! 💪"
  "you got this ✨"
  "beep boop 🤖"
  "stay hydrated 💧"
  "nice commit 🎉"
  "onward! 🚀"
  "almost there"
  "coffee time? ☕"
  "great work 👏"
  "take a breath 🌿"
  "ship it! 🚢"
  "looking good 😎"
  "you rock!"
  "high five! 🖐️"
  "beep beep"
  "tiny steps count 👣"
  "proud of you 🥹"
  "clawd is here 🦀"
  "good vibes only ✌️"
  "still here!"
  "you're crushing it 🔥"
  "one sec..."
  "no bugs today? 🐞"
  "*happy noises*"
  "🎉"
  "☕"
  "🚀"
  "✨✨"
  "🦀👋"
  "🌟"
)

# Persist bubble state across refreshes (each invocation is a fresh process) so a
# triggered bubble stays visible for a real-time window instead of vanishing on
# the very next refresh if refreshes happen in quick succession.
BUBBLE_STATE="$HOME/.claude/.clawd-bubble-state"
BUBBLE_HOLD_SECONDS=5   # how long a triggered bubble stays up for

expiry=0
pose_idx=0
msg=""
if [ -f "$BUBBLE_STATE" ]; then
  IFS='|' read -r expiry pose_idx msg < "$BUBBLE_STATE"
fi
expiry=${expiry:-0}
pose_idx=${pose_idx:-0}

if [ "$expiry" -gt "$EPOCHSECONDS" ] 2>/dev/null; then
  : # still within its hold window — keep the same pose/message
else
  expiry=0
  pose_idx=0
  msg=""
  # ~1-in-6 chance a new bubble (and a random pose) triggers this refresh.
  if [ $((RANDOM % 6)) -eq 0 ]; then
    pose_idx=$((RANDOM % 4))
    msg="${MESSAGES[$((RANDOM % ${#MESSAGES[@]}))]}"
    expiry=$((EPOCHSECONDS + BUBBLE_HOLD_SECONDS))
  fi
fi
echo "${expiry}|${pose_idx}|${msg}" > "$BUBBLE_STATE"

clawd_out1="${CLAWD_COLOR}${pose_r1[$pose_idx]}${RESET}"
clawd_out2="${CLAWD_COLOR}${pose_r2[$pose_idx]}${RESET}"
clawd_out3="${CLAWD_COLOR}${clawd_r3}${RESET}"

if [ -n "$msg" ]; then
  clawd_out2="${clawd_out2} ${DIM}◀ ( ${msg} )${RESET}"
fi

printf "%b\n%b\n%b\n" \
  "${line1}   ${clawd_out1}" \
  "${line2}   ${clawd_out2}" \
  "${line3}   ${clawd_out3}"
