@echo off
:: Thanks to the OpenRSC team who I adapted this script from, much love <3
SET mariadbpath="%~dp0\database\bin\"
SET data="%~dp0\data\"
SET database="%~dp0\database\"
SET home=%~dp0


:start
:: Initial menu displayed to the user
cls
if not exist %database%\data\ goto initDB
echo:
echo What would you like to do?
echo:
echo Choices:
echo   1. Run the game
echo   2. Reset the database.
echo   3. Grant a player admin rights.
echo   4. Exit.
SET /P action=Please enter a number choice from above: 
echo:
if /i "%action%"=="1" goto run
if /i "%action%"=="2" goto reset
if /i "%action%"=="3" goto role
if /i "%action%"=="4" goto exit
echo Error! %action% is not a valid option. Press enter to try again.
echo:
SET /P action=""
goto start


:role
:: Grant player admin rights
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
echo
echo %username% is now an Administrator!
call %mariadbpath%mysqladmin.exe -uroot shutdown
echo
pause
goto start


:exit
:: Shuts down existing processes
taskkill /F /IM Java*
taskkill /F /IM mysqld*
exit


:run
:: Launch Client and Server
cls
cd %database%
start /min "Database" %mariadbpath%mysqld.exe --console --skip-grant-tables --lc-messages-dir="%CD%\share\english" --datadir="%CD%\data"
cls
echo:
echo Starting 2009scape.
echo:
cd %home%
start /min "Management Server" java -Xms1024m -Xmx1024m -jar ms.jar
start /min "Server - CTRL+C to close" java -Xms1024m -Xmx1024m -cp server.jar core.Server %home%\worldprops\default.json
start /min "Client - CTRL+C to close" java -Xms1024m -Xmx1024m -jar client.jar
echo:
goto start


:initDB
:: Setup mysql tables
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
pause
goto start


:reset
:: Confirmation menu for reset
taskkill /F /IM Java*
taskkill /F /IM mysqld*
cls
echo:
echo Are you ABSOLUTELY SURE that you want to reset all game databases?
echo:
echo To confirm the database reset, type yes and press enter.
echo:
SET /P confirmwipe=""
echo:
if /i "%confirmwipe%"=="yes" goto wipe
echo Error! %confirmwipe% is not a valid option.
pause
goto start


:wipe
:: Delete database and re-init
cls
cd %database%
rm -fr data
mkdir data
goto initDB