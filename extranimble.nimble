# Package

version     = "0.1.0"
author      = "Nycto"
description = "A set of build tasks for Nimble"
license     = "MIT"
skipDirs    = @[ "test" ]

import system, ospaths, strutils

const tasks = [
    "all",
    "src",
    "test",
    "bin",
    "readme",
    "setup_travis"
]

task test, "Execute tests":
    for dir in listDirs("test"):
        for task in tasks:
            exec("(cd $1 && nimble $2)" % [ dir, task ])

        for file in readFile(dir / "expect").strip.split("\n"):
            let fullPath = dir / file
            assert(fileExists(fullPath) or dirExists(fullPath), "File does not exist: " & fullPath)

        exec("(cd $1 && nimble clean)" % [ dir ])

    echo "Done!"

