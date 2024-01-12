$theVeryBeginningOfTheWholeProcess=get-date

$global:region='cn-shanghai'
$SourceDBInstanceId='rm-uf6fw0et9abaa000z'
$DestinationDBInstanceId='rm-uf6512iegrt67z10h'
$bucketname='oss-dmp-prd'
#$bucketname='oss-ncc-uat-archive-shanghai'
$endpoint_internal='oss-cn-shanghai-internal.aliyuncs.com'
#$SourceDatabaseName='testdb1117'
$SourceDatabaseName='preprodyonbipdb'
$DestinationDatabaseName='testDBrestored'
$datetime=(get-date).tostring('yyyy_MM_dd_hh_mm_ss')
$DestinationDatabaseNameRenamed=$DestinationDatabaseName+"_old_"+$datetime
$FilePath='C:\TMP'
$ScriptLogPath="$FilePath\runtimelog.log"
$DestinationServerName="$DestinationDBInstanceId.sqlserver.rds.aliyuncs.com"
$username='dbadmin'
$password='H@ngLungP@ssw0rd'

function get-url()
{
$hh=aliyun rds DescribeBackups --DBInstanceId $SourceDBInstanceId
$gg=$hh|convertfrom-json
$URL=$gg.items.backup | Where-Object {$_.BackupScale -eq "Database" -and $_.BackupType -eq "FullBackup"}
$global:count = $URL.BackupDownloadURL.count
} 

function set_configuration_non_prod()
{
aliyun configure set --profile akProfile --mode AK --region $region --access-key-id LTAI5tC2z9SZFZYBhZ3k7rR4 --access-key-secret R51oE1X5h3xrSoBoq5zI7hwmSMff8y
$bb=aliyun sts AssumeRole --region $region --RoleSessionName pan_chenc --RoleArn 'acs:ram::1597631240738298:role/resourcedirectoryaccountaccessrole'
$cc=$bb|convertfrom-json
aliyun configure set --profile stsTokenProfile --mode StsToken --region $region --access-key-id $cc.credentials.accesskeyid --access-key-secret $cc.credentials.AccessKeySecret --sts-token $cc.credentials.SecurityToken
}

function set_configuration_prod()
{
aliyun configure set --profile akProfile --mode AK --region $region --access-key-id LTAI5tC2z9SZFZYBhZ3k7rR4 --access-key-secret R51oE1X5h3xrSoBoq5zI7hwmSMff8y
$bb=aliyun sts AssumeRole --region $region --RoleSessionName pan_chenc --RoleArn 'acs:ram::1037731240699511:role/resourcedirectoryaccountaccessrole'
$cc=$bb|convertfrom-json
aliyun configure set --profile stsTokenProfile --mode StsToken --region $region --access-key-id $cc.credentials.accesskeyid --access-key-secret $cc.credentials.AccessKeySecret --sts-token $cc.credentials.SecurityToken
}

function sendmail([string]$SourceDBInstanceId,[string]$SourceDatabaseName,[string]$DestinationDBInstanceId,[string]$DestinationDatabaseName,[string]$DestinationDatabaseNameRenamed)
{
$From = "chencpan@hanglung.com"
#$To = "chencpan@hanglung.com","YibiaoYBWang@HangLung.com"
$To = "chencpan@hanglung.com"
$Copy = "chencpan@hanglung.com"
$Subject = "Restoration completed"
$Body = "
Source instance: $SourceDBInstanceId

Source database: $SourceDatabaseName

Destination instance: $DestinationDBInstanceId

Destination database: $DestinationDatabaseName

Destination original database has been renamed into : $DestinationDatabaseNameRenamed"
$SMTPServer = "172.28.0.71"
$SMTPPort = "25"
Send-MailMessage -From $From -to $To -Cc $Copy -Subject $Subject -Body $Body -SmtpServer $SMTPServer -Port $SMTPPort
}


##Removing
Write-Output ("Removing file started at " + (get-date)) | Out-File -FilePath $ScriptLogPath -append
$Removingfilestart=get-date
Remove-Item -Path $FilePath\bak\*.*
Remove-Item -Path $FilePath\*.zip
$Removingfileend=get-date
Write-Output ("Removing file ended at " + (get-date)) | Out-File -FilePath $ScriptLogPath -append
$timecostofRemovingfile=$Removingfileend-$Removingfilestart
$timecost1=($timecostofRemovingfile.days).ToString() +" days "+($timecostofRemovingfile.hours).ToString() +" hours "+($timecostofRemovingfile.minutes).ToString()+" minutes "+($timecostofRemovingfile.seconds).ToString() +" seconds "
Write-Output ("Removing file cost " + $timecost1) | Out-File -FilePath $ScriptLogPath -append

set_configuration_non_prod
get-url
$CountInitial=$count
Write-Output ("Before Backup the count number of backups is " + $count) | Out-File -FilePath $ScriptLogPath -append


##Backup
Write-Output ("Backup started at " + (get-date)) | Out-File -FilePath $ScriptLogPath -append
$Backupstart=get-date

aliyun rds CreateBackup --region $region --DBInstanceId $SourceDBInstanceId --DBName $SourceDatabaseName --BackupStrategy db --BackupMethod Physical --BackupType FullBackup

while ($count -eq $CountInitial)
{
set_configuration_non_prod
$hh=aliyun rds DescribeBackups --DBInstanceId $SourceDBInstanceId
$gg=$hh|convertfrom-json
$DbBackupList=$gg.items.backup | Where-Object {$_.BackupScale -eq "Database" -and $_.BackupType -eq "FullBackup"}
$count=$DbBackupList.count
write-output "Backup process is still ongoing"
sleep 10
}
Write-Output ("After Backup the count number of backups is " + $count) | Out-File -FilePath $ScriptLogPath -append
Write-Output ("The LastModifyDate of Backup which is about to download is " + $gg.items.backup[0].BackupEndTime) | Out-File -FilePath $ScriptLogPath -append

set_configuration_non_prod
$hh=aliyun rds DescribeBackups --DBInstanceId $SourceDBInstanceId
$gg=$hh|convertfrom-json
$URL=$gg.items.backup | Where-Object {$_.BackupScale -eq "Database" -and $_.BackupType -eq "FullBackup"}

$Backupend=get-date
Write-Output ("Backup ended at " + (get-date)) | Out-File -FilePath $ScriptLogPath -append
$timecostofBackup=$Backupend-$Backupstart
$timecost2=($timecostofBackup.days).ToString() +" days "+($timecostofBackup.hours).ToString() +" hours "+($timecostofBackup.minutes).ToString()+" minutes "+($timecostofBackup.seconds).ToString() +" seconds "
Write-Output ("Backup cost " + $timecost2) | Out-File -FilePath $ScriptLogPath -append


##Downloading
Write-Output ("Downloading started at " + (get-date)) | Out-File -FilePath $ScriptLogPath -append
$Downloadingstart=get-date
Invoke-WebRequest -uri $URL[0].BackupIntranetDownloadURL -OutFile "$FilePath\bak.zip"
#Invoke-WebRequest -uri $URL[0].BackupDownloadURL -OutFile "$FilePath\bak.zip"
$Downloadingend=get-date
Write-Output ("Downloading ended at " + (get-date)) | Out-File -FilePath $ScriptLogPath -append
$timecostofDownloading=$Downloadingend-$Downloadingstart
$timecost3=($timecostofDownloading.days).ToString() +" days "+($timecostofDownloading.hours).ToString() +" hours "+($timecostofDownloading.minutes).ToString()+" minutes "+($timecostofDownloading.seconds).ToString() +" seconds "
Write-Output ("Downloading file cost " + $timecost3) | Out-File -FilePath $ScriptLogPath -append



##Decompression
Write-Output ("Decompression started at " + (get-date)) | Out-File -FilePath $ScriptLogPath -append
$Decompressionstart=get-date
Expand-Archive -Path "$FilePath\bak.zip" -DestinationPath "$FilePath\bak"
$unzippedfile=Get-ChildItem -Path $FilePath\bak\*.bak
$FileFullName=$unzippedfile.fullname
$FileName=$unzippedfile.name
$Decompressionend=get-date
Write-Output ("Decompression ended at " + (get-date)) | Out-File -FilePath $ScriptLogPath -append
$timecostofDecompression=$Decompressionend-$Decompressionstart
$timecost4=($timecostofDecompression.days).ToString() +" days "+($timecostofDecompression.hours).ToString() +" hours "+($timecostofDecompression.minutes).ToString()+" minutes "+($timecostofDecompression.seconds).ToString() +" seconds "
Write-Output ("Decompression cost " + $timecost4) | Out-File -FilePath $ScriptLogPath -append


##Uploading
Write-Output ("Uploading started at " + (get-date)) | Out-File -FilePath $ScriptLogPath -append
$Uploadingstart=get-date
#& $FilePath\ossutil64.exe cp -c $FilePath\ossutilconfig_nonprod_internal $FileFullName oss://$bucketname -f
& $FilePath\ossutil64.exe cp -c $FilePath\ossutilconfig_prod_internal $FileFullName oss://$bucketname -f
$Uploadingend=get-date
Write-Output ("Uploading ended at " + (get-date)) | Out-File -FilePath $ScriptLogPath -append
$timecostofUploading=$Uploadingend-$Uploadingstart
$timecost5=($timecostofUploading.days).ToString() +" days "+($timecostofUploading.hours).ToString() +" hours "+($timecostofUploading.minutes).ToString()+" minutes "+($timecostofUploading.seconds).ToString() +" seconds "
Write-Output ("Uploading cost " + $timecost5) | Out-File -FilePath $ScriptLogPath -append

##Rename database name in destination
Write-Output ("Rename old database started at " + (get-date)) | Out-File -FilePath $ScriptLogPath -append
invoke-sqlcmd -ServerInstance $DestinationServerName -Username $username -password $password -Database "rdscore" -Query "EXEC sp_rds_modify_db_name $DestinationDatabaseName,$DestinationDatabaseNameRenamed" -QueryTimeout 0  2>&1 | Out-File -append $ScriptLogPath
Write-Output ("Rename old database ended at " + (get-date)) | Out-File -FilePath $ScriptLogPath -append


##Restoration
Write-Output ("Restoration started at " + (get-date)) | Out-File -FilePath $ScriptLogPath -append
$Restorationstart=get-date
set_configuration_prod
aliyun rds CreateMigrateTask --region $region --DBInstanceId $DestinationDBInstanceId --DBName $DestinationDatabaseName --BackupMode FULL --IsOnlineDB True --OssObjectPositions "${endpoint_internal}:${bucketname}:${FileName}"
set_configuration_prod
$NewDatabaseStatus=aliyun rds DescribeDatabases --region $region --DBInstanceId $DestinationDBInstanceId --DBName $DestinationDatabaseName
$NewDatabaseStatus=$NewDatabaseStatus|convertfrom-json
while (-not ($NewDatabaseStatus.Databases.Database.DBStatus -eq "Running"))
{
set_configuration_prod
$NewDatabaseStatus=aliyun rds DescribeDatabases --region $region --DBInstanceId $DestinationDBInstanceId --DBName $DestinationDatabaseName
$NewDatabaseStatus=$NewDatabaseStatus|convertfrom-json
write-output "Restoring process is still ongoing"
sleep 10
}
$Restorationend=get-date
Write-Output ("Restoration ended at " + (get-date)) | Out-File -FilePath $ScriptLogPath -append
$timecostofRestoration=$Restorationend-$Restorationstart
$timecost6=($timecostofRestoration.days).ToString() +" days "+($timecostofRestoration.hours).ToString() +" hours "+($timecostofRestoration.minutes).ToString()+" minutes "+($timecostofRestoration.seconds).ToString() +" seconds "
Write-Output ("Restoration cost " + $timecost6) | Out-File -FilePath $ScriptLogPath -append



##Granting privileges
##when the status of rds database show "running" is not meaning the restoration process got completed, it's not really in available status at that time, it still needs some time to wait.
$Grantingstart=get-date
sleep 10
Write-Output ("Granting Privilieges started at " + (get-date)) | Out-File -FilePath $ScriptLogPath -append
set_configuration_prod
aliyun rds GrantAccountPrivilege --region $region --DBInstanceId $DestinationDBInstanceId --AccountName prod_oper --DBName $DestinationDatabaseName --AccountPrivilege DBOwner  2>$null
while ($? -eq $false)
{
aliyun rds GrantAccountPrivilege --region $region --DBInstanceId $DestinationDBInstanceId --AccountName prod_oper --DBName $DestinationDatabaseName --AccountPrivilege DBOwner  2>$null
aliyun rds GrantAccountPrivilege --region $region --DBInstanceId $DestinationDBInstanceId --AccountName frp_gyc --DBName $DestinationDatabaseName --AccountPrivilege DBOwner  2>$null
sleep 10
}
$Grantingend=get-date
Write-Output ("Granting Privilieges ended at " + (get-date)) | Out-File -FilePath $ScriptLogPath -append
$timecostofGranting=$Grantingend-$Grantingstart
$timecost7=($timecostofGranting.days).ToString() +" days "+($timecostofGranting.hours).ToString() +" hours "+($timecostofGranting.minutes).ToString()+" minutes "+($timecostofGranting.seconds).ToString() +" seconds "
Write-Output ("Granting Privilieges cost " + $timecost7) | Out-File -FilePath $ScriptLogPath -append



$theVeryEndingOfTheWholeProcess=get-date
$timecostofTheWholeProcess=$theVeryEndingOfTheWholeProcess-$theVeryBeginningOfTheWholeProcess
$timecost8=($timecostofTheWholeProcess.days).ToString() +" days "+($timecostofTheWholeProcess.hours).ToString() +" hours "+($timecostofTheWholeProcess.minutes).ToString()+" minutes "+($timecostofTheWholeProcess.seconds).ToString() +" seconds "
Write-Output ("The Whole process cost " + $timecost8) | Out-File -FilePath $ScriptLogPath -append


sendmail $SourceDBInstanceId $SourceDatabaseName $DestinationDBInstanceId $DestinationDatabaseName $DestinationDatabaseNameRenamed
