:: foreach.cmd [cmd_to_execute] [filespec]
::
:: Executes a command for each file matching [filespec], which can be
:: a directory, wildcard mask, filename, or any combination thereof
::
:: Example: foreach.cmd exiftool f:\pics\*.NEF
::
@echo off
set source_dir=%~dp2
set filename=%~n2

:: handle case of directory specified without trailing backslash,
:: which causes ~dp to incorrectly interpret last segment of directory
:: name as filename. To do this we uncondtionally set source_dir to
:: the combination of ~dp2 and ~n2, adding a backslash at the end. If
:: %2 already specified a directory [with a blackslash] then we remove
:: the second backslash we just added (ugh)
:: https://stackoverflow.com/questions/138981/how-to-test-if-a-file-is-a-directory-in-a-batch-script
:: https://notepad2.blogspot.com/2018/05/windows-batch-script-remove-trailing.html
if exist %2\* set source_dir=%source_dir%%filename%\
if "%source_dir:~-2%"=="\\" set "source_dir=%source_dir:~0,-1%"

for /f "usebackq delims=|" %%f in (`dir /b %2`) do %1 "%source_dir%%%f"
