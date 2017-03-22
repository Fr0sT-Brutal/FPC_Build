Building FreePascal and Lazarus from sources on Windows
=======================================================

This repo contains two scripts for Windows to grab FPC and Lazarus sources and build them including cross-build.

Prerequisites
-------------

1. `git` binary in `PATH`.

Source retrieval uses git repositories so git must be accessible. Exporting from SVN is not supported.

2. Minimal FPC distribution

Get it from [here](https://www.getlazarus.org/setup/minimal).

3. Linux binaries and libs

For cross-compiling to Linux, binaries and libs are needed. You can get them from **Releases** section of this repo or by installing [full setup](https://www.getlazarus.org/setup).


Steps
-----

1. Create a directory where FPC and Lazarus will be

2. Place `update.bat`, `build.bat`, `buildall.bat` to that folder

3. Download minimal FPC, unpack it to that folder and rename to `fpc-min`

4. **For Linux cross-compiling:** download [full setup](https://www.getlazarus.org/setup) and install it to temporary folder. Copy `i386-linux-*.exe` and `x86_64-linux-*.exe` from `{TmpFullInstall}\fpc\bin\i386-win32` to `{FPCFromSources}\fpc-min\bin\i386-win32`. Alternatively, you can get these binaries from **Releases** section of this repo.

4. Run `update.bat`. It will create necessary folders and pull current master branches from FPC and Lazarus repositories

5. Run `buildall.bat`. It will build FPC for Win/32, Win/64, Lin/32 and Lin/64 and Lazarus for Win/32. If you don't need any of these, comment out corresponding lines in `buildall.bat`.

6. **For Linux cross-compiling:** copy `{TmpFullInstall}\fpc\lib` folder to `{FPCFromSources}\FPC`. Alternatively, you can get these binaries from **Releases** section of this repo.

7. Now you can remove `fpc-min` folder and uninstall temporary full install

8. Run `startlazarus.exe` and set paths.
