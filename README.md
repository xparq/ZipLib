# ZipLib

ZipLib is an easy-to-use, C++ streams-friendly library for working with ZIP archives.
It's built around STL streams, and has no external dependencies beyond the C++ standard lib.
(Everything it needs has been bundled and compiled in.)

This variant is a fork of https://github.com/DreamyCecil/ZipLib, which in turn is a fork
of [Petr Beneš's original](https://bitbucket.org/wbenny/ziplib) with a few improvements
(including unmerged fixes from issues & pull requests at the original).

## Features

- Compression/decompresion with Deflate, LZMA, BZip2
- Archiving without compression
- Adding, editing and removing files and directories in the archive
- Support of PKWare encryption (password protection)
- Support for file data descriptor blocks (e.g. for compressing to stdout)
- Support of per-file comments and archive comments
- Streaming via STL streams: no need to load huge amounts of data into memory
- Easy-to-use C++ streaming API: memory stream, substream, teestream etc. (`ZipLib/streams`)
- Handy serialization helpers (`ZipLib/streams/serialization.h`)
- Using only C++11 standard library features (e.g. smart pointers)
- Support of Windows and Linux

## Customizations in this fork

- Reshuffled dir structure (less arcane, more integration-friendly layout, no more internally hard-coded `#include` paths etc.)
- Toolchain support: MSVC, MinGW/w64devkit (GCC), Linux (GCC, CLANG); auto-detected
- Frugal CLI build with a single unified GNU makefile (no need for CMake or any other build tooling; _the original CMakeLists.txt files are now mostly obsolete!_)
- Static/shared lib option (i.e. `make LIB_MODE=shared`; the default is `static`)
- More explicit licensing information (see below)

## Licensing

- The original ZipLib copyright holder is Petr Beneš (see `Licence.txt`).
- See the sources of the bundled external libraries for their individual licenses (in the LICENSE files added by this fork).
- For the incremental changes inherited from https://github.com/DreamyCecil/ZipLib, contact the maintainer of that repo!
- All additional changes (made by me) are in the Public Domain.
