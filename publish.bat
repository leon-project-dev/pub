:: default in project Script dir 

::build 
echo "publish start..."

set SolutionName=%1
set InstallUrl=%2
set Configuration=%3

set GitHubActionURL=%4
set NotifyTitle=%5

set NowVersion=%6
if "%NowVersion%" == "" (
   :: read version file 
   cd tmp/
   set /p NowVersion=<./version.txt
   cd ../   
)

cd ../../

::clean cache file
cd Client/NeoTrader/
if exist .\obj\ ( rd /S /Q  .\obj\)
if exist .\bin\ ( rd /S /Q  .\bin\)

cd ..
:: clean pub dir
if exist .\pub\ ( rd /S /Q  .\pub\)

:: Restore the application
msbuild %SolutionName% /t:Restore /p:Configuration=%Configuration%

:: clean
msbuild %SolutionName% /t:clean

:: clickOnce 
msbuild %SolutionName% /t:publish /p:PublishProfile=Properties/PublishProfiles/ClickOnceProfile.pubxml /p:Platform=x64 /p:Version=%NowVersion% /p:FileVersion=%NowVersion% /p:PublishDir="../pub/" /p:CreateDesktopShortcut=True /p:ApplicationVersion=%NowVersion% /p:InstallUrl=%InstallUrl% /p:Configuration=%Configuration% 

if %errorlevel% NEQ 0 (
	:: notify slack
	cd ../Script/NeoTrader/
	call ./notify_slack.bat failure %NowVersion%  "%SolutionName% publish failure" %GitHubActionURL% %NotifyTitle%
	:: failure 
	EXIT -1
	GOTO END
)

:END
echo "publish end ..."





