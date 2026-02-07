@echo off
cd /d "%~dp0"
echo Launching TaskSchedular.exe ...
.\TaskSchedular.exe watch .\Weeekly.md --out .\Tasks.md
rem start "" "%~dp0TaskSchedular.exe" "watch .\Weeekly.md --out .\Tasks.md"
echo.
echo TaskSchedular.exe を開始。 ウィンドウを閉じるなら何かキーを押してください。
pause >nul
