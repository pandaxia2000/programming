$global:region='cn-shanghai'
$DBInstanceId='rm-uf6fw0et9abaa000z'
$DBName='preprodyonbipdb'
#$bucketname='oss-dmp-prd'
$bucketname='oss-ncc-uat-archive-shanghai'
$endpoint_internal='oss-cn-shanghai-internal.aliyuncs.com'
$DatabaseName='testDB'
$datetime=(get-date).tostring('yyyy_MM_dd_hh_mm_ss')
$DestinationDatabaseName=$DatabaseName+"_"+$datetime
$FilePath='C:\TMP'

function get-url()
{
$hh=aliyun rds DescribeBackups --DBInstanceId $DBInstanceId
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


Remove-Item -Path $FilePath\bak\*.*
Remove-Item -Path $FilePath\*.zip

set_configuration_non_prod
get-url
$CountInitial=$count

aliyun rds CreateBackup --region $region --DBInstanceId $DBInstanceId --DBName $DBName --BackupStrategy db --BackupMethod Physical --BackupType FullBackup

while ($count -eq $CountInitial)
{
set_configuration_non_prod
$hh=aliyun rds DescribeBackups --DBInstanceId $DBInstanceId
$gg=$hh|convertfrom-json
$DbBackupList=$gg.items.backup | Where-Object {$_.BackupScale -eq "Database" -and $_.BackupType -eq "FullBackup"}
$count=$DbBackupList.count
sleep 5
write-output "Backup process is still ongoing"
}

set_configuration_non_prod
$hh=aliyun rds DescribeBackups --DBInstanceId $DBInstanceId
$gg=$hh|convertfrom-json
$URL=$gg.items.backup | Where-Object {$_.BackupScale -eq "Database" -and $_.BackupType -eq "FullBackup"}

Invoke-WebRequest -uri $URL[0].BackupIntranetDownloadURL -OutFile "$FilePath\bak.zip"

Expand-Archive -Path "$FilePath\bak.zip" -DestinationPath "$FilePath\bak"
$unzippedfile=Get-ChildItem -Path $FilePath\bak\*.bak
$FileFullName=$unzippedfile.fullname
$FileName=$unzippedfile.name

& $FilePath\ossutil64.exe cp -c $FilePath\.ossutilconfig_nonprod $FileFullName oss://$bucketname
#$FilePath\ossutil64.exe cp -c $FilePath\ossutilconfig_prod_internal $FileFullName oss://$bucketname


set_configuration_non_prod
aliyun rds CreateMigrateTask --region $region --DBInstanceId $DBInstanceId --DBName $DestinationDatabaseName --BackupMode FULL --IsOnlineDB True --OssObjectPositions "${endpoint_internal}\:${bucketname}\:${FileName}"


set_configuration_non_prod
$NewDatabaseStatus=aliyun rds DescribeDatabases --region cn-shanghai --DBInstanceId $DBInstanceId --DBName $DestinationDatabaseName
$NewDatabaseStatus=$NewDatabaseStatus|convertfrom-json
while (-not ($NewDatabaseStatus.Databases.Database.DBStatus -eq "Running"))
{
sleep 5
}

aliyun rds GrantAccountPrivilege --region $region --DBInstanceId $DBInstanceId --AccountName wangyibiao --DBName $DestinationDatabaseName --AccountPrivilege DBOwner
aliyun rds GrantAccountPrivilege --region $region --DBInstanceId $DBInstanceId --AccountName preprod_oper --DBName $DestinationDatabaseName --AccountPrivilege DBOwner
