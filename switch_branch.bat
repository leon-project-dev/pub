::git switch branch
echo "git switch branch start..."
set Branch=%1
set GitHubActionURL=%2
set NotifyTitle=%3

:: get now version 
set NowVersion=%4
echo %NowVersion%

cd ../../
git checkout .
git checkout %Branch%

if %errorlevel% NEQ 0 (
:: notify 	
cd Script/NeoTrader/
call ./notify_slack.bat failure '%NowVersion%' "git switch branch %Branch% failure" %GitHubActionURL% %NotifyTitle%
:: failure 
EXIT -1
)

echo "git switch branch end..."