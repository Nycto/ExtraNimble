ExtraNimble [![Build Status](https://travis-ci.org/Nycto/ExtraNimble.svg?branch=master)](https://travis-ci.org/Nycto/ExtraNimble)
============

A standard build configuration for Nim projects.

Features
--------

* Building and running tests in the `test` folder
* Building any binaries in the `bin` folder
* Compiling any code embedded in the `README.md`
* Setting up the environment for a Travis CI build (see below)

Install
-------

You can get started by adding the following to the bottom of your 'nimble' file:

```
exec "test -d .build/ExtraNimble || git clone https://github.com/Nycto/ExtraNimble.git .build/ExtraNimble"
when existsDir(thisDir() & "/.build"):
    include ".build/ExtraNimble/extranimble.nim"
```

Once that is done, you can run `nimble tasks` to see the targets that have been defined.

I also recommend adding `.build` to your `.gitignore` file.

Travis CI Integration
---------------------

To support building your Nim project with Travis CI, you can run the following command:

```
nimble travis_setup
```

Then, you just need to check in the `.travis.yml` file that gets generated:

```
git add .travis.yml
git commit
```


