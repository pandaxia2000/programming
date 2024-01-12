param ([string]$SiteName)

$SiteNameList=('Center','Forum','Heartland','Olympia','Palace','Parc','Plaza','River','SpringCity','GG')

if (!$SiteName -Or $SiteNameList -notContains $SiteName){
	write-output "Please input a name of Site  as parameter to restore in DR environment. The Site name must be one of below: `n'Center'`n'GG'`n'Forum'`n'Heartland'`n'Olympia'`n'Palace'`n'Parc'`n'Plaza'`n'River'`n'SpringCity'`n"
	$commandName=$MyInvocation.MyCommand.Name
	write-output "Usage example: .\$commandName Plaza"
	exit
}else {write-output "Now start restoring DR environment from backup of $SiteName"}



##Defining functions and variables and data dictionary

function Run-Tasks
{
    Param
    (
        $taskArr,
        $parallelcount=1
    )
    $startTime = (Get-Date)
    Remove-Job *
    $taskCount = $taskArr.Length
    if($parallelCount -gt $taskArr.Length)
    {
        $parallelCount = $taskArr.Length
    }
	
    foreach($i in 1..$parallelCount)
    {
        Start-Job $taskArr[$i - 1] -Name "task$i"
    }
	
    $nextIndex = $parallelCount
	
    while(($nextIndex -lt $taskArr.Length) -or ($taskCount -gt 0))
    {
        foreach($job in Get-Job)
        {
            $state = [string]$job.State
            if($state -eq "Completed")
            {   
                Write-Host($job.Name + " Done, below is output：")
                Receive-Job $job
                Remove-Job $job
                $taskCount--
                if($nextIndex -lt $taskArr.Length)
                {   
                    $taskNumber = $nextIndex + 1
                    Start-Job $taskArr[$nextIndex] -Name "task$taskNumber"
                    $nextIndex++
                }
            }
        }
        sleep 1
    }
    
    "All tasks have been completed."
    (New-TimeSpan $startTime).totalseconds
}


function Decompress-7zip([String] $Zipfile, [String] $Directory,[String] $password)
{    
[string]$pathToZipExe = "$($Env:ProgramFiles)\7-Zip\7z.exe";    
[Array]$arguments = "e", "$Zipfile","-o$Directory","-p$password";    
& $pathToZipExe $arguments;
}


function replace_string([String] $folderPath, [String] $searchString,[String] $replaceString,[String] $filename)
{ 
$files = Get-ChildItem -Path $folderPath -Filter $filename
foreach ($file in $files) {
    $fileContent = Get-Content -Path $file.FullName
    $newContent = $fileContent -replace $searchString, $replaceString
    $newContent | Set-Content -Path $file.FullName
}
}



$DownloadPathName=@{}
$MallcooRQcode=@{}
$SiteNumber=@{}
$URL=@{}
$ZipFilePassword=@{}
$today=(Get-Date).tostring('yyyyMMdd')
$date=(Get-Date).adddays(-1)


$DownloadPathName.add('Center','\\172.28.0.41\POSBackup\CenterSmartpos')
$DownloadPathName.add('Forum','\\172.28.0.41\POSBackup\ForumSmartpos')
$DownloadPathName.add('Heartland','\\172.28.0.41\POSBackup\HeartlandSmartpos')
$DownloadPathName.add('Olympia','\\172.28.0.41\POSBackup\OlympiaSmartpos')
$DownloadPathName.add('Palace','\\172.28.0.41\POSBackup\PalaceSmartpos')
$DownloadPathName.add('Parc','\\172.28.0.41\POSBackup\ParcSmartpos')
$DownloadPathName.add('Plaza','\\172.28.0.41\POSBackup\PlazaSmartpos')
$DownloadPathName.add('River','\\172.28.0.41\POSBackup\RiversideSmartpos')
$DownloadPathName.add('SpringCity','\\172.28.0.41\POSBackup\SpringCitySmartpos')

$MallcooRQcode.add('Plaza','10132')
$MallcooRQcode.add('Grand Gateway','10209')
$MallcooRQcode.add('Forum','10127')
$MallcooRQcode.add('Palace','10211')
$MallcooRQcode.add('Center','10086')
$MallcooRQcode.add('Parc','10207')
$MallcooRQcode.add('Riverside','10243')
$MallcooRQcode.add('Olympia','10205')
$MallcooRQcode.add('SpringCity','11053')
$MallcooRQcode.add('Heartland','11408')

$SiteNumber.add('Plaza','100000000')
$SiteNumber.add('Grand Gateway','100000001')
$SiteNumber.add('Forum','100000002')
$SiteNumber.add('Palace','100000003')
$SiteNumber.add('Center','100000004')
$SiteNumber.add('Parc','100000005')
$SiteNumber.add('Riverside','100000006')
$SiteNumber.add('Olympia','100000007')
$SiteNumber.add('SpringCity','100000008')
$SiteNumber.add('Heartland','100000009')

$URL.add('Grand Gateway','172.28.8.216')
$URL.add('Plaza','172.28.12.216')
$URL.add('Center','172.28.44.216')
$URL.add('Palace','172.28.20.216')
$URL.add('Forum','172.28.16.216')
$URL.add('Parc','172.28.4.216')
$URL.add('Riverside','172.28.40.216:13')
$URL.add('Olympia','172.28.32.216')
$URL.add('SpringCity','172.28.56.216')
$URL.add('Heartland','172.28.60.216')


$ZipFilePassword.add('Forum','forum66')

$recompilation_sql="
connect mallcre/heading1234
drop database link mpos;
create database link MPOS
connect to mpos identified by heading1234 using 
'(DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = cmo-srv0053)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = HDAPP)
    )
  )';

drop database link HDAPP;
create database link HDAPP
connect to hd40 identified by heading1234 using 
'(DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = cmo-srv0053)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = HDAPP)
    )
  )';

drop database link BI_MPOS;
create database link BI_MPOS
connect to mpos identified by heading1234 using 
'(DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = cmo-srv0053)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = HDAPP)
    )
  )';

drop database link HD40;
create database link HD40
connect to hd40 identified by heading1234 using 
'(DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = cmo-srv0053)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = HDAPP)
    )
  )';
conn / as sysdba
@?\rdbms\admin\utlrp.sql
exit
"
$recompilation_sql|out-file -Encoding utf8 -filepath recompilation.sql



##Prerequisites

new-item -path D:\ -name drill -type directory
Remove-Item D:\drill\* -recurse -force

write-output "Start stopping Oracle listener at $(get-date)"
& lsnrctl stop
write-output "Stopping Oracle listener completed at $(get-date)"

write-output "Start stopping windows task '数据传输' at $(get-date)"
Disable-ScheduledTask -TaskPath “\” -TaskName "数据传输"
write-output "Stopping windows task '数据传输' completed at $(get-date)"

write-output "Start stopping Apache services at $(get-date)"
Stop-Service -Name "Apache Tomcat agency"
Stop-Service -Name "Apache Tomcat cre-server"
Stop-Service -Name "Apache Tomcat cre-web"
Stop-Service -Name "Apache Tomcat HDBI"
Stop-Service -Name "Apache Tomcat HDBPM"
Stop-Service -Name "Apache Tomcat HDIA"
Stop-Service -Name "Apache Tomcat HDMedia"
Stop-Service -Name "Apache Tomcat xdiamond"
Stop-Service -Name "Apache2.4"
write-output "Stopping Apache services completed at $(get-date)"



##Downloading and decompressing backups


write-output "Start downloading and decompressing backups at $(get-date)"

$items = Get-ChildItem -Recurse $DownloadPathName.$SiteName | Where-Object {$_.LastWriteTime -gt $date -and $_.Mode -notlike 'd*'}
$FullPathAndName=$items.DirectoryName+"\"+$items.name
$FullPath=$items.DirectoryName
$FileName=$items.name
copy-item $FullPathAndName -Destination "D:\drill"
$password=$ZipFilePassword.$SiteName
Decompress-7zip d:\drill\$FileName d:\drill $password

write-output "Downloading and decompressing backups completed at $(get-date)"




### Startup force

write-output "Start restarting Oracle instances at $(get-date)"

$task1 = {$env:ORACLE_SID="hdapp";
Write-Output "startup force;`nexit"|Out-File C:\Users\hladmin01\hdappstartupforce.sql -Encoding Ascii;
& 'D:\app\administrator\product\18.3.0\db_1\bin\sqlplus' '/ as sysdba' "@C:\Users\hladmin01\hdappstartupforce.sql";
remove-item C:\Users\hladmin01\hdappstartupforce.sql;}

$task2 = {$env:ORACLE_SID="hdbi";
Write-Output "startup force;`nexit"|Out-File C:\Users\hladmin01\hdbistartupforce.sql -Encoding Ascii;
& 'D:\app\administrator\product\18.3.0\db_1\bin\sqlplus' '/ as sysdba' "@C:\Users\hladmin01\hdbistartupforce.sql";
remove-item C:\Users\hladmin01\hdbistartupforce.sql;}

$task3 = {$env:ORACLE_SID="hdia";
Write-Output "startup force;`nexit"|Out-File C:\Users\hladmin01\hdiastartupforce.sql -Encoding Ascii;
& 'D:\app\administrator\product\18.3.0\db_1\bin\sqlplus' '/ as sysdba' "@C:\Users\hladmin01\hdiastartupforce.sql";
remove-item C:\Users\hladmin01\hdiastartupforce.sql;}

$taskArr = $task1, $task2, $task3

Run-Tasks -taskArr $taskArr -parallelcount 6

write-output "Restarting Oracle instances completed at $(get-date)"





### Dropping users cascade

write-output "Start dropping schemas in databases at $(get-date)"

$task4 = {$env:ORACLE_SID="hdapp";
Write-Output "drop user hd40 cascade;`ndrop user hdbi cascade;`ndrop user bpm cascade;`ndrop user mpos cascade;`nexit"|Out-File C:\Users\hladmin01\hdappdropusers.sql -Encoding Ascii;
& 'D:\app\administrator\product\18.3.0\db_1\bin\sqlplus' '/ as sysdba' "@C:\Users\hladmin01\hdappdropusers.sql";
remove-item C:\Users\hladmin01\hdappdropusers.sql;}

$task5 = {$env:ORACLE_SID="hdbi";
Write-Output "drop user mallcre cascade;`nexit"|Out-File C:\Users\hladmin01\hdbidropusers.sql -Encoding Ascii;
& 'D:\app\administrator\product\18.3.0\db_1\bin\sqlplus' '/ as sysdba' "@C:\Users\hladmin01\hdbidropusers.sql";
remove-item C:\Users\hladmin01\hdbidropusers.sql;}

$task6 = {$env:ORACLE_SID="hdia";
Write-Output "drop user iaaudit cascade;`ndrop user author cascade;`nexit"|Out-File C:\Users\hladmin01\hdiadropusers.sql -Encoding Ascii;
& 'D:\app\administrator\product\18.3.0\db_1\bin\sqlplus' '/ as sysdba' "@C:\Users\hladmin01\hdiadropusers.sql";
remove-item C:\Users\hladmin01\hdiadropusers.sql;}

$taskArr = $task4, $task5, $task6

Run-Tasks -taskArr $taskArr -parallelcount 6

write-output "Dropping schemas in databases completed at $(get-date)"




###Importing data from dumps


write-output "Start importing data for all instances at $(get-date)"

$task7 = {$env:ORACLE_SID="hdapp";
$date=(Get-Date).tostring('yyyyMMdd');
impdp system/heading1234 SCHEMAS=('hd40','bpm','hdbi','mpos') DIRECTORY=dump_dir DUMPFILE=$date"HDAPP.DMP" logfile=HDAPP.log PARALLEL=4}

$task8 = {$env:ORACLE_SID="hdbi";
$date=(Get-Date).tostring('yyyyMMdd');
impdp system/heading1234 SCHEMAS='mallcre'  DIRECTORY=dump_dir DUMPFILE=$date"HDBI.DMP" logfile=HDBI.log PARALLEL=4}

$task9 = {$env:ORACLE_SID="hdia";
$date=(Get-Date).tostring('yyyyMMdd');
impdp system/heading1234 SCHEMAS=('iaaudit','author') DIRECTORY=dump_dir DUMPFILE=$date"HDIA.DMP" logfile=HDIA.log PARALLEL=4}


$taskArr = $task7, $task8, $task9

Run-Tasks -taskArr $taskArr -parallelcount 6

write-output "Importing data for all instances completed at $(get-date)"




###Changing users password

write-output "Start changing users password for all instances at $(get-date)"

$task10 = {$env:ORACLE_SID="hdapp";
Write-Output "Alter user hd40 identified by heading1234;`nAlter user hdbi identified by heading1234;`nAlter user bpm identified by heading1234;`nAlter user mpos identified by heading1234;`nexit"|Out-File C:\Users\hladmin01\hdappchangepassword.sql -Encoding Ascii;
& 'D:\app\administrator\product\18.3.0\db_1\bin\sqlplus' '/ as sysdba' "@C:\Users\hladmin01\hdappchangepassword.sql";
remove-item C:\Users\hladmin01\hdappchangepassword.sql;}

$task11 = {$env:ORACLE_SID="hdbi";
Write-Output "Alter user mallcre identified by heading1234;`nexit"|Out-File C:\Users\hladmin01\hdbichangepassword.sql -Encoding Ascii;
& 'D:\app\administrator\product\18.3.0\db_1\bin\sqlplus' '/ as sysdba' "@C:\Users\hladmin01\hdbichangepassword.sql";
remove-item C:\Users\hladmin01\hdbichangepassword.sql;}

$task12 = {$env:ORACLE_SID="hdia";
Write-Output "Alter user iaaudit identified by heading1234;`nAlter user author identified by heading1234;`nexit"|Out-File C:\Users\hladmin01\hdiachangepassword.sql -Encoding Ascii;
& 'D:\app\administrator\product\18.3.0\db_1\bin\sqlplus' '/ as sysdba' "@C:\Users\hladmin01\hdiachangepassword.sql";
remove-item C:\Users\hladmin01\hdiachangepassword.sql;}


$taskArr = $task10, $task11, $task12

Run-Tasks -taskArr $taskArr -parallelcount 6

write-output "Changing users password for all instances completed at $(get-date)"





###Recompilation


write-output "Start recompiling in HDBI database at $(get-date)"

$env:ORACLE_SID="hdbi"
& 'D:\app\administrator\product\18.3.0\db_1\bin\sqlplus' '/ as sysdba' "@recompilation.sql"

write-output "Recompiling in HDBI database completed at $(get-date)"



##Modifying parameters in configuration files


write-output "Start modifying parameters in configuration files at $(get-date)"

# D:\ETL数据传输\CRE-NC0506\HL_NC.ini
$name=$URL.$SiteName
$folderPath = "D:\ETL数据传输\CRE-NC0506"
$searchString = "WebServiceUrl=http\:\/\/((2(5[0-5]|[0-4]\d))|[0-1]?\d{1,2})(\.((2(5[0-5]|[0-4]\d))|[0-1]?\d{1,2})){3}"
$replaceString = "WebServiceUrl=http://$name"
$filename="HL_NC.ini"

replace_string $folderPath $searchString $replaceString $filename


# D:\ETL数据传输\cre-nc\HL_NC.ini
$name=$URL.$SiteName
$folderPath = "D:\ETL数据传输\cre-nc"
$searchString = "WebServiceUrl=http\:\/\/((2(5[0-5]|[0-4]\d))|[0-1]?\d{1,2})(\.((2(5[0-5]|[0-4]\d))|[0-1]?\d{1,2})){3}"
$replaceString = "WebServiceUrl=http://$name"
$filename="HL_NC.ini"

replace_string $folderPath $searchString $replaceString $filename


# D:\ETL数据传输\CRE明细数据\DB_SYNC_BI_DETAIL.ini

$folderPath = "C:\Users\pan_chenc"
$filename="DB_SYNC_BI_DETAIL.ini"

if ($SiteName -eq 'Forum'){
$searchString = ".*StoreName=HANGLUNG"
$replaceString = "#StoreName=HANGLUNG"
replace_string $folderPath $searchString $replaceString $filename

$searchString = ".*StoreName=沈阳市府恒隆"
$replaceString = "StoreName=沈阳市府恒隆"
replace_string $folderPath $searchString $replaceString $filename
}else
{
$searchString = ".*StoreName=HANGLUNG"
$replaceString = "StoreName=HANGLUNG"
replace_string $folderPath $searchString $replaceString $filename

$searchString = ".*StoreName=沈阳市府恒隆"
$replaceString = "#StoreName=沈阳市府恒隆"
replace_string $folderPath $searchString $replaceString $filename
}

write-output "Modifying parameters in configuration files completed at $(get-date)"


##post-processing 

write-output "Start bringing services and task back to work at $(get-date)"

Start-Service -Name "Apache2.4"
Start-Service -Name "Apache Tomcat xdiamond"
Start-Service -Name "Apache Tomcat HDMedia"
Start-Service -Name "Apache Tomcat HDIA"
Start-Service -Name "Apache Tomcat HDBPM"
Start-Service -Name "Apache Tomcat HDBI"
Start-Service -Name "Apache Tomcat cre-web"
Start-Service -Name "Apache Tomcat cre-server"
Start-Service -Name "Apache Tomcat agency"

Enable-ScheduledTask -TaskPath “\” -TaskName "数据传输"

write-output "Bringing services and task back to work completed at $(get-date)"

Remove-Item recompilation.sql