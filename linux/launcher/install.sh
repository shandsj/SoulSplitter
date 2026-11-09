#!/usr/bin/env bash
set -Eeuo pipefail

PACKAGE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_LIVESPLIT="$PACKAGE_DIR/LiveSplit_1.8.37"
INSTALL_DIR="$HOME/Games/LiveSplit_1.8.37"
APP_DIR="$HOME/.local/share/applications"

if [[ ! -f "$SOURCE_LIVESPLIT/LiveSplit.exe" ]]; then
    printf 'Could not find the bundled LiveSplit files at:\n%s\n' "$SOURCE_LIVESPLIT" >&2
    exit 1
fi
if [[ ! -f "$SOURCE_LIVESPLIT/Components/SoulSplitter.dll" ]]; then
    printf 'The SoulSplitter component is missing from this package.\n' >&2
    exit 1
fi

mkdir -p "$INSTALL_DIR" "$INSTALL_DIR/Components" "$APP_DIR"

# Merge LiveSplit without replacing existing settings, layouts, splits, or
# unrelated custom components in an existing installation.
cp -an "$SOURCE_LIVESPLIT/." "$INSTALL_DIR/"

# Always refresh the SoulSplitter build delivered with this package.
for file in \
    SoulSplitter.dll SoulMemory.dll \
    MaterialDesignColors.dll MaterialDesignThemes.Wpf.dll \
    Microsoft.Xaml.Behaviors.dll \
    soulmemory_rs_x64.dll soulmemory_rs_x86.dll \
    soulmods_x64.dll soulmods_x86.dll \
    launcher_x64.exe launcher_x86.exe; do
    [[ -f "$SOURCE_LIVESPLIT/Components/$file" ]] || {
        printf 'Package is missing required component file: %s\n' "$file" >&2
        exit 1
    }
    cp -f "$SOURCE_LIVESPLIT/Components/$file" "$INSTALL_DIR/Components/$file"
done

install -m 0755 "$PACKAGE_DIR/livesplit-proton-launcher.sh" "$INSTALL_DIR/livesplit-proton-launcher.sh"
install -m 0644 "$PACKAGE_DIR/LiveSplit-Proton.desktop" "$APP_DIR/LiveSplit-Proton.desktop"

printf '\nInstallation complete.\n'
printf 'LiveSplit: %s\n' "$INSTALL_DIR/LiveSplit.exe"
printf 'Launcher:  LiveSplit (Proton) in your application menu\n\n'
printf 'Start your game in Steam, then launch LiveSplit (Proton).\n'
printf 'The launcher will ask which running game process to attach to.\n'
