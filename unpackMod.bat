cd "C:\W3Mods\Witcher_3_Mod_Tools\bin\x64"
setlocal
set /p modName=What is the directory name of the mod you want to unpack?
wcc_lite uncook -skiperrors -indir="C:\GOG Games\The Witcher 3 Wild Hunt\Mods\%modName%\content" -outdir="C:\W3mods\%modName%\Witcher3\content"
xcopy "C:\GOG Games\The Witcher 3 Wild Hunt\Mods\%modName%\content\scripts" "C:\W3Mods\%modName%\Witcher3\content\scripts" /S/K/I/Y
