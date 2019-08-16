Building FreePascal and Lazarus from sources on Windows
=======================================================

This repo contains two scripts for **Windows** to grab **FPC** and **Lazarus** sources and build them including cross-build.

:warning: Note that in most cases [fpcupdeluxe](https://github.com/LongDirtyAnimAlf/fpcupdeluxe/releases) will do anything for you.

Prerequisites
-------------

1. `git` binary in `PATH`.

Source retrieval uses git repositories so git must be accessible. Exporting from SVN is not supported.

2. Minimal FPC distribution

Get it from [here](https://www.getlazarus.org/setup/minimal).

3. Linux binaries and libs

For cross-compiling to Linux, binaries and libs are needed. You can get them:
 * From [CodeTyphon site](https://www.pilotlogic.com/sitejoom/index.php/downloads/category/5-toolchains)
 * By installing [full setup](https://www.getlazarus.org/setup)
 * From [Releases](https://github.com/Fr0sT-Brutal/FPC_Build/releases) section of this repo (these are exact copies from CodeTyphon site)

Steps
-----

1. Create a directory `{FPCFromSources}` where FPC and Lazarus will be

2. Put `update.bat`, `build.bat`, `buildall.bat` to that folder

3. Download minimal FPC, unpack it to that folder and rename to `fpc-min`

4. **For Linux cross-compiling:**

   4.1. Download [full setup](https://www.getlazarus.org/setup) and install it to temporary folder `{TmpFullInstall}`. Copy `{TargetCPU}-linux-*.exe` (where `{TargetCPU}` is `i386` and/or `x86_64`) from `{TmpFullInstall}\fpc\bin\i386-win32` to `{FPCFromSources}\fpc-min\bin\{TargetCPU}-linux` folders.

   *OR*

   4.2. You can get these binaries from [Releases](https://github.com/Fr0sT-Brutal/FPC_Build/releases) section of this repo. Unpack contents of `bin-{TargetCPU}-linux.7z` to `{FPCFromSources}\fpc-min\bin\{TargetCPU}-linux`.

5. Run `update.bat`. It will create necessary folders and pull current master branches from FPC and Lazarus repositories

6. Run `buildall.bat`. It will build FPC for Win/32, Win/64, Lin/32 and Lin/64 and Lazarus for Win/32. If you don't need any of these, comment out corresponding lines in `buildall.bat`.

7. **For Linux cross-compiling:**

   7.1. Copy `{TmpFullInstall}\fpc\lib` folder to `{FPCFromSources}\FPC` (note you must copy `lib` folder itself, that is, fresh FPC should have its own `lib` folder).


   *OR*

   7.2. You can get these libs from [Releases](https://github.com/Fr0sT-Brutal/FPC_Build/releases) section of this repo. Unpack contents of `lib-{TargetCPU}-linux.7z` to `{FPCFromSources}\FPC\lib\{TargetCPU}-linux`.

8. Now you can remove `fpc-min` folder and uninstall temporary full install

9. Run `startlazarus.exe` and set paths.