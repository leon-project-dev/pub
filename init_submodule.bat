@echo off & setlocal EnableDelayedExpansion

echo "git init submodule staring"

set GitHubActionURL=%1
set NotifyTitle=%2

:: get now version 
set NowVersion=%3

if "%NowVersion%" == "" (
   :: read version file 
   if exist 'tmp/' (
	   cd tmp/
	   set /p NowVersion=<./version.txt
       cd ../
   )   
)

echo %NowVersion%

git submodule > tmp.txt

set /a n=0
set line=""
set gitErrorLevel=0
for /f "tokens=2 delims= " %%I in (tmp.txt) do ( 
	echo "!cd!"
	cd %%I
	git checkout .
	git checkout main
                git pull
	if !errorlevel! NEQ 0 (
	    set gitErrorLevel=1
	)

	set /a n=0
	set /a dotCount=1
	set line=%%I
	set line=!line:/= !
	echo "line=!line!"

	for %%J in ( !line! ) do (
		set /a n+=1	
		if "%%J" == ".." (
			set /a dotCount+=1
		)
	)

	echo "%%I: !n!, dotCount: !dotCount!"

	for /L %%K in (!dotCount!,1,!n!) do (		
	    cd ..
		echo "..end: !cd!"
	)
	
	cd ./Script/NeoTrader/
	echo "!cd!"
                echo "gitErrorLevel: !gitErrorLevel!"
	if "!gitErrorLevel!" == "1" (
		:: git error
		rd /S /Q tmp.txt
		call ./notify_slack.bat failure '%NowVersion%' "git init submodule failure" %GitHubActionURL% %NotifyTitle%
		Exit -1
	)
)

del tmp.txt

echo "git init submodule end"