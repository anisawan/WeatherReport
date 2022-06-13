*** Settings ***
Library  BuiltIn
Library  DateTime
Library  String
Library  Collections
Library  Autosphere.Archive
Library  Autosphere.Tables
Library  Autosphere.Excel.Files
Library  Autosphere.Browser.Playwright  
Library  ConfigrationFile.py

*** Variables ***
${RPAStarsChallengeDay1Path}
${CredentialFile}  config.ini  
${DataFromCredentail}  DATA
${WorkSheetOfChallengeFile}  Sheet1
${GoogleUrl}
${WeatherUrl}
${Countries}

***Keyword***
Read the RPAStarsChallengeDay1 file
    Open Workbook  ${RPAStarsChallengeDay1Path}
    Set Active Worksheet  ${WorkSheetOfChallengeFile}
    ${ExcelTable}=  Read Worksheet as Table  ${WorkSheetOfChallengeFile}  header=True
    ${CountryList}=  Get table column  ${ExcelTable}  Country
    Set global variable  ${Countries}  ${CountryList}
    
Open the browser 
    Open Available Browser    maximized= True
    

Update the Capital Column in Excel Workbook
    Go To  ${GoogleUrl}
    ${RowNo}=  Set Variable  2
    FOR  ${Country}  IN  @{Countries}
        ${str}=  Fetch From Left  ${Country}  (
        input text  (//input)[1]  ${str}
        Press keys  (//input)[1]      RETURN
        ${Capital}=  Get Text  (//*[@class="fl"])[11]  
        Set Worksheet Value  ${RowNo}  B  ${Capital}
        Save Workbook
        ${RowNo}=  Evaluate  ${RowNo} + 1
        Go To  ${GoogleUrl}
    END

Update the Weather and Status Columns
    Go To  ${WeatherUrl}
    ${RowNo}=  Set Variable  2
    FOR  ${Country}  IN  @{Countries}
        ${CountryName}=  Fetch From Left  ${Country}  (
        input text  (//input)[2]  ${CountryName}
        Press keys  (//input)[2]      RETURN
        Sleep  1
        ${statFirstEle}=  Run Keyword And Return Status  Page Should Contain Element  //*[@class="h2"]
        IF  ${statFirstEle} == True
            ${Weather}=  Get Text  //*[@class="h2"]
            Set Worksheet Value  ${RowNo}  C  ${Weather}
            IF  '${Weather}'!='${EMPTY}'
                Set Worksheet Value  ${RowNo}  D  Yes
            ELSE
                Set Worksheet Value  ${RowNo}  D  No
            END
        ELSE
            ${statSecondEle}=  Run Keyword And Return Status  Page Should Contain Element  (//*[@class="rbi"])[1]
            IF  ${statSecondEle} == True
                ${Weather}=  Get Text  (//*[@class="rbi"])[1]
                Set Worksheet Value  ${RowNo}  C  ${Weather}
                IF  '${Weather}'!='${EMPTY}'
                    Set Worksheet Value  ${RowNo}  D  Yes
                ELSE
                    Set Worksheet Value  ${RowNo}  D  No
                END
            ELSE
                Set Worksheet Value  ${RowNo}  C  Weather Not Found
                Set Worksheet Value  ${RowNo}  D  No
            END
        END
        Save Workbook
        ${RowNo}=  Evaluate  ${RowNo} + 1
        Go To  ${WeatherUrl}
    END
    Close Workbook


Exit the browser
    Close Browser

***Tasks***
Weather Data Bot
    ${ExPath}=  Get Value From Config File  ${CredentialFile}  ${DataFromCredentail}  path
    Set global variable  ${RPAStarsChallengeDay1Path}  ${ExPath}  
    ${GoogUrl}=  Get Value From Config File  ${CredentialFile}  ${DataFromCredentail}  gurl
    Set global variable  ${GoogleUrl}  ${GoogUrl}
    ${WeathUrl}=  Get Value From Config File  ${CredentialFile}  ${DataFromCredentail}  wurl
    Set global variable  ${WeatherUrl}  ${WeathUrl}
    
    Read the RPAStarsChallengeDay1 file
    Open the browser
    Update the Capital Column in Excel Workbook
    Update the Weather and Status Columns
    Exit the browser
    
    
