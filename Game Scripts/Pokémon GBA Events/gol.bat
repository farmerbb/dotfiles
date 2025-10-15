@echo off
chcp 1252

copy "N:\OneDrive\Android\Backup\Emulation\RetroArch\saves\Pokémon Emerald Version.srm" emerald-old.srm
Z:\Games\Utilities\rzip.exe x emerald-old.srm emerald.sav

Z:\Games\Utilities\WC3Tool\WC3Tool.exe

Z:\Games\Utilities\rzip.exe x emerald.sav emerald-new.srm
copy emerald-new.srm "N:\OneDrive\Android\Backup\Emulation\RetroArch\saves\Pokémon Emerald Version.srm"