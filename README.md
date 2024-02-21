# ZipLib

ZipLib is an easy-to-use, C++ streams-friendly library for working with ZIP archives.
It's built around STL streams, and has no external dependencies beyond the C++ standard lib.
(Everything it needs has been bundled and compiled in.)

This variant is a fork of https://github.com/DreamyCecil/ZipLib, which in turn is a fork
of [Petr Beneš's original](https://bitbucket.org/wbenny/ziplib) with a few improvements
(including unmerged fixes from issues & pull requests at the original).

## Features

- Compression/decompression with Deflate, LZMA, BZip2
- Archiving without compression
- Adding, editing and removing files and directories in the archive
- PKWare encryption (password protection)
- Per-file and archive-level comments
- Streaming (via STL streams): no need to load huge amounts of data into memory
- Support for file data descriptor blocks (e.g. for compressing to stdout)
- Easy-to-use C++ streaming API: memory stream, substream, teestream etc. (`ZipLib/streams`)
- Basic serialization helpers (`ZipLib/streams/serialization.h`)
- Modest use of the C++ standard lib (mostly C++11 features)
- Support for Windows and Linux

## Customizations in this fork

- C++17 baseline (up from C++11; still avoiding excessive use of the std. lib)
- Reshuffled dir structure (less arcane, more integration-friendly layout, less rigid internal `#include` paths,
  some headers renamed for better ergonomics etc.)
- More explicit toolchain support: MSVC, MinGW/w64devkit (GCC), Linux (GCC, CLANG); auto-detected
- Frugal CLI build with a single unified GNU makefile (no need for CMake or any other heavy tooling;
  _the original CMakeLists.txt files are now mostly obsolete, and so are some of the VS project files, I'm afraid!_)
- Static/shared lib option (i.e. `make LIB_MODE=shared`; the default is `static`)
- Stopped calling this lib "lightweight". :) _(OK, it's not so bad, but I have very different ideas about what "lightweight" is.)_
- More explicit licensing information (see below); also replaced the unlicensed photo in the original `in1.jpg` test file
  (which, BTW, was "Candy Cigarette" from 1989, by Sally Mann -- an amazing shot!)

## Licensing

- The original ZipLib copyright holder is Petr Beneš (see `Licence.txt`).
- See the sources of the bundled external libraries for their individual licenses (in the LICENSE files added by this fork).
- For the incremental changes inherited from https://github.com/DreamyCecil/ZipLib, contact the maintainer of that repo!
- All additional changes (by me) are in the Public Domain.
