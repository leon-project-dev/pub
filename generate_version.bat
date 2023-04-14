echo "generate version start..."
set SolutionName=%1
set Branch=%2
set MaxFlors=%3
set VerisonRoot=%4
set Version=%5
if '%Version%' NEQ '' (
	GOTO :END
)
mkdir tmp
:: call python
python ./publish.py %VerisonRoot%\%SolutionName%\%Branch%\  %MaxFlors% ./tmp/version.txt

:END
echo "generate version end..."