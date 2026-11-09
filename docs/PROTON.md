# Linux / Steam Proton (Experimental)

SoulSplitter is a Windows LiveSplit component. On Linux, it can be used with the Windows version of LiveSplit running inside the same Proton/Wine environment as the game. This is not a native Linux or Wayland port.

## Tested configuration

The current setup has been tested with:

- Bazzite 44
- Steam
- GE-Proton 9-27
- LiveSplit 1.8.37
- Dark Souls Remastered (Steam App ID `570940`)

Other distributions, Proton versions, games, and desktop environments have not all been tested. Using the launcher with another Proton/Wine game does not add SoulSplitter support for that game; the component must already support it.

## Launching SoulSplitter on Linux

Use [LiveSplit-Proton](https://github.com/shandsj/LiveSplit-Proton), the separate, game-agnostic launcher for starting an existing LiveSplit installation inside a running Proton/Wine game's process environment.

The [LiveSplit-Proton README](https://github.com/shandsj/LiveSplit-Proton) is the source of truth for launcher requirements and setup, including the quick start, optional application-menu shortcut, configuration, permissions, and launcher troubleshooting. Those instructions are maintained in that repository rather than duplicated here.

At a high level:

1. Install LiveSplit and the SoulSplitter component using the normal [SoulSplitter installation instructions](../README.md#installation).
2. Start the game through Steam with Proton.
3. Follow the [LiveSplit-Proton quick start](https://github.com/shandsj/LiveSplit-Proton#quick-start) to launch LiveSplit in the game's environment.

LiveSplit needs to run in the game's Proton/Wine environment for SoulSplitter to inspect the game process. Starting it independently in a different Wine environment can prevent the component from attaching.

## Dark Souls Remastered notes

On the tested Bazzite setup, these Dark Souls 1 component settings avoided the configuration crash seen during testing:

- **Start automatically:** disabled
- **Reset inventory indices:** disabled
- **Dropmod:** None

Keep these settings disabled initially. Earlier testing produced a crash while opening the component settings with the related automatic-start/inventory-reset behavior enabled, but the exact cause was not isolated. Treat these as conservative workarounds for the tested setup, not proof that either option is incompatible with every Proton version.

When configuring a run, use the normal SoulSplitter settings for the game and set LiveSplit to compare against game time, as described in the main installation instructions.

## Troubleshooting

### LiveSplit opens but SoulSplitter cannot attach

First confirm that LiveSplit was started through LiveSplit-Proton after the game was running. Then confirm that the selected process is the actual game and that SoulSplitter supports that game.

For process discovery, Wine loader, namespace, or launcher errors, use the [LiveSplit-Proton troubleshooting guide](https://github.com/shandsj/LiveSplit-Proton#troubleshooting).

### Dark Souls Remastered closes when configuring the component

Apply the Dark Souls Remastered settings listed above. Re-enable automatic start or inventory-index reset only after testing them independently.

## Scope and limitations

- This integration is experimental and has been tested on one Bazzite configuration.
- It is not a native Linux or Wayland port.
- LiveSplit-Proton handles launching LiveSplit in the game's environment; it does not add game support to SoulSplitter.
- A successful build and automated test run do not replace testing with a live game process.

For general SoulSplitter configuration and game-specific help, see the project [README](../README.md) and [Wiki](https://github.com/FrankvdStam/SoulSplitter/wiki).
