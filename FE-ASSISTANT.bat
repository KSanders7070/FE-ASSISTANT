@ECHO OFF

setlocal enabledelayedexpansion

:: Set SCRIPT_NAME to the name of this batch file script
	set CURRENT_VERSION=2.0.b05

:: Set SCRIPT_NAME to the name of this batch file script
	set SCRIPT_NAME=FE-Assistant

:: Set GH_USER_NAME to your GitHub username here
	set GH_USER_NAME=KSanders7070

:: Set GH_REPO_NAME to your GitHub repository name here
	set GH_REPO_NAME=FE-ASSISTANT

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

TITLE !SCRIPT_NAME! (v!CURRENT_VERSION!)

:SetUpTempDir

	:: Setting up the Temp Directory
	CD /D "%temp%"
		IF exist "!GH_REPO_NAME!-UDPATE" RD /S /Q "!GH_REPO_NAME!-UDPATE"
		MD "!GH_REPO_NAME!-UDPATE"
		
	CD /D "!GH_REPO_NAME!-UDPATE"

:GetLatestVerNum

	:: URL to fetch JSON data from GitHub API
	set "URL_TO_DOWNLOAD=https://api.github.com/repos/!GH_USER_NAME!/!GH_REPO_NAME!/releases/latest"
	
	:: Use curl to fetch the JSON data
	curl -s "%URL_TO_DOWNLOAD%">response.json

	:: Notes for future developemnt:
	:: 	Searches for lines containing the text "tag_name", and extract the values associated with "tag_name" into a variable named LATEST_VERSION.
	:: 		Note-In this .json, there should only be one line with "tag_name" in it.
	:: 	The command inside the single quotes ('...') reads the response.json file using the type command and pipes the output to find /i "tag_name"
	:: 	which searches for lines containing the case-insensitive text "tag_name".
	:: 	The rest of the !line! code is just striping the data way from the actual version number.
	for /f "tokens=*" %%A in ('type response.json ^| find /i "tag_name"') do (
		set "line=%%A"
		set "line=!line:*"tag_name": =!"
		set "line=!line:~2,-2!"
		set "LATEST_VERSION=!line!"
	)

:DoYouHaveLatest
	
	:: If the current version matches the latest version available, contine on with normal code.
	if "!CURRENT_VERSION!"=="!LATEST_VERSION!" (
		
		set VERSION_STATUS=---Running Latest Version---
		goto RestOfCode
	)
	
	set VERSION_STATUS=---VERSION v!LATEST_VERSION! AVAILABLE---
	TITLE !SCRIPT_NAME! (v!CURRENT_VERSION!)       !VERSION_STATUS!

:UpdateAvailablePrompt

	cls
	
	ECHO.
	ECHO.
	ECHO * * * * * * * * * * * * *
	ECHO     UPDATE AVAILABLE
	ECHO * * * * * * * * * * * * *
	ECHO.
	ECHO.
	ECHO GITHUB VERSION: !LATEST_VERSION!
	ECHO YOUR VERSION:   !CURRENT_VERSION!
	ECHO.
	ECHO.
	ECHO.
	ECHO  CHOICES:
	ECHO.
	ECHO     A   -   AUTOMATICALLY UPDATE THE BATCH FILE YOU ARE USING NOW.
	ECHO.
	ECHO     M   -   MANUALLY DOWNLOAD THE NEWEST BATCH FILE UPDATE AND USE THAT FILE.
	ECHO.
	ECHO     C   -   CONTINUE USING THIS FILE.
	ECHO.
	ECHO.
	ECHO.
	ECHO NOTE: IF YOU HAVE ATTMEPTED TO AUTOATMICALLY UPDATE ALREADY AND YOU CONTINUE
	ECHO       TO GET THIS UPDATE SCREEN, PLEASE UTILIZE THE MANUAL UPDATE OPTION.
	ECHO.
	ECHO.
	ECHO.

	SET UPDATE_CHOICE=NO_CHOICE_MADE

	SET /p UPDATE_CHOICE=Please type either A, M, or C and press Enter: 
		if /I %UPDATE_CHOICE%==A GOTO AUTO_UPDATE
		if /I %UPDATE_CHOICE%==M GOTO MANUAL_UPDATE
		if /I %UPDATE_CHOICE%==C GOTO RestOfCode
		if /I %UPDATE_CHOICE%==NO_CHOICE_MADE GOTO UpdateAvailablePrompt
			echo.
			echo.
			echo.
			echo.
			echo  %UPDATE_CHOICE% IS NOT A RECOGNIZED RESPONSE. Try again.
			echo.
			GOTO UpdateAvailablePrompt
	
:AUTO_UPDATE
	
	:: Sets the directory that this batch file is currently in.
	SET CUR_BAT_DIR=%~dp0
	
	:: Sets the name of this batch file to this variable.
	SET BAT_NAME=%~nx0
	
	:: Creates the URL to download the latest version of this batch file.
	set FILE_URL=https://github.com/!GH_USER_NAME!/!GH_REPO_NAME!/releases/download/v!LATEST_VERSION!/!BAT_NAME!
	
	:: Sets the download file name to the same name as this batch file.
	set DOWNLOAD_FILE_NAME=!BAT_NAME!

	CLS
	
	ECHO.
	ECHO.
	ECHO * * * * * * * * * * * * * * * * * * * * * * * * * * *
	ECHO.
	ECHO   PRESS ANY KEY TO START THE AUTOMATIC UPDATE.
	ECHO.
	ECHO.
	ECHO   THIS SCREEN WILL CLOSE.
	ECHO.
	ECHO   WAIT 5 SECONDS
	ECHO.
	ECHO   THE NEW UPDATED BATCH FILE WILL START BY ITSELF.
	ECHO.
	ECHO * * * * * * * * * * * * * * * * * * * * * * * * * * *
	ECHO.
	ECHO.
	
	PAUSE
	
	:: Creates a small batch file that will be automatically launched and will:
	::     1) Wait 5 seconds
	::     2) Call the directory of this batch file
	::     3) Will start a batch file by this same name however by the time
	::        that is called, it is likely that this batch file will be
	::        overwritten by the newly downloaded version.
	CD /d "%temp%"
		(
		ECHO @ECHO OFF
		ECHO TIMEOUT 5
		ECHO CD /d "%~dp0"
		ECHO START %~nx0
		ECHO EXIT
		)>TempBatWillDelete.bat
	
	START /MIN TempBatWillDelete.bat
	
	CD /d "!CUR_BAT_DIR!"
		curl -o %DOWNLOAD_FILE_NAME% -L %FILE_URL%
	EXIT

:MANUAL_UPDATE
	
	set GH_LATEST_RLS_PAGE=https://github.com/!GH_USER_NAME!/!GH_REPO_NAME!/releases/latest
	
	CLS
	
	START "" "!GH_LATEST_RLS_PAGE!"
	
	ECHO.
	ECHO.
	ECHO GO TO THE FOLLOWING WEBSITE, DOWNLOAD AND USE THE LATEST VERSION OF %~nx0
	ECHO.
	ECHO    !GH_LATEST_RLS_PAGE!
	ECHO.
	ECHO Press any key to exit...
	
	pause>nul
	
	exit

:UpdateCleanUp

	cls
	
	CD /D "%temp%"
		IF exist "!GH_REPO_NAME!-UDPATE" RD /S /Q "!GH_REPO_NAME!-UDPATE"

:RestOfCode
	
	:: Ensures the directory is back to where this batch file is hosted.
	CD /D "%~dp0"
	
	CLS

:START
mode con: cols=140 lines=45

:: Users of this batch file should put their own faclity ID on the next line.
SET FACILITY_ID=ZZZ

TITLE !SCRIPT_NAME! (v!CURRENT_VERSION!)-!FACILITY_ID!       !VERSION_STATUS!

:HELLO

	CLS
	
	ECHO.
	ECHO.
	ECHO  WHAT WOULD YOU LIKE TO DO?
	ECHO.
	ECHO.
	ECHO      A) CHECK FOR AN UPDATE.
	ECHO.
	ECHO              -You are currently running v%USER_VER%.
	ECHO.
	ECHO              -This option will open the GitHub releases page for this program allowing you to
	ECHO               download the latest version. If you download another version of this BATCH files,
	ECHO               simply delete this file and run the new one.
	ECHO.
	ECHO.
	ECHO      B) !FACILITY_ID! AIRAC RELEASE PREP.
	ECHO.
	ECHO              -Type DETAILS if you want more information on what this function does.
	ECHO                   -If you haven't ran this script before, be sure you read this information.
	ECHO.
	ECHO              -If "!FACILITY_ID!" is not your facility ID, please choose the "CHANGE FACILITY" option.
	ECHO.
	ECHO.
	ECHO      C) CHANGE FACILITY.
	ECHO.
	ECHO              -If your facility is NOT "!FACILITY_ID!", select this option.
	ECHO.
	ECHO.
	ECHO      D) HELP.
	ECHO.
	ECHO              -Delete all previously saved directories and information.
	ECHO.
	ECHO              -Edit the GeoJSON list, renaming list, or the CRC defaults.
	ECHO.
	ECHO.
	
	SET WHAT_T0_DO_CHOICE=NO_INPUT_BY_USER
	
	SET /P WHAT_T0_DO_CHOICE=Type associated letter option or type DETAILS, and press Enter: 
		if /i "!WHAT_T0_DO_CHOICE!"=="A" GOTO CHECKUPDATE
		if /i "!WHAT_T0_DO_CHOICE!"=="B" GOTO AiracReleaseOption
		if /i "!WHAT_T0_DO_CHOICE!"=="DETAILS" GOTO DETAILS
		if /i "!WHAT_T0_DO_CHOICE!"=="C" GOTO SetFacilityID
		if /i "!WHAT_T0_DO_CHOICE!"=="D" GOTO HELP
		ECHO.
		ECHO  *** !WHAT_T0_DO_CHOICE! *** is NOT a recognized response. Try again...
		echo.
		ECHO Press any key to try again...
		PAUSE>NUL
		goto HELLO

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:CHECKUPDATE

START "" https://github.com/KSanders7070/FE-ASSISTANT/releases/latest

GOTO HELLO

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:AiracReleaseOption

	CLS

:PythonInstallCheck
	
	:: Checkst to see if Python is installed and if it isn't, displays an error to the user
	:: instructoring them how to install it along with opening their default web browser up to the install page.
	python --version > nul 2>&1
	
	if %errorlevel% == 0 (
		echo Python is installed and available in PATH.
	) else (
		CALL :PythonNotInstalled
	)
	
	CLS

:LocalAppdataFolder

	:: Creates a folder in the Local Appdata directory of the user if it doesn't already exist
	:: in order to save previously selected directories so the user doesn't have to select the folders each time.
	CD /D "%LocalAppData%"
		IF NOT EXIST "!FACILITY_ID!-FE-ASSISTANT-appdata" MD "!FACILITY_ID!-FE-ASSISTANT-appdata"
		SET FE_ASSISTANT_AppData_DIR=%LocalAppData%\!FACILITY_ID!-FE-ASSISTANT-appdata

:DefaultSetterManagement

	:: Deleting the FEB-DefaultSetter-main folder if previously saved and then making a new setup for running the
	:: Python script in the background without needing the user to have it installed in a specific directory already.
	CD /D "!FE_ASSISTANT_AppData_DIR!"
		IF EXIST "DefaultSetter" RD /S /Q "DefaultSetter"
			MD "DefaultSetter"
				SET DefaultSetter_DIR=!FE_ASSISTANT_AppData_DIR!\DefaultSetter
				
			MD "!DefaultSetter_DIR!\DefaultSetterOutput"
				SET DefaultSetter_Output_DIR=!DefaultSetter_DIR!\DefaultSetterOutput
				
			MD "!DefaultSetter_DIR!\modules"
				SET DefaultSetter_Modules_DIR=!DefaultSetter_DIR!\modules
		
		:: Creates the DefaultSetterPrefs_DIR for later use.
		SET DefaultSetterPrefs_DIR=!FE_ASSISTANT_AppData_DIR!\DefaultSetterPrefs
		CALL :Make_DefaultSetter

:PreferencesHandler

	:: Define the configuration file name
	set "configFile=!FACILITY_ID!-FE-ASSISTANT_config.txt"
	
	:: Initialize variables
	SET "DecombinedALiasFilesDirectory=NOT_SET"
	SET "CombinedALiasFilesDirectory=NOT_SET"
	SET "CombinedAliasFileName=NOT_SET"
	SET "BrowserMsg= "
	SET "CmdMsgLine1= "
	SET "CmdMsgLine2= "

	:: Read configFile and assign the values to the appropriate variables for later use.
	IF EXIST "!configFile!" (
		for /f "tokens=1,* delims==" %%a in ('type "!configFile!"') do (
			set "index1=%%a"
			set "index2=%%b"
				if "!index1!"=="DecombinedALiasFilesDirectory" set "DecombinedALiasFilesDirectory=!index2!"
				if "!index1!"=="CombinedALiasFilesDirectory" set "CombinedALiasFilesDirectory=!index2!"
				if "!index1!"=="CombinedAliasFileName" set "CombinedAliasFileName=!index2!"
		)
	)
	
	:: Checks to see if any data is missing from the variables, thus requiring the user to input some information.
	:: This part is simply to prepare the user for what type of prompts are coming and be prepared to do a one-time setup.
	if "!DecombinedALiasFilesDirectory!"=="NOT_SET" goto MissingInformationMsg
	if "!CombinedALiasFilesDirectory!"=="NOT_SET" goto MissingInformationMsg
	if "!CombinedAliasFileName!"=="NOT_SET" goto MissingInformationMsg
	if not exist "!DefaultSetterPrefs_DIR!" goto MissingInformationMsg

	:: If we have reached this point, all information has been found and saved to the appropriate variables and no warnign is required.
	goto AllIinfoFound

	:MissingInformationMsg
		echo.
		echo.
		echo Looks like either this is your first time setting up this batch file or there was an update and
		echo we are missing some information about your system or facility preferences.
		echo.
		echo The following few prompts will ask you for some information, and then we will store that information
		echo for the next time you run this script so you don't have to do this set-up every time.
		echo.
		echo.
		echo                                 ---------------------
		echo                                        WARNING
		echo                                 ---------------------
		echo.
		echo           READ THE PROMPTS VERY CAREFULLY, as there is very little error checking!
		echo.
		echo.
		
		pause

		CLS

	:: If the configFile didn't have any value for the following variables, that means we need
	:: to ask the user to select the directory or some other input and save it for future use.

	IF "!DecombinedALiasFilesDirectory!"=="NOT_SET" (
			SET "BrowserMsg=Select the Decombined ALias file host folder"
			SET "CmdMsgLine1=Select the folder that hosts the the DECOMBINED alias files meant for editing."
			SET "CmdMsgLine2=This does NOT mean the COMBINED, finalized alias file."
			
			CALL :SelectDirectory
				SET DecombinedALiasFilesDirectory=!SELECTED_DIRECTORY!
				ECHO DecombinedALiasFilesDirectory=!SELECTED_DIRECTORY!>>!configFile!
		)

	IF "!CombinedALiasFilesDirectory!"=="NOT_SET" (
			SET "BrowserMsg=Select the output location for the combined Alias file"
			SET "CmdMsgLine1=Select the folder that you want the finalized combined alias file to be place in."
			SET "CmdMsgLine2=Do NOT make this folder the same folder that hosts the decombined alias files."

			CALL :SelectDirectory
				SET CombinedALiasFilesDirectory=!SELECTED_DIRECTORY!
				ECHO CombinedALiasFilesDirectory=!SELECTED_DIRECTORY!>>!configFile!
		)

	IF "!CombinedAliasFileName!"=="NOT_SET" (
			ECHO.
			ECHO.
			ECHO What do you wish the name of the finalized Alias file to be called?"
			ECHO     Ex: !FACILITY_ID! Alias
			ECHO.
			ECHO.

			SET /P CombinedAliasFileName=Type the name of the file WITHOUT an extension like .txt: 
				SET CombinedAliasFileName=!CombinedAliasFileName!.txt
				ECHO CombinedAliasFileName=!CombinedAliasFileName!>>!configFile!
		)

	:: If the DefaultSetterPrefs folder doesn't exist, make one.
	IF EXIST "!DefaultSetterPrefs_DIR!" goto AllIinfoFound
		CALL :CreateTemplateGeojsonPrefFiles

:: If we have reached this point, all information has been found and saved to the appropriate variables and no warnign is required.
:: Begin normal AIRAC Cycle prepartion processess.
:AllIinfoFound

CLS

:BeginAiracReleasePrep

:FEBOutputDirSelect
	:: Launches Windows Folder Browser window to have the user select the FE-Buddy Output folder.
	:: Note-This directory is not saved in the configFile because it is more likely to change every
	::      AIRAC release and adds a level of human validation.
	SET "BrowserMsg=Select the FE-Buddy Output folder"
	SET "CmdMsgLine1=Select the FE-Buddy Output folder."
	SET "CmdMsgLine2=    Note-This directory is not saved in the configFile for future runs of this script."
			
			CALL :SelectDirectory
				SET FEB_Output_DIR=!SELECTED_DIRECTORY!

:UpdateALiasFIles
	:: Overwrites the decombined alias files with the coorisponding alias files from the FE-Buddy Output folder.
	SET FEB_OUTPUT_ALIAS_DIR=!FEB_Output_DIR!\ALIAS
		IF NOT EXIST "!FEB_OUTPUT_ALIAS_DIR!" (
		
			SET VARIABLE_NAME=FEB_OUTPUT_ALIAS_DIR
			SET DIRECTORY_NOT_FOUND=!FEB_OUTPUT_ALIAS_DIR!
			CALL :DIRECTORY_NOT_FOUND
		)
		
		:: Clears the previously combined alias file or makes a new one if never previously created.
		break>"!CombinedALiasFilesDirectory!\!CombinedAliasFileName!"
		
		CD /D "!DecombinedALiasFilesDirectory!"
			SET FILE_NAME_ENDING=_AIRPORT ISR.txt
				CALL :FindFileName
				TYPE "!FEB_OUTPUT_ALIAS_DIR!\ISR_APT.txt">"!file_name!"
				
			SET FILE_NAME_ENDING=_NAVAID ISR.txt
				CALL :FindFileName
				TYPE "!FEB_OUTPUT_ALIAS_DIR!\ISR_NAVAID.txt">"!file_name!"
				
			SET FILE_NAME_ENDING=_AIRWAY FIXES ALIAS.txt
				CALL :FindFileName
				TYPE "!FEB_OUTPUT_ALIAS_DIR!\AWY_ALIAS.txt">"!file_name!"
				
			SET FILE_NAME_ENDING=_STAR DP FIXES ALIAS.txt
				CALL :FindFileName
				TYPE "!FEB_OUTPUT_ALIAS_DIR!\STAR_DP_Fixes_Alias.txt">"!file_name!"
				
			SET FILE_NAME_ENDING=_FAA CHART RECALL.txt
				CALL :FindFileName
				TYPE "!FEB_OUTPUT_ALIAS_DIR!\FAA_CHART_RECALL.txt">"!file_name!"
				
			SET FILE_NAME_ENDING=_TELEPHONY.txt
				CALL :FindFileName
				TYPE "!FEB_OUTPUT_ALIAS_DIR!\TELEPHONY.txt">"!file_name!"
		
		:: Combine all of the newly updated decombined alias files.
		type "!DecombinedALiasFilesDirectory!\*.txt">>"!CombinedALiasFilesDirectory!\!CombinedAliasFileName!"
			(
				echo.
				echo.
			)>>"!CombinedALiasFilesDirectory!\!CombinedAliasFileName!"

:PrepareVnasGeoJsons

	:: Checks to see if the CRC folder exists inside the FE-Buddy Output folder that the user should have selected.
	SET FEB_CRC_DIR=!FEB_Output_DIR!\CRC
			IF NOT EXIST "!FEB_CRC_DIR!" (
			
				SET VARIABLE_NAME=FEB_CRC_DIR
				SET DIRECTORY_NOT_FOUND=!FEB_CRC_DIR!
				CALL :DIRECTORY_NOT_FOUND
			)
			
	SET FEB_CRC_BATCH_DIR=!FEB_CRC_DIR!\vNAS BATCH UPLOAD
	
		:: If the vNAS BATCH UPLOAD folder already exists, it is likely that this script has already
		:: been ran on that selected folder and will cause issues.
		IF EXIST "!FEB_CRC_BATCH_DIR!" (
			SET DIRECTORY_THAT_ALREADY_EXISTS=FE-Buddy Output \CRC\vNAS BATCH UPLOAD
			CALL :DirectoryAlreadyExists
		)

	:: Creates the vNAS BATCH UPLOAD folder inside the user selected FE-Buddy Output folder \CRC\.
	CD /D "!FEB_CRC_DIR!"
				
		:: Checks to see if there are 21 or more .geojson files in the FE-Buddy \ CRC directory.
		:: If there are less, then it is likely that the script has already been ran on this directory and will cause issues.
		set "fileCount=0"
		for %%i in (*.geojson) do (
			set /a "fileCount+=1"
		)
		if not !fileCount! GEQ 21 CALL :IncorrectGeoJsonAmnt
		
		MD "!FEB_CRC_BATCH_DIR!"

		CD /D "!DefaultSetterPrefs_DIR!"

		:: Sets the file name of the Rename_FE-Buddy_Output_GeoJSONs.txt as a variable.
		if not exist "Rename_FE-Buddy_Output_GeoJSONs.txt" (
			CALL :DefaultSetterPrefEdit
		)
		
		:: Loop through each line in Rename_FE-Buddy_Output_GeoJSONs.txt
		for /f "tokens=1,2 delims=," %%a in ('type "!DefaultSetterPrefs_DIR!\Rename_FE-Buddy_Output_GeoJSONs.txt"') do (
			set "old_filename=%%a"
			set "new_filename=%%b"
		
			:: Rename the file
			ren "!FEB_CRC_DIR!\!old_filename!" "!new_filename!"
		
			:: Move the renamed file to the vNAS BATCH UPLOAD folder
			move "!FEB_CRC_DIR!\!new_filename!" "!FEB_CRC_BATCH_DIR!\"
		)

	:: Runs the setdefaults.py and passes in the directories of where to find the vNAS BATCH UPLOAD files,
	:: where to place the output files, and where the CRC defaults list is located.
	CD /D "!DefaultSetter_DIR!"
		python.exe setdefaults.py --sourcedir "!FEB_CRC_BATCH_DIR!" --outputdir "!DefaultSetter_Output_DIR!" --defaultsfile "!DefaultSetterPrefs_DIR!\CRC_GeoJSON_Defaults.txt"

	:: Move files from DefaultSetting Output folder and back to the vNAS BATCH UPLOAD folder.
	ECHO.
	ECHO.
	ECHO The following were edited and moved back the FE-Buddy vNAS BATCH UPLOAD folder:
	for %%A in ("%DefaultSetter_Output_DIR%\*.geojson") do (
		move "%%A" "%FEB_CRC_BATCH_DIR%"
	)

:EndChecks
	set TextCheckStatus=NOT_SET
	set GeoJsonsCheckStatus=NOT_SET
	
	:: Check if the .txt file exists in CombinedAliasFilesDirectory
	:: If no .txt files found, set the TextCheckStatus variable to Failed.
	if not exist "%CombinedAliasFilesDirectory%\*.txt" set TextCheckStatus=Failed
	
	:: Count the number of .geojson files in FEB_CRC_BATCH_DIR
	for /f %%A in ('dir /b /a-d "%FEB_CRC_BATCH_DIR%\*.geojson" ^| find /c /v ""') do set "geojson_count=%%A"
	
		:: Check if there are at least 21 .geojson files
		:: If less than 21, sets the GeoJsonsCheckStatus variable to failed.
		if %geojson_count% LSS 21 set GeoJsonsCheckStatus=Failed
	
	:: If either check or both failed, goes to EndChecksFailed function to notify the user.
	If "!TextCheckStatus!"=="Failed" CALL :EndChecksFailed
	If "!GeoJsonsCheckStatus!"=="Failed" CALL :EndChecksFailed

ECHO.
ECHO.
ECHO  ---------
ECHO    DONE
ECHO  ---------
ECHO.
ECHO.
ECHO Press any key do the following:
ECHO.
ECHO      -Open a web browser tab to the virtualnas.net page where you may upload the newly combined alias file.
ECHO.
ECHO      -Open a web browser tab to the virtualnas.net/video-maps page where you may upload the newly edited
ECHO       geojsons using the BATCH UPLOAD option.
ECHO.
ECHO      -Open the file browswer to the folder hosting the newly combined alias file for easier drag/drop or reference.
ECHO.
ECHO      -Open the file browswer to the folder hosting the newly edited geojsons for easier drag/drop or reference.
ECHO.
ECHO      -Close this Command Prompt window.
ECHO.
ECHO.
ECHO Note-If you don't wish for these to open, you may simply click the red X to close this window.
ECHO.
ECHO.
ECHO.

PAUSE>NUL

START "" "https://data-admin.virtualnas.net/"
START "" "https://data-admin.virtualnas.net/video-maps"
START /B /WAIT explorer.exe "!FEB_CRC_BATCH_DIR!" "!CombinedALiasFilesDirectory!"

PAUSE>NUL

EXIT


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:FunctionsToBeCalled


:SelectDirectory

	:: Resets the SELECTED_DIRECTORY variable for error checking later.
	set SELECTED_DIRECTORY=NOT_DEFINED
	
	CLS
	ECHO.
	ECHO.
	ECHO !CmdMsgLine1!
	ECHO !CmdMsgLine2!
	ECHO.
	ECHO.

	:: Launches Windows Folder Browser window to have the user select a directory and then saves that directory to the "SELECTED_DIRECTORY" variable.
	set "psCommand=(New-Object -ComObject Shell.Application).BrowseForFolder(0, '!BrowserMsg!', 0, 0).Self.Path"
		for /f "usebackq delims=" %%I in (`powershell -command "%psCommand%"`) do set "SELECTED_DIRECTORY=%%I"

		:: If user clicked cancel or nothing at all, it exits the Command Prompt window.
		IF "!SELECTED_DIRECTORY!"=="NOT_DEFINED" EXIT
	
		CLS
	
		SET "BrowserMsg= "
		SET "CmdMsgLine1= "
		SET "CmdMsgLine2= "
	
		GOTO :EOF

:FindFileName
	
	:: Finds the whole file name for a given file name ending.
	for /f "delims=" %%G in ('dir /b ^| findstr /L /C:"!FILE_NAME_ENDING!"') do SET file_name=%%G
		
	GOTO :EOF

:DIRECTORY_NOT_FOUND

	:: Displays an error message if the directory that is trying to be saved to a variable does not exist.
	ECHO.
	ECHO.
	ECHO               -------
	ECHO                ERROR
	ECHO               -------
	ECHO.
	ECHO Setting variable: !VARIABLE_NAME!
	ECHO Could not find directory: !DIRECTORY_NOT_FOUND!
	ECHO.
	ECHO If you were running an AIRAC release, it may be a good idea to rerun FE-Buddy
	ECHO prior to starting this batch file again.
	ECHO.
	ECHO Press any key to end this script...
	PAUSE>nul
	EXIT
		
	GOTO :EOF

:DETAILS

	mode con: cols=140 lines=70

	CLS
	
	ECHO.
	ECHO.
	ECHO What does the "The AIRAC Release Prep" do?
	ECHO.
	ECHO 	-Takes the individual Alias files from the FE-Buddy Output folder and overwrites
	ECHO 	 the appropriate corresponding files in your own "Decombined alias" file directory.
	ECHO 	 It will then combine all of the decombined alias files into one alias file in
	ECHO 	 alphanumeric order.
	ECHO.
	ECHO 		Example decombined alias files in the decombined directory:
	ECHO 			*_EVERYTHING ELSE.txt
	ECHO 			*_FAA CHART RECALL.txt
	ECHO 			*_NAVAID ISR.txt
	ECHO 			*_AIRPORT ISR.txt
	ECHO 			*_AIRWAY FIXES ALIAS.txt
	ECHO 			*_STAR DP FIXES ALIAS.txt
	ECHO 			*_AIRPORT_SPECIFIC_ISR.txt
	ECHO 			*_TELEPHONY.txt
	ECHO.	
	ECHO 		Note how they have a prefixing number and ends with an underscore; This is required formatting.
	ECHO 		The prefixing number can be as small or large as you like but the name of the file after the
	ECHO 		underscore is REQUIRED to stay the same as it is in this example.
	ECHO 		The names of the files can be changed if you alter the code within this script.
	ECHO        Another requirement for this part to work correctly is that there must be at least one blank line
	ECHO        at the end of each of decombined alias files.
	ECHO.
	ECHO. 	 
	ECHO 	 -Takes following CRC .GeoJSON files, grabs the ones you have defined in the renaming preference .txt file,
	ECHO      will rename them to what you want, add the CRC defaults that you have defined, and place them into a sub-folder
	ECHO      labeled "vNAS BATCH UPLOAD" in the Selected FE-Buddy Output folder \CRC:
	ECHO.  
	ECHO 		APT_symbols
	ECHO 		APT_text
	ECHO.  
	ECHO 		ARTCC BOUNDARIES-HIGH_lines
	ECHO 		ARTCC BOUNDARIES-LOW_lines
	ECHO.  
	ECHO 		AWY-HIGH_lines(DME Cutoff)
	ECHO 		AWY-HIGH_lines
	ECHO 		AWY-HIGH_symbols
	ECHO 		AWY-HIGH_text
	ECHO.  
	ECHO 		AWY-LOW_lines(DME Cutoff)
	ECHO 		AWY-LOW_lines
	ECHO 		AWY-LOW_symbols
	ECHO 		AWY-LOW_text
	ECHO.  
	ECHO 		FIX_symbols
	ECHO 		FIX_text
	ECHO.  
	ECHO 		NDB_symbols
	ECHO 		NDB_text
	ECHO.  
	ECHO 		RWY_lines
	ECHO.  
	ECHO 		VOR_symbols
	ECHO 		VOR_text
	ECHO.  
	ECHO 		WX STATIONS_symbols
	ECHO 		WX STATIONS_text
	ECHO.
	ECHO.
	ECHO 	When the script is done, you should then be able to go to vNAS Admin site, upload the combined
	ECHO 	alias file and then do a BATCH Upload of all the .GeoJSONs found in the vNAS BATCH Upload folder.
	ECHO.
	ECHO.
	ECHO Press any key to return to the main menu...
	
	PAUSE>NUL
	
	mode con: cols=140 lines=45

	GOTO HELLO

:SetFacilityID

	CLS
	
	ECHO.
	ECHO.
	ECHO To set the facility ID to your own:
	ECHO.
	ECHO 	1) Close the CMD Prompt window.
	ECHO.
	ECHO 	2) Right click on the batch file and click EDIT.
	ECHO.
	ECHO 	3) Find the line of code near the top that says "SET FACILITY_ID=".
	ECHO            Note-There may be information after the equals sign.
	ECHO.
	ECHO 	4) Replace the information after the equals sign with your own facility ID.
	ECHO            Ex (without quotes): "SET FACILITY_ID=ZZZ"
	ECHO.
	ECHO 	5) Save the file and relaunch the batch file.
	ECHO.
	ECHO.
	
	PAUSE
	
	goto HELLO

:HELP
	
	CLS
	
	ECHO.
	ECHO.
	ECHO WHAT DO YOU NEED HELP WITH?
	ECHO.
	ECHO    A) Resetting all preferences; Making it like the first time you ran this script.
	ECHO            -Be careful, as this will also delete your CRC GeoJSON Preferences and data.
	ECHO.
	ECHO    B) I want to edit the CRC GeoJSON Preferences and data.
	ECHO.
	ECHO.
	
	SET RESET_QUERY=NO_INPUT_BY_USER
	
	SET /P HELP_QUERY=To reset preferences type Y, and press Enter: 
		if /i "!HELP_QUERY!"=="A" GOTO HelpResetPrefs
		if /i "!HELP_QUERY!"=="B" GOTO HelpEditGeoJSONprefs

:HelpResetPrefs

	CLS
	
	CD /D "%LocalAppdata%"
	
	ECHO.
	ECHO.
	ECHO Typing "Y" without quotes will delete all previously
	ECHO saved data such as directories and other preferences.
	ECHO.
	ECHO 	-Any other action will just return you to the main menu.
	ECHO.
	
	:: If user types Y (regardless of case), the !FACILITY_ID!-FE-ASSISTANT-appdata
	:: folder from %LocalAppdata% and all contents will be removed which will
	:: require the user to set it up again on the next run of the AIRAC Release option.
	:: Typing anything else or nothing at all will return to the beginning of this scrip.
	SET RESET_QUERY=NO_INPUT_BY_USER
	
	SET /P RESET_QUERY=To reset preferences type Y, and press Enter: 
		if /i "!RESET_QUERY!"=="Y" (

			RD /S /Q !FACILITY_ID!-FE-ASSISTANT-appdata
			
			ECHO.
			ECHO.
			ECHO Your preferences has been reset.
			ECHO The next time you run the AIRAC release option,
			ECHO it will prompt you to setup your preferences again.
			ECHO.
			ECHO.
			
			PAUSE
		)
		
	CLS
	
	GOTO HELLO

:HelpEditGeoJSONprefs

	CLS
	
	ECHO.
	ECHO.
	
	if exist "%LocalAppData%\!FACILITY_ID!-FE-ASSISTANT-appdata\DefaultSetterPrefs" (
		ECHO Press any key to open the directory with your CRC GeoJSON preference files...
		
		PAUSE>NUL
		
		START /B /WAIT explorer.exe "%LocalAppData%\!FACILITY_ID!-FE-ASSISTANT-appdata\DefaultSetterPrefs"
		
		EXIT
	) ELSE (
		ECHO Looks like you do not yet have Default Setter Pref settings yet for !FACILITY_ID!.
		ECHO.
		ECHO Contact the developer if you still have issues after troubleshooting.
		ECHO.
		ECHO.
		ECHO Press any key to return to the main menu...
		
		PAUSE>NUL
		
		GOTO HELLO
	)

:PythonNotInstalled
	
	:: Checks the users system to see if it is 32 or 64 bit for later use.
	set "ProgramFilesPath=%ProgramFiles(x86)%"

	if "%ProgramFilesPath%"=="" (
		SET BIT=32
	) else (
		SET BIT=64
	)
	
	CLS
	
	START "" https://www.python.org/downloads/windows/
	
	ECHO.
	ECHO.
	ECHO               -------
	ECHO                ERROR
	ECHO               -------
	ECHO.
	ECHO Python does not appear to be installed on your computer.
	ECHO.
	ECHO Python is required to perform certain parts of this process.
	ECHO Please go to https://www.python.org/downloads/windows/ and download the latest release and install in.
	ECHO      -This page should have also opened in your default webbrowser.
	ECHO.
	ECHO   It is recommended to download the "Windows installer (!BIT!-bit)"
	ECHO.
	ECHO.
	ECHO IMPORTANT:
	ECHO      When you install Python, be sure "ADD PYTHON TO PATH" is checked in the installation
	ECHO      wizard prior to selecting "INSTALL NOW".
	ECHO.
	ECHO Press any key to exit...
	
	PAUSE>NUL
	
	exit

:Make_DefaultSetter

	:: SPECIAL THANKS to Kyle Rodgers (MisterRodg) for creating this python file as a temp fix for setting Defaults into the FE-Buddy output CRC GeoJSON files!
	::      Check out his GitHub here: https://github.com/misterrodg
	::            Specific Default Setter repo: https://github.com/misterrodg/FEB-DefaultSetter
	
	:: Creates the setdefaults.py file in the primary DefaultSetter directory.
	(
		ECHO import argparse
		ECHO.
		ECHO from modules.FEBDefaults import FEBDefaults
		ECHO from modules.FileHandler import FileHandler
		ECHO from modules.GeoJSON import GeoJSON
		ECHO.
		ECHO.
		ECHO def processDefaults^(filePath^):
		ECHO     print^("\nGetting Defaults from FEB Defaults File"^)
		ECHO     febDefaults = FEBDefaults^(filePath^)
		ECHO     return febDefaults.defaults
		ECHO.
		ECHO.
		ECHO def processFiles^(sourceDir, useSourceLocal, outputDir, useOutputLocal, defaultsArray^):
		ECHO     fileHandler = FileHandler^(^)
		ECHO     fileHandler.checkDir^(outputDir, useOutputLocal^)
		ECHO     fileHandler.deleteAllInSubdir^(".geojson", outputDir, useOutputLocal^)
		ECHO     fileList = fileHandler.searchForType^(".geojson", sourceDir, useSourceLocal^)
		ECHO     numFiles = str^(len^(fileList^)^)
		ECHO     print^(f"Found {numFiles} .geojson files in {sourceDir}"^)
		ECHO     fileCount = 0
		ECHO     for f in fileList:
		ECHO         fileData = fileHandler.splitFolderFile^(f, sourceDir^)
		ECHO         folder = fileData[0]
		ECHO         fileName = fileData[1].replace^(".geojson", ""^)
		ECHO         defaults = next^(
		ECHO             ^(item for item in defaultsArray if item["fileName"] == fileData[1]^), False
		ECHO         ^)
		ECHO         if defaults:
		ECHO             print^(f^"[{str^(fileCount + 1^)}/{numFiles}] Processing {fileName}.geojson^"^)
		ECHO             GeoJSON^(sourceDir, outputDir, fileName, defaults["default"]^)
		ECHO             fileCount += 1
		ECHO     print^("\n>>>>> Defaults are now set. Files located in " + outputDir + "<<<<<\n"^)
		ECHO.
		ECHO.
		ECHO def main^(^):
		ECHO     # Set up Defaults
		ECHO     SOURCE_DIR = "feb_source"
		ECHO     OUTPUT_DIR = "output"
		ECHO     FEB_DEFAULTS = "vNAS_Defaults.txt"
		ECHO     # Set up Argmument Handling
		ECHO     parser = argparse.ArgumentParser^(description="FEB-DefaultSetter"^)
		ECHO     parser.add_argument^(
		ECHO         "--sourcedir", type=str, help="The path to the source directory."
		ECHO     ^)
		ECHO     parser.add_argument^(
		ECHO         "--outputdir", type=str, help="The path to the output directory."
		ECHO     ^)
		ECHO     parser.add_argument^(
		ECHO         "--defaultsfile", type=str, help="The filename of the FEB Defaults File."
		ECHO     ^)
		ECHO     args = parser.parse_args^(^)
		ECHO     sourceDir = SOURCE_DIR
		ECHO     useSourceLocal = True
		ECHO     outputDir = OUTPUT_DIR
		ECHO     useOutputLocal = True
		ECHO     febDefaults = "./" + sourceDir + "/" + FEB_DEFAULTS
		ECHO     if args.sourcedir ^^!= None:
		ECHO         sourceDir = args.sourcedir
		ECHO         useSourceLocal = False
		ECHO     if args.outputdir ^^!= None:
		ECHO         outputDir = args.outputdir
		ECHO         useOutputLocal = False
		ECHO     febDefaults = args.defaultsfile if args.defaultsfile ^^!= None else febDefaults
		ECHO     print^("\nInitializing DefaultSetter"^)
		ECHO     # Read the defaults from the FEB List
		ECHO     defaultsArray = processDefaults^(febDefaults^)
		ECHO     # Process the files from the FEB List
		ECHO     processFiles^(sourceDir, useSourceLocal, outputDir, useOutputLocal, defaultsArray^)
		ECHO.
		ECHO.
		ECHO if __name__ == "__main__":
		ECHO     main^(^)
	)>"!DefaultSetter_DIR!\setdefaults.py"

	:: Creates the FEBDefaults.py file in the primary DefaultSetter\modules directory.
	(
		ECHO class FEBDefaults:
		ECHO     def __init__^(self, filePath^):
		ECHO         self.defaultFilePath = filePath
		ECHO         self.defaults = []
		ECHO         self.read^(^)
		ECHO.
		ECHO     def add^(self, fileName, default^):
		ECHO         newItem = {"fileName": fileName, "default": default}
		ECHO         self.defaults.append^(newItem^)
		ECHO.
		ECHO     def read^(self^):
		ECHO         currentFile = ""
		ECHO         currentDefaults = ""
		ECHO         with open^(self.defaultFilePath^) as lines:
		ECHO             for line in lines:
		ECHO                 if line.endswith^(".geojson\n"^):
		ECHO                     currentFile = line.strip^(^)
		ECHO                 if line.startswith^('{"type":"Feature",'^):
		ECHO                     withoutComma = line.rstrip^(",\n"^)
		ECHO                     currentDefaults = withoutComma.strip^(^)
		ECHO                 if currentFile ^^!= "" and currentDefaults ^^!= "":
		ECHO                     self.add^(currentFile, currentDefaults^)
		ECHO                     currentFile = ""
		ECHO                     currentDefaults = ""
		ECHO.
		ECHO.
	)>"!DefaultSetter_Modules_DIR!\FEBDefaults.py"
	
	:: Creates the FileHandler.py file in the primary DefaultSetter\modules directory.
	(
		ECHO import os
		ECHO.
		ECHO.
		ECHO class FileHandler:
		ECHO     def __init__^(self^):
		ECHO         self.localPath = os.getcwd^(^)
		ECHO.
		ECHO     def checkDir^(self, subdirPath, useLocal=True^):
		ECHO         result = False
		ECHO         dirPath = self.localPath + "/" + subdirPath if useLocal == True else subdirPath
		ECHO         os.makedirs^(name=dirPath, exist_ok=True^)
		ECHO         if os.path.exists^(dirPath^):
		ECHO             result = True
		ECHO         return result
		ECHO.
		ECHO     def deleteAllInSubdir^(self, fileType, subdirPath=None, useLocal=True^):
		ECHO         # As it stands, this will only ever delete items in the named subfolder where this script runs.
		ECHO         # Altering this function could cause it to delete the entire contents of other folders where you wouldn't want it to.
		ECHO         # Alter this at your own risk.
		ECHO         if subdirPath ^^!= None:
		ECHO             deletePath = ^(
		ECHO                 self.localPath + "/" + subdirPath if useLocal == True else subdirPath
		ECHO             ^)
		ECHO             for f in os.listdir^(deletePath^):
		ECHO                 if f.endswith^(fileType^):
		ECHO                     os.remove^(os.path.join^(deletePath, f^)^)
		ECHO.
		ECHO     def searchForType^(self, fileType, subdirPath=None, useLocal=True^):
		ECHO         result = []
		ECHO         searchPath = self.localPath if useLocal == True else subdirPath
		ECHO         if subdirPath ^^!= None and useLocal == True:
		ECHO             searchPath += "/" + subdirPath
		ECHO         for dirpath, subdirs, files in os.walk^(searchPath^):
		ECHO             result.extend^(
		ECHO                 os.path.join^(dirpath, f^) for f in files if f.endswith^(fileType^)
		ECHO             ^)
		ECHO         return result
		ECHO.
		ECHO     def splitFolderFile^(self, fullPath, subdirPath=None^):
		ECHO         result = []
		ECHO         split = os.path.split^(fullPath^)
		ECHO         searchPath = self.localPath
		ECHO         if subdirPath ^^!= None:
		ECHO             searchPath += "/" + subdirPath
		ECHO         result.append^(split[0].replace^(searchPath, ""^)^)
		ECHO         result.append^(split[1]^)
		ECHO         return result
		ECHO.
	)>"!DefaultSetter_Modules_DIR!\FileHandler.py"
	
	:: Creates the GeoJSON.py file in the primary DefaultSetter\modules directory.
	(
		ECHO import json
		ECHO.
		ECHO.
		ECHO class GeoJSON:
		ECHO     def __init__^(self, sourceFolder, outputFolder, fileName, defaults^):
		ECHO         self.fileName = sourceFolder + "/" + fileName + ".geojson"
		ECHO         self.outputFileName = outputFolder + "/" + fileName + ".geojson"
		ECHO         self.defaults = json.loads^(defaults^)
		ECHO         self.read^(^)
		ECHO.
		ECHO     def read^(self^):
		ECHO         with open^(self.fileName, "r"^) as geoJsonFile:
		ECHO             data = json.load^(geoJsonFile^)
		ECHO             data["features"].insert^(0, self.defaults^)
		ECHO             with open^(self.outputFileName, "w"^) as outputFile:
		ECHO                 json.dump^(data, outputFile, separators=^(",", ":"^), indent=None^)
		ECHO.
	)>"!DefaultSetter_Modules_DIR!\GeoJSON.py"

	GOTO :EOF

:DirectoryAlreadyExists

	CLS
				
	ECHO.
	ECHO.
	ECHO                            ---------
	ECHO                             WARNING
	ECHO                            ---------
	ECHO.
	ECHO There is already a directory: !DIRECTORY_THAT_ALREADY_EXISTS!
	ECHO in the location you selected, giving the impression that this script has
	ECHO already be ran for this folder and would have issues.
	ECHO.
	ECHO Please close this CMD prompt, run FE-Buddy again and get a new set of
	ECHO data before running this script again.
	ECHO.
	ECHO Press any key to close this CMD Prompt...
	
	PAUSE>NUL
	
	EXIT

:DefaultSetterPrefEdit

	CLS
	
	ECHO.
	ECHO.
	ECHO                            ---------
	ECHO                             WARNING
	ECHO                            ---------
	ECHO.
	ECHO One of the following files were not found in the following directory:
	ECHO.
	ECHO      !DefaultSetterPrefs_DIR!
	ECHO.
	ECHO      -CRC_GeoJSON_Defaults.txt
	ECHO       or
	ECHO      -Rename_FE-Buddy_Output_GeoJSONs.txt
	ECHO.
	ECHO Press any key to launch the browswer where this file should be...
	
	pause>nul
	
	start /B /WAIT explorer.exe "!DefaultSetterPrefs_DIR!"
	
	exit

:FILE_TO_RENAME_NOT_FOUND
	
	:: Then it will write the three prefs files for the DefaultSetter pythong with generic data allowing the user to edit it at the end.
	
	:: Dev note: Do not place the following line into a "IF NOT EXIST", as the if statement does not play well with the escaped characters later on.
	CLS
	
	ECHO.
	ECHO.
	ECHO                            ---------
	ECHO                             WARNING
	ECHO                            ---------
	ECHO.
	ECHO You wanted to change the name of "!FEBuddy_FILE_NAME!"
	ECHO to "!FACILITY_DISIRED_NAME!" but that file was not found in
	ECHO the FEB_CRC_BATCH_DIR:
	ECHO      !FEB_CRC_BATCH_DIR!
	ECHO.
	ECHO Press any key to launch the browswer where you can edit the renaming file...
	
	pause>nul
	
	start /B /WAIT explorer.exe "!DefaultSetterPrefs_DIR!"
	
	exit

:CreateTemplateGeojsonPrefFiles
	
	set GEOJSON_EXTENSION=.geojson
		
	MD "!DefaultSetterPrefs_DIR!"
	(
		ECHO APT_symbols!GEOJSON_EXTENSION!,RENAMED_ZZZ_APT_symbols!GEOJSON_EXTENSION! 
		ECHO APT_text!GEOJSON_EXTENSION!,RENAMED_ZZZ_APT_text!GEOJSON_EXTENSION!
		ECHO ARTCC BOUNDARIES-HIGH_lines!GEOJSON_EXTENSION!,RENAMED_ZZZ_ARTCC BOUNDARIES-HIGH_lines!GEOJSON_EXTENSION!
		ECHO ARTCC BOUNDARIES-LOW_lines!GEOJSON_EXTENSION!,RENAMED_ZZZ_ARTCC BOUNDARIES-LOW_lines!GEOJSON_EXTENSION!
		ECHO AWY-HIGH_lines^(DME Cutoff^)!GEOJSON_EXTENSION!,RENAMED_ZZZ_AWY-HIGH_lines^(DME Cutoff^)!GEOJSON_EXTENSION!
		ECHO AWY-HIGH_lines!GEOJSON_EXTENSION!,RENAMED_ZZZ_AWY-HIGH_lines!GEOJSON_EXTENSION!
		ECHO AWY-HIGH_symbols!GEOJSON_EXTENSION!,RENAMED_ZZZ_AWY-HIGH_symbols!GEOJSON_EXTENSION!
		ECHO AWY-HIGH_text!GEOJSON_EXTENSION!,RENAMED_ZZZ_AWY-HIGH_text!GEOJSON_EXTENSION!
		ECHO AWY-LOW_lines^(DME Cutoff^)!GEOJSON_EXTENSION!,RENAMED_ZZZ_AWY-LOW_lines^(DME Cutoff^)!GEOJSON_EXTENSION!
		ECHO AWY-LOW_lines!GEOJSON_EXTENSION!,RENAMED_ZZZ_AWY-LOW_lines!GEOJSON_EXTENSION!
		ECHO AWY-LOW_symbols!GEOJSON_EXTENSION!,RENAMED_ZZZ_AWY-LOW_symbols!GEOJSON_EXTENSION!
		ECHO AWY-LOW_text!GEOJSON_EXTENSION!,RENAMED_ZZZ_AWY-LOW_text!GEOJSON_EXTENSION!
		ECHO FIX_symbols!GEOJSON_EXTENSION!,RENAMED_ZZZ_FIX_symbols!GEOJSON_EXTENSION!
		ECHO FIX_text!GEOJSON_EXTENSION!,RENAMED_ZZZ_FIX_text!GEOJSON_EXTENSION!
		ECHO NDB_symbols!GEOJSON_EXTENSION!,RENAMED_ZZZ_NDB_symbols!GEOJSON_EXTENSION!
		ECHO NDB_text!GEOJSON_EXTENSION!,RENAMED_ZZZ_NDB_text!GEOJSON_EXTENSION!
		ECHO RWY_lines!GEOJSON_EXTENSION!,RENAMED_ZZZ_RWY_lines!GEOJSON_EXTENSION!
		ECHO VOR_symbols!GEOJSON_EXTENSION!,RENAMED_ZZZ_VOR_symbols!GEOJSON_EXTENSION!
		ECHO VOR_text!GEOJSON_EXTENSION!,RENAMED_ZZZ_VOR_text!GEOJSON_EXTENSION!
		ECHO WX STATIONS_symbols!GEOJSON_EXTENSION!,RENAMED_ZZZ_WX STATIONS_symbols!GEOJSON_EXTENSION!
		ECHO WX STATIONS_text!GEOJSON_EXTENSION!,RENAMED_ZZZ_WX STATIONS_text!GEOJSON_EXTENSION!
	)>"!DefaultSetterPrefs_DIR!\Rename_FE-Buddy_Output_GeoJSONs.txt"

	(
		ECHO RENAMED_ZZZ_APT_symbols!GEOJSON_EXTENSION!
		ECHO ^{"type":"Feature","geometry":^{"type":"Point","coordinates":^[90.0,180.0^]^},"properties":^{"isSymbolDefaults":true,"bcg":40,"filters":^[40^],"style":"airwayIntersections","size":1^}^},
		ECHO.
		ECHO RENAMED_ZZZ_APT_text!GEOJSON_EXTENSION!
		ECHO ^{"type":"Feature","geometry":^{"type":"Point","coordinates":^[90.0,180.0^]^},"properties":^{"isTextDefaults":true,"bcg":40,"filters":^[40^],"size":1,"underline":false,"opaque":false,"xOffset":12,"yOffset":0^}^},
		ECHO.
		ECHO RENAMED_ZZZ_ARTCC BOUNDARIES-HIGH_lines!GEOJSON_EXTENSION!
		ECHO ^{"type":"Feature","geometry":^{"type":"Point","coordinates":^[90.0,180.0^]^},"properties":^{"isLineDefaults":true,"bcg":40,"filters":^[40^],"style":"Solid","thickness":1^}^},
		ECHO.
		ECHO RENAMED_ZZZ_ARTCC BOUNDARIES-LOW_lines!GEOJSON_EXTENSION!
		ECHO ^{"type":"Feature","geometry":^{"type":"Point","coordinates":^[90.0,180.0^]^},"properties":^{"isLineDefaults":true,"bcg":40,"filters":^[40^],"style":"Solid","thickness":1^}^},
		ECHO.
		ECHO RENAMED_ZZZ_AWY-HIGH_lines^(DME Cutoff^)!GEOJSON_EXTENSION!
		ECHO ^{"type":"Feature","geometry":^{"type":"Point","coordinates":^[90.0,180.0^]^},"properties":^{"isLineDefaults":true,"bcg":40,"filters":^[40^],"style":"Solid","thickness":1^}^},
		ECHO.
		ECHO RENAMED_ZZZ_AWY-HIGH_lines!GEOJSON_EXTENSION!
		ECHO ^{"type":"Feature","geometry":^{"type":"Point","coordinates":^[90.0,180.0^]^},"properties":^{"isLineDefaults":true,"bcg":40,"filters":^[40^],"style":"Solid","thickness":1^}^},
		ECHO.
		ECHO RENAMED_ZZZ_AWY-HIGH_symbols!GEOJSON_EXTENSION!
		ECHO ^{"type":"Feature","geometry":^{"type":"Point","coordinates":^[90.0,180.0^]^},"properties":^{"isSymbolDefaults":true,"bcg":40,"filters":^[40^],"style":"airwayIntersections","size":1^}^},
		ECHO.
		ECHO RENAMED_ZZZ_AWY-HIGH_text!GEOJSON_EXTENSION!
		ECHO ^{"type":"Feature","geometry":^{"type":"Point","coordinates":^[90.0,180.0^]^},"properties":^{"isTextDefaults":true,"bcg":40,"filters":^[40^],"size":1,"underline":false,"opaque":false,"xOffset":12,"yOffset":0^}^},
		ECHO.
		ECHO RENAMED_ZZZ_AWY-LOW_lines^(DME Cutoff^)!GEOJSON_EXTENSION!
		ECHO ^{"type":"Feature","geometry":^{"type":"Point","coordinates":^[90.0,180.0^]^},"properties":^{"isLineDefaults":true,"bcg":40,"filters":^[40^],"style":"Solid","thickness":1^}^},
		ECHO.
		ECHO RENAMED_ZZZ_AWY-LOW_lines!GEOJSON_EXTENSION!
		ECHO ^{"type":"Feature","geometry":^{"type":"Point","coordinates":^[90.0,180.0^]^},"properties":^{"isLineDefaults":true,"bcg":40,"filters":^[40^],"style":"Solid","thickness":1^}^},
		ECHO.
		ECHO RENAMED_ZZZ_AWY-LOW_symbols!GEOJSON_EXTENSION!
		ECHO ^{"type":"Feature","geometry":^{"type":"Point","coordinates":^[90.0,180.0^]^},"properties":^{"isSymbolDefaults":true,"bcg":40,"filters":^[40^],"style":"airwayIntersections","size":1^}^},
		ECHO.
		ECHO RENAMED_ZZZ_AWY-LOW_text!GEOJSON_EXTENSION!
		ECHO ^{"type":"Feature","geometry":^{"type":"Point","coordinates":^[90.0,180.0^]^},"properties":^{"isTextDefaults":true,"bcg":40,"filters":^[40^],"size":1,"underline":false,"opaque":false,"xOffset":12,"yOffset":0^}^},
		ECHO.
		ECHO RENAMED_ZZZ_FIX_symbols!GEOJSON_EXTENSION!
		ECHO ^{"type":"Feature","geometry":^{"type":"Point","coordinates":^[90.0,180.0^]^},"properties":^{"isSymbolDefaults":true,"bcg":40,"filters":^[40^],"style":"airwayIntersections","size":1^}^},
		ECHO.
		ECHO RENAMED_ZZZ_FIX_text!GEOJSON_EXTENSION!
		ECHO ^{"type":"Feature","geometry":^{"type":"Point","coordinates":^[90.0,180.0^]^},"properties":^{"isTextDefaults":true,"bcg":40,"filters":^[40^],"size":1,"underline":false,"opaque":false,"xOffset":12,"yOffset":0^}^},
		ECHO.
		ECHO RENAMED_ZZZ_NDB_symbols!GEOJSON_EXTENSION!
		ECHO ^{"type":"Feature","geometry":^{"type":"Point","coordinates":^[90.0,180.0^]^},"properties":^{"isSymbolDefaults":true,"bcg":40,"filters":^[40^],"style":"airwayIntersections","size":1^}^},
		ECHO.
		ECHO RENAMED_ZZZ_NDB_text!GEOJSON_EXTENSION!
		ECHO ^{"type":"Feature","geometry":^{"type":"Point","coordinates":^[90.0,180.0^]^},"properties":^{"isTextDefaults":true,"bcg":40,"filters":^[40^],"size":1,"underline":false,"opaque":false,"xOffset":12,"yOffset":0^}^},
		ECHO.
		ECHO RENAMED_ZZZ_RWY_lines!GEOJSON_EXTENSION!
		ECHO ^{"type":"Feature","geometry":^{"type":"Point","coordinates":^[90.0,180.0^]^},"properties":^{"isLineDefaults":true,"bcg":40,"filters":^[40^],"style":"Solid","thickness":1^}^},
		ECHO.
		ECHO RENAMED_ZZZ_VOR_symbols!GEOJSON_EXTENSION!
		ECHO ^{"type":"Feature","geometry":^{"type":"Point","coordinates":^[90.0,180.0^]^},"properties":^{"isSymbolDefaults":true,"bcg":40,"filters":^[40^],"style":"airwayIntersections","size":1^}^},
		ECHO.
		ECHO RENAMED_ZZZ_VOR_text!GEOJSON_EXTENSION!
		ECHO ^{"type":"Feature","geometry":^{"type":"Point","coordinates":^[90.0,180.0^]^},"properties":^{"isTextDefaults":true,"bcg":40,"filters":^[40^],"size":1,"underline":false,"opaque":false,"xOffset":12,"yOffset":0^}^},
		ECHO.
		ECHO RENAMED_ZZZ_WX STATIONS_symbols!GEOJSON_EXTENSION!
		ECHO ^{"type":"Feature","geometry":^{"type":"Point","coordinates":^[90.0,180.0^]^},"properties":^{"isSymbolDefaults":true,"bcg":40,"filters":^[40^],"style":"airwayIntersections","size":1^}^},
		ECHO.
		ECHO RENAMED_ZZZ_WX STATIONS_text!GEOJSON_EXTENSION!
		ECHO ^{"type":"Feature","geometry":^{"type":"Point","coordinates":^[90.0,180.0^]^},"properties":^{"isTextDefaults":true,"bcg":40,"filters":^[40^],"size":1,"underline":false,"opaque":false,"xOffset":12,"yOffset":0^}^},
	)>"!DefaultSetterPrefs_DIR!\CRC_GeoJSON_Defaults.txt"

	CLS
	
	ECHO.
	ECHO.
	ECHO 2 files have been created for you here:
	ECHO !DefaultSetterPrefs_DIR!
	ECHO.
	ECHO.
	ECHO      "Rename_FE-Buddy_Output_GeoJSONs.txt"
	ECHO           -This file lists multiple file names that FE-Buddy Outputs into the CRC folder.
	ECHO            After that file name you will see a comma then another file name.
	ECHO            That file name is what the file will be renamed to.
	ECHO.
	ECHO           -Go into this file and delete lines that contain file names you will not want to grab from
	ECHO            FE-Buddy's Output CRC folder.
	ECHO            Then edit the name after the comma to what want that file to be renamed to. Do not leave blank lines.
	ECHO.
	ECHO           -Keep in mind that file names cannot end with a dot or a space or include these characters: \ / : * ? " < > |
	ECHO.
	ECHO.
	ECHO      "CRC_GeoJSON_Defaults.txt"
	ECHO           -This file lists the renamed files that you want from FE-Buddy, and below it is the GeoJSON "isDefaults"
	ECHO            string to be inserted into that file.
	ECHO.
	ECHO           -Go into this file and delete the lines of the file names and coordisponding GeoJSON defaults that you don't
	ECHO            want.
	ECHO            Then rename the file names as you did previously. Blank lines are ok in this file.
	ECHO.
	ECHO.
	ECHO Press any key to open the folder with these 2 files and to quit this CMD Prompt...
	ECHO      Note-This CMD prompt will close when you select any key to allow you to edit those files but don't worry,
	ECHO           your previously saved data will be remembered.
	
	pause>nul
	
	start /B /WAIT explorer.exe "!DefaultSetterPrefs_DIR!"
	
	EXIT

:IncorrectGeoJsonAmnt

	CLS
				
	ECHO.
	ECHO.
	ECHO                            ---------
	ECHO                             WARNING
	ECHO                            ---------
	ECHO.
	ECHO !FEB_CRC_DIR!
	ECHO.
	ECHO 	There appears to be less than the expected amount of .geojson files
	ECHO    in this directory.
	ECHO	This may be because this batch script has been ran on this FE-Buddy Output
	ECHO	folder already and would cause issues if continued with this process.
	ECHO.
	ECHO	Another possibility is that the FE-Buddy Output\CRC folder has another sub-folder
	ECHO    that hosts all of the .geojsons which is unusual/unexpected such as:
	ECHO 	FE-BUDDY OUTPUT\CRC\CRC
	ECHO.
	ECHO Please close this CMD prompt, run FE-Buddy again and get a new set of
	ECHO data before running this script again.
	ECHO.
	ECHO Press any key to close this CMD Prompt...
	
	PAUSE>NUL
	
	EXIT

:EndChecksFailed

	CLS
				
	ECHO.
	ECHO.
	ECHO                            ---------
	ECHO                             WARNING
	ECHO                            ---------
	ECHO.
	ECHO 	Something went wrong...
	ECHO.
	
	If "!TextCheckStatus!"=="Failed" (
	ECHO	There appears to be no .txt file here where your alias file should be:
	ECHO	!CombinedAliasFilesDirectory!
	ECHO.
	)
	
	If "!GeoJsonsCheckStatus!"=="Failed" (
	ECHO	There appears to be less than the expected amount of .geojson files here:
	ECHO	!FEB_CRC_BATCH_DIR!
	ECHO.
	)
	ECHO Please close this CMD prompt, run FE-Buddy again and get a new set of
	ECHO data before running this script again.
	ECHO.
	ECHO If the problem continues, reach out to Kyle Sanders (developer).
	ECHO.
	ECHO Press any key to close this CMD Prompt...
	
	PAUSE>NUL
	
	EXIT

