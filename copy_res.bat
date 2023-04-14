::copy res
echo "copy res start..."

set SolutionName=%1
set Branch=%2
set VersisonRoot=%3
set UpdateRoot=%4
set NotifyTitle=%5
set InstallUrl=%6
set NowVersion=%7
if "%NowVersion%" == "" (
   :: read version file 
   cd tmp/
   set /p NowVersion=<./version.txt
   cd ../   
   rd /S /Q tmp
)

echo %NowVersion%

cd ../../Client/

set VersionDir=%SolutionName%_v%NowVersion%_%Branch%
mkdir %VersionDir%
xcopy /S /Q /E .\pub\* .\%VersionDir%\

cd pub
powershell rm -r *.dll;rm -r *.pdb;rm -r *.config;rm -r *.json;rm -r .\Resources\;rm -r .\NeoTrader.exe
cd ../

cd %VersionDir%
powershell rm -r .\'Application Files'\;rm -r Launcher.exe;rm -r NeoTrader.application;rm -r setup.exe
cd ../

powershell Compress-Archive -Path ./%VersionDir% -DestinationPath ./%VersionDir%.zip

set h=%time:~0,2%
set h=%h: =0%
set CurrTime=%date:~3,4%%date:~8,2%%date:~11,2%%h%%time:~3,2%%time:~6,2%

:: md verison dir
set zipDir=%VersisonRoot%\%SolutionName%\%Branch%\%CurrTime%_%NowVersion%
if exist %zipDir% ( powershell rm -r %zipDir%)
md "%zipDir%"
copy .\%VersionDir%.zip %zipDir%\

rd /S /Q %VersionDir%
del %VersionDir%.zip

::del update res dir
::powershell rm -r c:\pub\update\%SolutionName%\%VersionType%\
:: md update res dir
::md "c:\pub\update\%SolutionName%\%VersionType%"


:: copy to update 
set updateDir=%UpdateRoot%%SolutionName%\%Branch%
if not exist %updateDir% ( md %updateDir%)
xcopy /S /Q /Y /E .\pub\* %updateDir%\

:: copy res to other git
set gitUpdateDir=c:/pub_git/pub/
:: rm prve res
rm -r %gitUpdateDir%*
:: copy res
xcopy /S /Q /Y /E .\pub\* %gitUpdateDir%\

:: git
cd %gitUpdateDir%
git commit -am 'update res'


cd ../Script/NeoTrader/
:: notify publish success 
call ./notify_slack.bat success %NowVersion%  "%SolutionName% publish success" " " %NotifyTitle% %InstallUrl%setup.exe

echo "copy res end..."



