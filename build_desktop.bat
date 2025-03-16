@echo off

set OUT_DIR=build\desktop
if not exist %OUT_DIR% mkdir %OUT_DIR%

odin build src\desktop -vet -strict-style -out:%OUT_DIR%\hyperlines.exe -collection:src=./src
IF %ERRORLEVEL% NEQ 0 exit /b 1

xcopy /y /e /i sprites %OUT_DIR%\sprites >nul
IF %ERRORLEVEL% NEQ 0 exit /b 1

echo Desktop build created in %OUT_DIR%