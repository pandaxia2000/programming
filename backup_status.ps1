out-file ./rds_backup_logs.txt

$arnlist = @{}
$rdsInstanceInfo= @{}

$startdate = Get-Date
$startdate=$startdate.AddDays(-7)
$startdate=$startdate.ToString("yyyy-MM-dd'T'00:00'Z'")

$enddate = Get-Date
$enddate=$enddate.ToString("yyyy-MM-dd'T'00:00'Z'")

$arnlist.add('hanglung_lzapplications_non_prod', 'acs:ram::1597631240738298:role/resourcedirectoryaccountaccessrole')
$arnlist.add('hanglung_lzapplications_dev', 'acs:ram::1640033418775766:role/resourcedirectoryaccountaccessrole')
$arnlist.add('hanglung_lzsharedservice_all', 'acs:ram::1986410517224485:role/resourcedirectoryaccountaccessrole')
$arnlist.add('hanglung_lzapplications_prod', 'acs:ram::1037731240699511:role/resourcedirectoryaccountaccessrole')
$arnlist.add('hanglung_lzaudit_all', 'acs:ram::1441231240671980:role/resourcedirectoryaccountaccessrole')

$arnlist.add('hanglung_cmo', 'acs:ram::1122367252336711:role/resourcedirectoryaccountaccessrole')
$arnlist.add('hanglung_estatement', 'acs:ram::1181109823940150:role/resourcedirectoryaccountaccessrole')
$arnlist.add('hanglung_poc', 'acs:ram::1570711122834635:role/resourcedirectoryaccountaccessrole')
$arnlist.add('hkhanglung', 'acs:ram::1131298460129165:role/resourcedirectoryaccountaccessrole')
$arnlist.add('hanglung_pss', 'acs:ram::1120000677935607:role/resourcedirectoryaccountaccessrole')


foreach ($s in $arnlist.keys)
{
aliyun configure set --profile akProfile --mode AK --region cn-shanghai --access-key-id LTAI5tC2z9SZFZYBhZ3k7rR4 --access-key-secret R51oE1X5h3xrSoBoq5zI7hwmSMff8y
$bb=aliyun sts AssumeRole --region cn-shanghai --RoleSessionName pan_chenc --RoleArn $arnlist.$s
$cc=$bb|convertfrom-json
aliyun configure set --profile stsTokenProfile --mode StsToken --region cn-shanghai --access-key-id $cc.credentials.accesskeyid --access-key-secret $cc.credentials.AccessKeySecret --sts-token $cc.credentials.SecurityToken
$rdsinstancename=aliyun rds DescribeDBInstances  --RegionId cn-shanghai
$rdsinstancename_array=$rdsinstancename|convertfrom-json
$rdsdbinstanceid=($rdsinstancename_array.items.dbinstance.DBInstanceId -split "`n")
$rdsdbinstanceEngine=($rdsinstancename_array.items.dbinstance.Engine -split "`n")



   if (!$rdsdbinstanceid) 
      {
	  "There is no rds instance in " + $s | out-file ./rds_backup_logs.txt -Append -Width 200
	  }
   else
      {   
      $rdsInstanceInfo= @{}
      for ($o=0; $o -lt $rdsdbinstanceid.length; $o=$o+1)
      {$rdsInstanceInfo.add($rdsdbinstanceid[$o],$rdsdbinstanceEngine[$o])}
      
      
      foreach ($i in $rdsInstanceInfo.keys)
      {
      $hh=aliyun rds DescribeBackups --DBInstanceId $i
      $gg=$hh|convertfrom-json
      $gg.items.backup|Select-Object @{name="AliyunAccountName";expression={$s}},@{name="Engine";expression={$rdsInstanceInfo.$i}},@{name="DBInstanceId";expression={$_.DBInstanceId}},@{name="BackupType";expression={$_.BackupType}},@{name="BackupStartTime";expression={$_.BackupStartTime}},@{name="BackupEndTime";expression={$_.BackupEndTime}},@{name="BackupStatus";expression={$_.BackupStatus}},@{name="BackupMode";expression={$_.BackupMode}},@{name="BackupMethod";expression={$_.BackupMethod}},@{name="BackupSize";expression={$_.BackupSize}} |Format-Table -AutoSize -Wrap | out-file ./rds_backup_logs.txt -Append -Width 200
      }
      }

}



foreach ($s in $arnlist.keys)
{
aliyun configure set --profile akProfile --mode AK --region cn-shanghai --access-key-id LTAI5tC2z9SZFZYBhZ3k7rR4 --access-key-secret R51oE1X5h3xrSoBoq5zI7hwmSMff8y
$bb=aliyun sts AssumeRole --region cn-shanghai --RoleSessionName pan_chenc --RoleArn $arnlist.$s
$cc=$bb|convertfrom-json
aliyun configure set --profile stsTokenProfile --mode StsToken --region cn-shanghai --access-key-id $cc.credentials.accesskeyid --access-key-secret $cc.credentials.AccessKeySecret --sts-token $cc.credentials.SecurityToken

$polardbclustername=aliyun polardb DescribeDBClusters --RegionId cn-shanghai
$polardbclustername_array=$polardbclustername|convertfrom-json
$polardbclustername_dbclusterid=($polardbclustername_array.Items.DBCluster.DBClusterId -split "`n")
$polardbclustername_dbtype=($polardbclustername_array.Items.DBCluster.Engine -split "`n")

   if (!$polardbclustername_dbclusterid)
      {
	  "There is no polardb cluster in " + $s | out-file ./rds_backup_logs.txt -Append -Width 200
	  }
   else
      {
      $polardbInstanceInfo= @{}
      for ($o=0; $o -lt $polardbclustername_dbclusterid.length; $o=$o+1)
        {$polardbInstanceInfo.add($polardbclustername_dbclusterid[$o],$polardbclustername_dbtype[$o])}
      
      
      foreach ($i in $polardbInstanceInfo.keys)
        {
        $hh=aliyun polardb DescribeBackups --DBClusterId $i --StartTime $startdate --EndTime $enddate
        $gg=$hh|convertfrom-json
        $gg.items.backup|Select-Object @{name="AliyunAccountName";expression={$s}},@{name="Engine";expression={$polardbInstanceInfo.$i}},@{name="DBInstanceId";expression={$i}},@{name="BackupType";expression={$_.BackupType}},@{name="BackupStartTime";expression={$_.BackupStartTime}},@{name="BackupEndTime";expression={$_.BackupEndTime}},@{name="BackupStatus";expression={$_.BackupStatus}},@{name="BackupMode";expression={$_.BackupMode}},@{name="BackupMethod";expression={$_.BackupMethod}},@{name="BackupSetSize";expression={$_.BackupSetSize}} |Format-Table -AutoSize -Wrap | out-file ./rds_backup_logs.txt -Append -Width 200
        }
      }
}




$From = "chencpan@hanglung.com"
$To = "chencpan@hanglung.com"
$Copy = "chencpan@hanglung.com"
$Attachment = "./rds_backup_logs.txt"
$Subject = "Aliyun RDS/polardb backup daily report"
$Body = "Aliyun RDS/polardb backup daily report."
$SMTPServer = "cmo-smtp01.hanglung.net"
$SMTPPort = "587"
Send-MailMessage -From $From -to $To -Cc $Copy -Subject $Subject -Body $Body -SmtpServer $SMTPServer -Port $SMTPPort -Attachments $Attachment






