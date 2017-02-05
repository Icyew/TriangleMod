cd "C:\W3Mods\Witcher_3_Mod_Tools\bin\x64"
wcc_lite uncook -unbundleonly -skiperrors -indir="C:\GOG Games\The Witcher 3 Wild Hunt\content\content0\bundles" -outdir="C:\W3mods\modReference\Witcher3\content"
xcopy "C:\GOG Games\The Witcher 3 Wild Hunt\content\content0\scripts" "C:\W3Mods\modReference12\Witcher3\content\scripts" /S/K/I/Y
wcc_lite uncook -unbundleonly -skiperrors -indir="C:\GOG Games\The Witcher 3 Wild Hunt\DLC\ep1\content\bundles" -outdir="C:\W3mods\modReference\Witcher3\content"