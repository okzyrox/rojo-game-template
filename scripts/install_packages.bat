::: Installs packages, and set's up overture bindings + fixes types

@echo off
:: Navigate
for %%D in ("%CD%") do (
    if /I "%%~nxD"=="scripts" (
        cd ..
    )
)

:: Install Toolkits
rokit install

:: Installs packages (and sets up Overture bindings)

wally install

:: Type sourcemap rebinding
echo Processing Types...
rojo sourcemap default.project.json --output sourcemap.json
wally-package-types --sourcemap sourcemap.json Packages/
wally-package-types --sourcemap sourcemap.json ServerPackages/

:: Process Packages
echo Processing Packages...

for %%f in (Packages\*.lua) do (
    echo Processing: %%f
    
    ren "%%f" "%%~nf.lua"
    
    (
        echo {
        echo     "properties": {
        echo         "Tags": [
        echo             "oLibrary"
        echo         ]
        echo     }
        echo }
    ) > "%%~dpnf.meta.json"
)

for %%f in (ServerPackages\*.lua) do (
    echo Processing: %%f
    
    ren "%%f" "%%~nf.lua"
    
    (
        echo {
        echo     "properties": {
        echo         "Tags": [
        echo             "oLibrary"
        echo         ]
        echo     }
        echo }
    ) > "%%~dpnf.meta.json"
)

echo Installed Packages