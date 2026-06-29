#!/usr/bin/env bash
# Status line: model, wall-clock session time, and % of session spent active in Claude.
# Reads the status-line JSON payload from stdin.

input=$(cat)

model=$(printf '%s' "$input" | jq -r '.model.display_name // "claude"')
wall_ms=$(printf '%s' "$input" | jq -r '.cost.total_duration_ms // 0')
api_ms=$(printf '%s' "$input" | jq -r '.cost.total_api_duration_ms // 0')
cost=$(printf '%s' "$input" | jq -r '.cost.total_cost_usd // 0')

# Wall-clock elapsed, formatted as Hh Mm or Mm.
wall_s=$(( wall_ms / 1000 ))
h=$(( wall_s / 3600 ))
m=$(( (wall_s % 3600) / 60 ))
if [ "$h" -gt 0 ]; then
  elapsed="${h}h ${m}m"
else
  elapsed="${m}m"
fi

# Active share = API time / wall time.
if [ "$wall_ms" -gt 0 ]; then
  pct=$(( api_ms * 100 / wall_ms ))
else
  pct=0
fi

cost_fmt=$(printf '%.2f' "$cost")

printf '%s | %s elapsed | %d%% active | $%s' "$model" "$elapsed" "$pct" "$cost_fmt"
