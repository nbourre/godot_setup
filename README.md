# godot_setup
Repo that creates a Godot Windows setup automatically with each release.

👉 Get them [here](releases).

# Testing NSIS script from home
Ensure that your have a `godot_build/mono` or `godot_build/regular` folder with the Godot build you want to package.

# To build the installer, run the following command in the terminal:
```cmd
"C:\Program Files (x86)\NSIS\makensis.exe " /DVERSION=4.4.1-stable godot_installer.nsis
rem OR for Mono builds
"C:\Program Files (x86)\NSIS\makensis.exe " /DVERSION=4.4.1-stable godot_mono_installer.nsis
```

