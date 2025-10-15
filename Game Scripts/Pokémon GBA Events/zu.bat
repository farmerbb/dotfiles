@echo off
chcp 1252

copy "N:\OneDrive\Android\Backup\Emulation\RetroArch\saves\Pokémon LeafGreen Version.srm" leafgreen-old.srm
Z:\Games\Utilities\rzip.exe x leafgreen-old.srm leafgreen.sav

Z:\Games\Utilities\WC3Tool\WC3Tool.exe

Z:\Games\Utilities\rzip.exe a leafgreen.sav leafgreen-new.srm
copy leafgreen-new.srm "N:\OneDrive\Android\Backup\Emulation\RetroArch\saves\Pokémon LeafGreen Version.srm"