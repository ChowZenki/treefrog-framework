@echo OFF
@setlocal

set VERSION=1.7.1
set TFDIR=C:\TreeFrog\%VERSION%

:parse_loop
if "%1" == "" goto :start
if /i "%1" == "--prefix" goto :prefix
if /i "%1" == "--enable-debug" goto :enable_debug
if /i "%1" == "--enable-gui-mod" goto :enable_gui_mod
if /i "%1" == "--enable-mongo" goto :enable_mongo
if /i "%1" == "--help" goto :help
if /i "%1" == "-h" goto :help
goto :help
:continue
shift
goto :parse_loop


:help
  echo Usage: %0 [OPTION]... [VAR=VALUE]...
  echo;
  echo Configuration:
  echo   -h, --help          display this help and exit
  echo   --enable-debug      compile with debugging information
  echo   --enable-gui-mod    compile and link with QtGui module
  echo   --enable-mongo      compile with MongoDB driver library
  echo;
  echo Installation directories:
  echo   --prefix=PREFIX     install files in PREFIX [%TFDIR%]
  goto :exit

:prefix
  shift
  if "%1" == "" goto :help
  set TFDIR=%1
  goto :continue

:enable_debug
  set DEBUG=yes
  goto :continue

:enable_gui_mod
  set USE_GUI=use_gui=1
  goto :continue

:enable_mongo
  set USE_MONGO=use_mongo=1
  goto :continue


:start
if "%DEBUG%" == "yes" (
  set OPT="CONFIG+=debug"
) else (
  set OPT="CONFIG+=release"
)

::
:: Generates tfenv.bat
::
set TFENV=tfenv.bat
echo @echo OFF> %TFENV%
echo ::>> %TFENV%
echo :: This file is generated by configure.bat>> %TFENV%
echo ::>> %TFENV%
echo;>> %TFENV%
echo set TFDIR=%TFDIR%>> %TFENV%
echo set PATH=%%TFDIR^%%\bin;%PATH%>> %TFENV%
echo set QMAKESPEC=%QMAKESPEC%>> %TFENV%
echo echo Setup a TreeFrog/Qt environment.>> %TFENV%
echo echo -- QMAKESPEC set to %%QMAKESPEC%%>> %TFENV%
echo echo -- TFDIR set to %%TFDIR%%>> %TFENV%


set TFDIR=%TFDIR:\=/%
:: Builds MongoDB driver
if not "%USE_MONGO%" == "" (
  echo Compiling MongoDB driver library ...
  cd 3rdparty\mongo-c-driver
  qmake -r %OPT%
  mingw32-make clean >nul 2>&1
  mingw32-make >nul 2>&1
  if ERRORLEVEL 1 (
    echo Compile failed.
    echo MongoDB driver not available, reconfigure without '--enable-mongo'.
    exit /b
  )
  cd ..\..
)
cd src
if exist Makefile ( mingw32-make -k distclean >nul 2>&1 )
qmake -spec win32-g++ %OPT% target.path='%TFDIR%/bin' header.path='%TFDIR%/include' %USE_GUI% %USE_MONGO%
cd ..
cd tools
if exist Makefile ( mingw32-make -k distclean >nul 2>&1 )
qmake -recursive -spec win32-g++ %OPT% target.path='%TFDIR%/bin' header.path='%TFDIR%/include' datadir='%TFDIR%' %USE_MONGO%
mingw32-make qmake
cd ..

echo;
echo First, run "mingw32-make install" in src directory.
echo Next, run "mingw32-make install" in tools directory.

:exit
exit /b
