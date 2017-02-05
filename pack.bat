cd "C:\W3Mods\Witcher_3_Mod_Tools\bin\x64"
wcc_lite pack -dir="C:\W3mods\TMod\temp\Witcher3\content" -outdir="C:\GOG Games\The Witcher 3 Wild Hunt\Mods\mod1111Triangle\content"
wcc_lite metadatastore -path="C:\GOG Games\The Witcher 3 Wild Hunt\Mods\mod1111Triangle\content"



@echo off
REM wcc_lite uncook -skiperrors -indir="C:\GOG Games\The Witcher 3 Wild Hunt\content\content0\bundles" -outdir="C:\W3mods\modReference"
REM wcc_lite uncook -skiperrors -indir="C:\GOG Games\The Witcher 3 Wild Hunt\DLC\ep1\content\bundles" -outdir="C:\W3mods\modReference\HeartOfStone\content\dlc\ep1"