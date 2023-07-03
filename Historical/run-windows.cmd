@echo off
:: Thanks to the OpenRSC team who I adapted this script from, much love <3
set mariadbpath=%~dp0\database\bin\
set data=%~dp0\data\
set database=%~dp0\database\
set home=%~dp0

:CHECK_JAVA
java -version 1>nul 2>nul || (
   echo ERROR: Java not installed!
   GOTO OPENJDK
)
for /f tokens^=2-5^ delims^=.-_^" %%j in ('java -fullversion 2^>^&1') do set "jver=%%j%%k%%l%%m"

if %jver% LSS 180261 (
  echo Current Java version is outdated. Java 8 Update 261 is the minimum.
  GOTO JAVA_VERSION_ERROR
)

if %jver% GTR 190000 (
  echo Current Java version is not Java 8.
  GOTO JAVA_VERSION_ERROR
)

GOTO start

:JAVA_VERSION_ERROR
echo.
echo Expected min version:
echo openjdk full version "1.8.0_261-b12"
echo.
echo Current Java install:
java -fullversion
echo.

:OPENJDK
echo Opening OpenJDK 8 download page . . .
start https://adoptopenjdk.net/?variant=openjdk8^&jvmVariant=hotspot
pause

:start
:: Initial menu displayed to the user
cls
if not exist "%database%\data\" goto initDB
echo:
echo What would you like to do?
echo:
echo Choices:
echo   1. Run the game
echo   2. Reset the database.
echo   3. Grant a player admin rights.
echo   4. Exit.
set /p action=Please enter a number choice from above: 
echo:
if /i "%action%"=="1" goto run
if /i "%action%"=="2" goto reset
if /i "%action%"=="3" goto role
if /i "%action%"=="4" goto exit
echo Error! %action% is not a valid option. Press enter to try again.
echo:
set /p action=""
goto start


:role
:: Grant player admin rights
taskkill /f /im mysqld*
taskkill /f /im java*
cls
cd "%database%"
call start /min "" "%mariadbpath%mysqld.exe" --console --skip-grant-tables --lc-messages-dir="%cd%\share\english" --datadir="%cd%\data"
ping localhost -n 4 > nul
cls
set /p username=Please enter the user to make an admin: 
call "%mariadbpath%mysql.exe" -uroot -e "USE global; UPDATE `members` SET `rights` = '2' WHERE `members`.`username` = '%username%';"
ping localhost -n 3 > nul
echo:
echo %username% is now an Administrator!
call "%mariadbpath%mysqladmin.exe" -uroot shutdown
echo:
pause
goto start


:exit
:: Shuts down existing processes
taskkill /f /im Java*
taskkill /f /im mysqld*
exit


:run
:: Launch Client and Server
cls
cd "%database%"
echo Starting Database.
start /min "Database" "%mariadbpath%mysqld.exe" --console --skip-grant-tables --lc-messages-dir="%cd%\share\english" --datadir="%cd%\data"
ping localhost -n 6 > nul
cls
echo:
echo Starting 2009scape.
echo:
cd "%home%"
start /min "Management Server" java -Xms1024m -Xmx1024m -jar ms.jar
ping localhost -n 3 > nul
start /min "Server - CTRL+C to close" java -Xms1024m -Xmx1024m -cp server.jar rs09.Server "worldprops\default.json"
ping localhost -n 10 > nul
start /min "" java -Xms1024m -Xmx1024m -jar client.jar
echo:
goto start


:initDB
:: Setup mysql tables
taskkill /f /im Java*
taskkill /f /im mysqld*
cd "%home%"
mkdir "%home%..\.runite_rs\runescape"
robocopy data\cache\ "%userprofile%\.runite_rs\runescape\" /mir /is > nul 2>&1
cd "%database%"
mkdir data
call start /b ""  "%mariadbpath%mysqld.exe" --console --skip-grant-tables --lc-messages-dir="%cd%\share\english" --datadir="%cd%\data" > nul 2>&1
ping localhost -n 4 > nul
call "%mariadbpath%mysql.exe" -uroot -e "CREATE DATABASE global;
call "%mariadbpath%mysql.exe" -uroot -e "CREATE DATABASE server;
call "%mariadbpath%mysql.exe" -uroot global < "%data%\global.sql"
echo:
echo Databases initialized!
taskkill /f /im mysqld*
goto start


:reset
:: Confirmation menu for reset
taskkill /f /im Java*
taskkill /f /im mysqld*
cls
echo:
echo Are you ABSOLUTELY SURE that you want to reset all game databases?
echo:
echo To confirm the database reset, type yes and press enter.
echo:
set /p confirmwipe=""
echo:
if /i "%confirmwipe%"=="yes" goto wipe
echo Error! %confirmwipe% is not a valid option.
pause
goto start


:wipe
:: Delete database and re-init
cls
rmdir /S /Q "%database%data"
mkdir "%database%data"
goto initDB
