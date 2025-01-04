# MiniCpu
This is a simple CPU component that is implement in VHDL.

# Building and running the project (Windows)
- Prerequisites:
    - ~~Make building tool: install from MSYS2, Cygwin or choco package manager~~
    - VS Code VHDL extension: https://marketplace.visualstudio.com/items?itemName=puorc.awesome-vhdl
    - GHDL simulator: http://ghdl.free.fr/ghdl-installer-0.29.1.exe
    - GTKWave signal visualizer: https://sourceforge.net/projects/gtkwave/files/gtkwave-3.3.90-bin-win64/gtkwave-3.3.90-bin-win64.zip
- Steps:
    - To build the project open your personal keybinds with ``Ctrl+Shift+P`` and type ``Open Keyboard Shortcut (JSON)`` and add this:

        ````json
        [
            { 
                "key": "alt+1",
                "command": "workbench.action.tasks.runTask",
                "args": "runC",
            },
            { 
                "key": "alt+2",
                "command": "workbench.action.tasks.runTask",
                "args": "analyze",
            }
        ]
        ````

        You can replace the keys according with your preferences.