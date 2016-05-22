cd "C:\W3Mods\Witcher_3_Mod_Tools\bin\x64"
setlocal
set modName=mod1111Triangle
set unpackedPath=C:\W3mods\TriangleMod\temp\Witcher3

rmdir "C:\GOG Games\The Witcher 3 Wild Hunt\Mods\%modName%\content\scripts" /S/Q
xcopy "%unpackedPath%\content\scripts" "C:\GOG Games\The Witcher 3 Wild Hunt\Mods\%modName%\content\scripts" /S/K/I/Y
rmdir "%unpackedPath%\content\scripts" /S/Q
xcopy "%unpackedPath%\content\content0" "C:\GOG Games\The Witcher 3 Wild Hunt\Mods\%modName%\content\content0" /S/K/I/Y
rmdir "%unpackedPath%\content\content0" /S/Q

set isEmpty=true
for /F %%i in ('dir /b /a "%unpackedPath%\content\*"') do (
    if not "%%i" == "scripts" (
    	if not "%%i" == "content0" (
    		set isEmpty=false
    	)
    )
)

if "%isEmpty%" == "false" (
	wcc_lite pack -dir="%unpackedPath%\content" -outdir="C:\GOG Games\The Witcher 3 Wild Hunt\Mods\%modName%\content"
	wcc_lite metadatastore -path="C:\GOG Games\The Witcher 3 Wild Hunt\Mods\%modName%\content"
)



@echo off
REM wcc_lite uncook -skiperrors -indir="C:\GOG Games\The Witcher 3 Wild Hunt\content\content0\bundles" -outdir="C:\W3mods\modReference"
REM wcc_lite uncook -skiperrors -indir="C:\GOG Games\The Witcher 3 Wild Hunt\DLC\ep1\content\bundles" -outdir="C:\W3mods\modReference\HeartOfStone\content\dlc\ep1"