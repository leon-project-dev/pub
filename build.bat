::build 

echo "git push build start..."
set SolutionName=%1
set CommitUser=%2
set CommitMessage=%3
set GitHubActionURL=%4

set Header={\"content-type\"=\"application/json\"}
set SlackURL=https://hooks.slack.com/services/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

cd ../../

::clean cache file
cd Client/NeoTrader/
if exist .\obj\ ( rd /S /Q  .\obj\)
if exist .\bin\ ( rd /S /Q  .\bin\)

cd ..

:: Restore the application
msbuild %SolutionName% /t:Restore /p:Configuration=Debug

::build 
msbuild %SolutionName% /p:Platform=x64

if %errorlevel% == 0 (  GOTO SUCCESS)

::ERROR 
set FailureBody={\"text\": \"[Commit Build]：Failure \nCommit User: %CommitUser% \nCommitMessage: %CommitMessage% \nError Log URL: %GitHubActionURL%\"}
powershell curl -h @%Header% -uri %SlackURL% -method post -body '%FailureBody%'
EXIT -1	

:SUCCESS
echo success

set Body={\"text\": \"[Commit Build]: Success \nCommit User: %CommitUser% \nCommitMessage: %CommitMessage%\"}
powershell curl -h @%Header% -uri %SlackURL% -method post -body '%Body%'

echo "git push build end..."

