# Linux / Steam Proton (Experimental)

This page documents an experimental way to run SoulSplitter with Windows LiveSplit on Linux when the game itself is launched through Steam Proton.

It is **not a native Linux build** of LiveSplit or SoulSplitter. LiveSplit remains a Windows application running under Wine/Proton.

## Tested configuration

The current setup has been tested with:

- Bazzite 44
- Steam
- GE-Proton 9-27
- LiveSplit 1.8.37
- Dark Souls Remastered (Steam App ID `570940`)

Other Linux distributions, Proton versions, games, and desktop environments have not all been tested. The launcher can attach to a variety of Proton/Wine processes, but that does not add SoulSplitter game support where the component does not already implement it.

## Why a launcher is needed

Steam runs each Proton game in its own compatibility environment. Starting LiveSplit separately, even while selecting the same Wine prefix, can place it in a different container and Wine server. In that situation SoulSplitter may not be able to inspect the game's process.

The launcher finds running Windows executable processes that expose a Wine/Proton prefix, asks which process to use, and starts LiveSplit inside that process's mount and PID namespaces. It also removes inherited `WINESERVERSOCKET` and `LD_PRELOAD` values that caused problems when launching from the host.

## Requirements

- A Steam game launched through Proton or a compatible Wine environment
- Bash
- `ps` (usually provided by `procps`)
- `nsenter` (provided by `util-linux`)
- `sudo`
- Standard command-line tools: `env`, `grep`, `head`, `sed`, and `tr`

These tools are available by default on Bazzite. Other distributions may require installing the packages that provide them.

## Install the all-in-one package

The Proton compatibility workflow produces a ZIP artifact containing LiveSplit 1.8.37, the built SoulSplitter component, the launcher, and an installer.

1. Open the repository's **Actions** tab and select **Proton compatibility build**.
2. Open a successful run and download the `SoulSplitter-Proton-Bundle` artifact. If there is no recent run (for example, after this change is merged to `main`), use **Run workflow** and select the `main` branch to create a fresh package.
3. Extract the ZIP to a convenient location.
4. Open a terminal in the extracted folder and run:

   ```bash
   bash install.sh
   ```

The installer copies LiveSplit to `~/Games/LiveSplit_1.8.37`, installs the launcher, and adds **LiveSplit (Proton)** to the desktop application menu. It does not require administrator privileges. The ZIP includes license notices for SoulSplitter, LiveSplit, and the bundled MIT-licensed UI dependencies.

If that LiveSplit folder already exists, the installer preserves existing files and settings, then refreshes the SoulSplitter component files. The current installer does not replace existing LiveSplit core files that are already present.

## Run LiveSplit with a game

1. Start the game from Steam and wait until it reaches the title screen or gameplay.
2. Launch **LiveSplit (Proton)** from the application menu.
3. Choose the game's actual executable from the detected process list. Avoid selecting Steam helpers, launchers, or updater processes.
4. Enter your Linux password when prompted.
5. LiveSplit should open in the same Proton environment as the selected game.

When configuring a run, use the normal SoulSplitter settings for the game and set LiveSplit to compare against game time, as described in the main installation instructions.

## Dark Souls Remastered notes

The tested Bazzite setup was stable with these Dark Souls 1 component settings:

- **Start automatically:** disabled
- **Reset inventory indices:** disabled
- **Dropmod:** None

Keep these settings disabled initially. Earlier testing produced a crash while opening the component settings with the related automatic-start/inventory-reset behavior enabled, but we did not isolate which option caused it. Treat these as conservative workarounds, not as proof that either option is incompatible with every Proton version.

## Permissions and security

The launcher uses `sudo nsenter` to enter the selected game's mount and PID namespaces. It uses `--setuid follow` and `--setgid follow` so the launched Wine process follows the target process's user and group rather than running the game as root.

The elevated operation is needed for namespace entry. Steam and the game should already be running as the normal desktop user. Review the launcher script before running it, particularly on systems with a different security model or process namespace configuration.

The launcher inspects local process command lines and environment variables under `/proc`. It does not upload those values or send game data to a remote service.

## Troubleshooting

### No game processes are listed

Start the game through Steam first and wait for the game's executable to appear. The launcher filters for processes whose command line includes a Windows `.exe` and whose environment contains `WINEPREFIX` or `STEAM_COMPAT_DATA_PATH`.

### Several processes are listed

Choose the actual game executable, not a launcher, crash handler, updater, or Steam helper. If unsure, close unrelated Proton games and try again.

### The launcher cannot find the Wine loader

The launcher reads the Wine loader path from the selected game's environment. Some custom Wine setups may not expose the same environment variables or host-visible paths. Such setups may need additional launcher changes.

### LiveSplit opens but SoulSplitter cannot attach

Confirm that LiveSplit was started through **LiveSplit (Proton)** after the game was started. Starting LiveSplit with `protontricks-launch` in a separate process environment may create a second Wine server and will not use this namespace-based launch path.

### Dark Souls Remastered closes when configuring the component

Apply the Dark Souls Remastered settings in the section above. Re-enable automatic start or inventory-index reset only after testing them independently.

## Current limitations

- This is an experimental integration tested on one Bazzite configuration.
- It is not a native Linux or Wayland port.
- The launcher handles process selection and namespace entry; it does not make every game supported by SoulSplitter.
- The process scanner relies on Linux `/proc`, visible command lines, and Wine/Proton environment variables.
- A successful build and automated test run do not replace testing against a live game process.

For general SoulSplitter configuration and game-specific troubleshooting, see the project [Wiki](https://github.com/FrankvdStam/SoulSplitter/wiki) and the main [README](../README.md).
