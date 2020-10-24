@echo off
:# Thanks to the OpenRSC team who I adapted this script from, much love <3
SET mariadbpath="%~dp0\database\bin\"
SET data="%~dp0\data\"
SET database="%~dp0\database\"
SET home=%~dp0
:<------------Begin Start------------>
REM Initial menu displayed to the user
:start
cls
echo:
echo What would you like to do?
echo:
echo Choices:
echo   1. Run the game
echo   2. Initialize the database. (Only needs to be run once!)
echo   3. Reset the database.
echo   4. Grant a player admin rights.
echo   5. Exit.
SET /P action=Please enter a number choice from above:
echo:
if /i "%action%"=="1" goto run
if /i "%action%"=="2" goto initDB
if /i "%action%"=="3" goto reset
if /i "%action%"=="4" goto role
if /i "%action%"=="5" goto exit
echo Error! %action% is not a valid option. Press enter to try again.
echo:
SET /P action=""
goto start
:<------------End Start------------>

:<------------Begin Role----------->
:role
taskkill /F /IM mysqld*
taskkill /F /IM java*
cls
cd %database%
call START ""  %mariadbpath%mysqld.exe --console --skip-grant-tables --lc-messages-dir="%CD%\share\english" --datadir="%CD%\data"
PING localhost -n 4 >NUL
cls
SET /p username=Please enter the user to make an admin: 
call %mariadbpath%mysql.exe -uroot -e "USE global; UPDATE `members` SET `rights` = '2' WHERE `members`.`username` = '%username%';"
PING localhost -n 3 >NUL
echo: 
echo %username% is now an Administrator!
call %mariadbpath%mysqladmin.exe -uroot shutdown
echo:
pause
goto start
:<------------End Role------------->

:<------------Begin Exit------------>
:exit
REM Shuts down existing processes
taskkill /F /IM Java*
taskkill /F /IM mysqld*
exit
:<------------End Exit------------>

:<------------Begin Run------------>
:run
cls
cd %database%
start /b "Database" %mariadbpath%mysqld.exe --console --skip-grant-tables --lc-messages-dir="%CD%\share\english" --datadir="%CD%\data"
PING localhost -n 6 >NUL

cls
echo:
echo Starting 2009scape.
echo:
cd %home%
start /b "Management Server" java -Xms1024m -Xmx1024m -jar ms.jar
PING localhost -n 3 >NUL


echo "Starting server-------------------------"
start "Server - Press CTRL+C to close correctly" java -Xms1024m -Xmx1024m -cp server.jar core.Server %home%\worldprops\default.json
PING localhost -n 10 >NUL

echo "Starting client-------------------------"
start "" java -Xms1024m -Xmx1024m -jar client.jar
echo:
goto start
:<------------End Run------------>

:<------------Begin initDB------------>
:initDB
REM Shuts down existing processes
taskkill /F /IM Java*
taskkill /F /IM mysqld*
cd %home%
mkdir %home%..\.runite_rs\runescape
robocopy data\cache\ %userprofile%\.runite_rs\runescape\ /MIR /IS
cd %database%
mkdir data
call START ""  %mariadbpath%mysqld.exe --console --skip-grant-tables --lc-messages-dir="%CD%\share\english" --datadir="%CD%\data"
PING localhost -n 4 >NUL
call %mariadbpath%mysql.exe -uroot -e "CREATE DATABASE global;
call %mariadbpath%mysql.exe -uroot -e "CREATE DATABASE server;
call %mariadbpath%mysql.exe -uroot global < "%data%\global.sql"
echo:
echo Databases initialized!
taskkill /F /IM mysqld*
echo:
pause
goto start
:<------------End initDB------------>

:<------------Begin Reset------------>
:reset
REM Shuts down existing processes
taskkill /F /IM Java*
taskkill /F /IM mysqld*
REM Verifies the user wishes to clear existing player data
cls
echo:
echo Are you ABSOLUTELY SURE that you want to reset all game databases?
echo:
echo To confirm the database reset, type yes and press enter.
echo:
SET /P confirmwipe=""
echo:
if /i "%confirmwipe%"=="yes" goto wipe
if /i "%confirmwipe%"=="no" goto start
echo Error! %confirmwipe% is not a valid option.
pause
goto start
REM Starts up the database server and imports both server and player database files to replace anything previously existing
:wipe
cls
cd %database%
rm -fr data
mkdir data
goto initDB
:<------------End Reset------------>
