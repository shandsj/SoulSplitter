#!/usr/bin/env bash
set -Eeuo pipefail

# Launch LiveSplit inside the namespaces and Wine environment of a running
# Steam Proton game. This avoids creating a second Wine server/container.

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
LIVESPLIT_EXE="${SCRIPT_DIR}/LiveSplit.exe"
LIVESPLIT_DIR="$SCRIPT_DIR"

fail() {
    printf '\nERROR: %s\n' "$*" >&2
    read -r -p 'Press Enter to close this window...' _ || true
    exit 1
}

[[ -f "$LIVESPLIT_EXE" ]] || fail "LiveSplit.exe not found beside this launcher: $LIVESPLIT_EXE"
command -v nsenter >/dev/null 2>&1 || fail 'nsenter is missing. Install the util-linux package.'
command -v sudo >/dev/null 2>&1 || fail 'sudo is not installed.'
command -v ps >/dev/null 2>&1 || fail 'ps is missing.'

# Enumerate Windows .exe processes that belong to a Wine/Proton prefix.
# The target process may have a truncated Linux comm name, so use its full
# command line and environment rather than pgrep -x.
CANDIDATES=()
while IFS= read -r process_line; do
    [[ -n "$process_line" ]] || continue
    process_line="${process_line#"${process_line%%[![:space:]]*}"}"
    pid="${process_line%%[[:space:]]*}"
    cmd="${process_line#"$pid"}"
    cmd="${cmd#"${cmd%%[![:space:]]*}"}"
    [[ "$pid" =~ ^[0-9]+$ ]] || continue
    [[ -r "/proc/$pid/environ" ]] || continue

    lower_cmd="${cmd,,}"
    [[ "$lower_cmd" == *".exe"* ]] || continue
    [[ "$lower_cmd" == *"livesplit.exe"* ]] && continue
    if [[ "$lower_cmd" =~ (steam\.exe|steamwebhelper\.exe|explorer\.exe|services\.exe|winedevice\.exe|plugplay\.exe|rpcss\.exe|svchost\.exe|start\.exe|conhost\.exe|cmd\.exe|taskhostw?\.exe) ]]; then
        continue
    fi

    # Only offer processes attached to a Wine/Proton prefix.
    if ! tr '\0' '\n' < "/proc/$pid/environ" | grep -Eq '^(WINEPREFIX|STEAM_COMPAT_DATA_PATH)='; then
        continue
    fi
    CANDIDATES+=("$pid"$'\t'"$cmd")
done < <(ps -eo pid=,args=)

(("${#CANDIDATES[@]}" > 0)) || fail 'No running Proton/Wine game executable was found. Start the game through Steam first.'

printf 'LiveSplit will attach to a running Proton/Wine game.\n'
printf 'Choose the actual game executable, not a launcher or helper process.\n\n'
for i in "${!CANDIDATES[@]}"; do
    line="${CANDIDATES[$i]}"
    printf '  %d) %s\n' "$((i + 1))" "${line#*$'\t'}"
done
printf '\n'
read -r -p 'Choose the game number: ' choice
[[ "$choice" =~ ^[0-9]+$ ]] || fail 'Please enter a number from the list.'
((choice >= 1 && choice <= ${#CANDIDATES[@]})) || fail 'That selection is outside the list.'

line="${CANDIDATES[$((choice - 1))]}"
GAME_PID="${line%%$'\t'*}"
GAME_CMD="${line#*$'\t'}"
[[ -r "/proc/$GAME_PID/environ" ]] || fail 'The selected game process has exited.'

read_target_env() {
    local key="$1"
    tr '\0' '\n' < "/proc/$GAME_PID/environ" | sed -n "s/^$key=//p" | head -n 1
}

WINELOADER="$(read_target_env WINELOADER)"
PROTON_PATH="$(read_target_env PROTON_PATH)"
WINEPREFIX="$(read_target_env WINEPREFIX)"
STEAM_COMPAT_DATA_PATH="$(read_target_env STEAM_COMPAT_DATA_PATH)"

if [[ -z "$WINELOADER" && -n "$PROTON_PATH" && -x "$PROTON_PATH/files/bin/wine64" ]]; then
    WINELOADER="$PROTON_PATH/files/bin/wine64"
fi
if [[ -z "$WINEPREFIX" && -n "$STEAM_COMPAT_DATA_PATH" ]]; then
    WINEPREFIX="$STEAM_COMPAT_DATA_PATH/pfx"
fi

[[ -n "$WINEPREFIX" ]] || fail 'Could not read WINEPREFIX or STEAM_COMPAT_DATA_PATH from the selected process.'
[[ -n "$WINELOADER" && -x "$WINELOADER" ]] || fail "Could not locate the selected game's Proton wine64 loader."

printf '\nSelected: %s (PID %s)\n' "$GAME_CMD" "$GAME_PID"
printf 'Prefix:   %s\n' "$WINEPREFIX"
printf 'Loader:   %s\n\n' "$WINELOADER"
printf "Starting LiveSplit inside the game's existing Proton namespaces. sudo may ask for your password.\n"

# These variables refer to resources that are not inherited by nsenter, or to
# a preload shim with the wrong ELF class. Wine reconnects through its prefix.
sudo nsenter \
    --target "$GAME_PID" \
    --mount --pid --env \
    --setgid follow --setuid follow \
    --wd="$LIVESPLIT_DIR" \
    -- \
    /usr/bin/env -u WINESERVERSOCKET -u LD_PRELOAD \
    "$WINELOADER" "$LIVESPLIT_EXE"

printf '\nLiveSplit has closed.\n'
read -r -p 'Press Enter to close this window...' _ || true
