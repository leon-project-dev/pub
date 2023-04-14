::git pull
echo "git pull start..."
set SolutionName=%1
set GitHubActionURL=%2
set NotifyTitle=%3

:: get now version 
set NowVersion=%4

if "%NowVersion%" == "" (
   :: read version file 
   if exist 'tmp/' (
	   cd tmp/
	   set /p NowVersion=<./version.txt
       cd ../
   )   
)

echo %NowVersion%

cd ../../
git checkout .
git pull
::git pull --recurse-submodules

if %errorlevel% NEQ 0 (
:: notify 	
cd Script/NeoTrader/
call ./notify_slack.bat failure '%NowVersion%' "git pull failure" %GitHubActionURL% %NotifyTitle%
:: failure 
EXIT -1
)

echo "git pull end..."