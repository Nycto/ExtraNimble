import system, ospaths, strutils

# The directory in which to put build artifacts
when not defined(buildDir):
    const buildDir = ".build"

assert(buildDir.strip != "", "buildDir must not be empty")

proc inBuildDir(path: string): string =
    ## Locates a path relative to the build directory
    result = buildDir / path

proc outBin(path: string): string =
    ## Determines the output bin of a path
    result = path.extractFilename.changeFileExt(ext = "").inBuildDir

# Where to put the nim cache
when not defined(nimCache):
    const nimCache = ".nimcache".inBuildDir

# Convenience compiler flags
when not defined(flags):
    const flags = [
        "--verbosity:0",
        "--hint[Processing]:off",
        "--hint[XDeclaredButNotUsed]:off",
    ]

# Compiler flags that usually aren't changed
when not defined(baseFlags):
    const baseFlags = [
        "--path:.",
        "--nimcache:$1" % [ nimCache ]
    ]

proc compile(path: string, run: bool) =
    ## Compiles a file
    exec "nimble -y c $# $# $# --out:$# $#" % [
        if run: "-r" else: "",
        flags.join(" "),
        baseFlags.join(" "),
        path.outBin,
        path
    ]

iterator nimFiles(dir: string): string =
    ## Lists nim files in a directory
    for file in listFiles(dir):
        if file.endsWith(".nim"):
            yield file

template callTask(name: untyped) =
    ## Invokes the nimble task with the given name
    exec "nimble " & astToStr(name)

task src, "Compiles source files":
    for file in nimFiles("."):
        compile(file, run = false)

task test, "Execute package tests":
    for file in nimFiles("test"):
        compile(file, run = true)

task bin, "Compiles and tests the 'bin' files":
    for file in nimFiles("bin"):
        compile(file, run = false)

task readme, "Compiles the code in the readme":
    if fileExists("README.md"):
        let dir = "readme".inBuildDir
        exec "mkdir -p " & dir
        var blob = newSeq[string]()
        var within = false
        var count = 1
        for line in readFile("README.md").split("\n"):
            if not within and line.startsWith("```nim"):
                within = true
            elif within and line.startsWith("```"):
                let filename = dir / ("readme_" & $count & ".nim")
                writeFile(filename, blob.join("\n"))
                compile(filename, run = true)
                inc(count)
                blob.setLen(0)
                within = false
            elif within:
                blob.add(line)

task all, "Runs all tasks":
    callTask src
    callTask test
    callTask bin
    callTask readme

task clean, "Removes the build directory":
    let path = "." / buildDir
    if fileExists(path):
        exec "rm -r " & path

# The content to put in the .travis.yml file
const travisFile = """
os: linux
language: c
install: bash <(curl -s https://raw.githubusercontent.com/Nycto/ExtraNimble/master/travis-setup.sh)
before_script: export PATH="$HOME/Nim/bin:$PATH"
script: nimble all
sudo: false
cache:
  directories:
    - $HOME/Nim
"""

task setup_travis, "Creates a .travis.yml integration file":
    writeFile(".travis.yml", travisFile)


