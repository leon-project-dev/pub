:: default in script dir
:: notify 
echo "notify slack start..."
set Success=%1
set Version=%2
set Message=%3
set GitHubActionURL=%4
set NotifyTitle=%5
set DownLoadURL=%6

set Header={\"content-type\"=\"application/json\"}
set SlackURL=https://hooks.slack.com/services/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
set FailureBody={\"text\": \"[%NotifyTitle%] \nmessge: %Message% \nlog url: %GitHubActionURL%\"}
set FailureBodyWithVersion={\"text\": \"[%NotifyTitle%] \nmessge: v%Version% %Message% \nlog url: %GitHubActionURL%\"}
echo %FailureBodyWithVersion%
if "%Success%" == "failure" (
	if %Version% == '' (
		powershell curl -h @%Header% -uri %SlackURL% -method post -body '%FailureBody%'
		GOTO END
	)
	powershell curl -h @%Header% -uri %SlackURL% -method post -body '%FailureBodyWithVersion%'
	GOTO END
)

set SuccessBodyWithVersion={\"text\": \"[%NotifyTitle%] \nmessge: v%Version% %Message% \nsoftware download url: %DownLoadURL%\"}
if "%Success%" == "success" (	
powershell curl -h @%Header% -uri %SlackURL% -method post -body '%SuccessBodyWithVersion%'
GOTO END
)

:END
echo "notify slack end..."


