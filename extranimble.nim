import system, ospaths, strutils

# The directory in which to put build artifacts
when not defined(buildDir):
    const buildDir = ".build"

assert(buildDir.strip != "", "buildDir must not be empty")

# Locates a path relative to the build directory
proc inBuildDir(path: string): string =
    result = buildDir / path

# Determines the output bin of a path
proc outBin(path: string): string =
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

# Compiles a file
proc compile(path: string, run: bool) =
    exec "nimble c $# $# $# --out:$# $#" % [
        if run: "-r" else: "",
        flags.join(" "),
        baseFlags.join(" "),
        path.outBin,
        path
    ]

# Lists nim files in a directory
iterator nimFiles(dir: string): string =
    for file in listFiles(dir):
        if file.endsWith(".nim"):
            yield file

# Compiles any files in the root
proc src() =
    for file in nimFiles("."):
        compile(file, run = false)

# Runs tests
proc test() =
    for file in nimFiles("test"):
        compile(file, run = true)

# Compiles the bin files and runs them
proc bin() =
    for file in nimFiles("bin"):
        compile(file, run = false)

# Compiles the code in the readme
proc readme() =
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

task src, "Compiles source files":
    src()

task test, "Execute package tests":
    test()

task bin, "Compiles and tests the 'bin' files":
    bin()

task readme, "Compiles the code in the readme":
    readme()

task all, "Runs all tasks":
    src()
    test()
    bin()
    readme()

task clean, "Removes the build directory":
    exec "rm -r " & ("." / buildDir)

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


