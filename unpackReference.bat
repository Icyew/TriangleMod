cd "C:\W3Mods\Witcher_3_Mod_Tools\bin\x64"
wcc_lite uncook -skiperrors -uncookext=redswf -dumpswf -indir="C:\GOG Games\The Witcher 3 Wild Hunt\content" -outdir="D:\W3mods\modReference\Witcher3\content"
xcopy "C:\GOG Games\The Witcher 3 Wild Hunt\content\content0\scripts" "D:\W3Mods\modReference\Witcher3\content\scripts" /S/K/I/Y
wcc_lite uncook -skiperrors -uncookext=redswf -dumpswf -indir="C:\GOG Games\The Witcher 3 Wild Hunt\DLC\ep1\content" -outdir="D:\W3mods\modReference\Witcher3\content"
wcc_lite uncook -skiperrors -uncookext=redswf -dumpswf -indir="C:\GOG Games\The Witcher 3 Wild Hunt\DLC\bob\content" -outdir="D:\W3mods\modReference\Witcher3\content"
