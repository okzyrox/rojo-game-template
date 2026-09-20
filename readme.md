# rojo-game-template

This a simple rojo game template which is curated to best fit my projects and style, including various utility modules and packages and a simple layout for managing client-ran and server-ran code.

## Controllers/Services

Each piece of the Client or Server is a Controller or Service, which are loaded on the server startup and started after all have loaded successfully. This keeps code nice and compact in each module without having a mess with a lot of files with duplicate code or just messy style as a result of not using a module script.

It also uses [Overture](https://github.com/devSparkle/Overture) by default to load packages and other modules on runtime by name only, although it isn't necessary and is just a convenience thing for me.

The "ControllerBag" system for the client was mainly developed by me, and inspired by what Knit does, as on the client it can become a pain when requiring other Controllers locally and resulting in invalid state and all kinds of problems, which is why I made it the sole source of controller data here.

## Scripts

The only script that exists is `install_packages`, which does a few things:
    - Install's Rokit toolkits
    - Install's Wally packages
    - Fixes Wally package type exports (due to wally being dumb...)
    - Add's overture tags to modules for access via `Overture:LoadLibrary(...)`
    - Regenerate's the sourcemap

It is a far more convenient and quick solution than doing all of the above manually, and is available in batch command and shell command form.

The source for it can be viewed in `scripts/install_packages.[bat/sh]`