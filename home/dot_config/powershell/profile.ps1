# PowerShell aliases on Windows, mirroring the ones in ~/.profile.
# Managed by chezmoi. A one-line stub at $PROFILE dot-sources this file; the
# stub is written by run_onchange_after_windows-powershell-profile.ps1.
#
# Two PowerShell facts shape this file:
#   1. Set-Alias cannot carry arguments, so anything with a flag is a function.
#   2. Aliases outrank functions in command resolution, so a built-in alias of
#      the same name wins unless it is removed first -- hence the loop below.

# Built-in aliases we deliberately shadow. -Force because they are ReadOnly.
# gc = Get-Content, gp = Get-ItemProperty, gcb = Get-Clipboard.
foreach ($name in 'gc', 'gp', 'gcb') {
    if (Test-Path "Alias:$name") { Remove-Item "Alias:$name" -Force }
}

# listing
function ll { Get-ChildItem -Force @args }
function la { Get-ChildItem -Force @args }
function l  { Get-ChildItem @args }

# git
function g   { git @args }
function gs  { git status @args }
function gc  { git commit @args }
function gp  { git push @args }
function gpl { git pull @args }
function gco { git checkout @args }
function gcb { git checkout -b @args }

# claude code, no permission prompts -- every tool call runs unconfirmed
function ccd { claude --dangerously-skip-permissions @args }

function pwdc { (Get-Location).Path | Set-Clipboard }
