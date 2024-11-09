NeoVim microplugin for keeping a list of frequently used commands (build, run, etc).

Global mappings:
* `F5` - Run last command
* `Ctrl-F5`, `Alt-F5` - Run *alternative* versions of last command
* `Shift-F5` - Open or create "launchpad" file with command list and show it in split window

Launchpad buffer mappings:
* `Enter` - run current line as Lua command and close window
* `Shift-Enter` - remember current line as 'last command' and close window
* `Ctrl-Enter`, `Alt-Enter` - run current line as *alternative* Lua command and close window

To implement *alternative* versions of command use `MOD` variable.

