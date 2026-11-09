SOULSPLITTER + LIVESPLIT FOR PROTON
===================================

This is an all-in-one Bazzite/Linux package containing:
  - LiveSplit 1.8.37
  - The SoulSplitter component build from the linux-proton-support branch
  - The Proton namespace launcher
  - A one-command installer and application-menu entry

INSTALL
-------
1. Extract the ZIP somewhere convenient (Downloads is fine).
2. Open the extracted folder in a terminal.
3. Run:

       bash install.sh

The installer places LiveSplit in ~/Games/LiveSplit_1.8.37 and adds
"LiveSplit (Proton)" to your application menu. It does not need sudo.
If that LiveSplit folder already exists, existing settings, layouts, splits,
and unrelated components are preserved; the bundled SoulSplitter files are
refreshed.

USE
---
1. Start the supported game from Steam and let it reach the main menu/game.
2. Open your application menu and launch "LiveSplit (Proton)".
3. Select the actual game executable from the list.
4. Enter your Linux password when sudo asks. LiveSplit will then launch inside
   the game's existing Proton namespaces and Wine server.

DARK SOULS REMASTERED FIRST-RUN SETTINGS
----------------------------------------
For the working setup validated on Bazzite, open the Dark Souls 1 component
settings before attaching and keep these options disabled initially:
  - Start automatically
  - Reset inventory indices

Keep Dropmod set to None. Earlier testing produced a crash while opening
the component settings with the related automatic-start/inventory-reset behavior
enabled, but we did not isolate which option caused it. Keep them disabled
initially and only re-enable them after testing separately.

NOTES
-----
- The launcher can attach LiveSplit to other running Proton/Wine game processes.
  That does not mean SoulSplitter supports every game. SoulSplitter's game
  features are limited to the games implemented by the component.
- This package was assembled for Bazzite 44 with Steam Proton; the tested game
  setup used GE-Proton9-27. Other distributions and Proton versions may differ.
- The launcher requires bash, sudo, nsenter (util-linux), and a running Proton
  game process. The password prompt is expected: nsenter needs permission to
  enter the game's namespaces.
- The source fork and its Linux/Proton work are here:
  https://github.com/shandsj/SoulSplitter/tree/linux-proton-support

LICENSES
--------
SoulSplitter is distributed under GNU GPL version 3; see LICENSES/.
LiveSplit is distributed under the MIT License by its authors; see LICENSES/.
The bundled MaterialDesignInXAML and Microsoft.Xaml.Behaviors assemblies also have their MIT notices in LICENSES/.
The programs and libraries remain separate works bundled together for convenience.
