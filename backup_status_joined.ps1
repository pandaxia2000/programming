
##only save logs within 30 days

$TimeOutDays=31
$filePath="C:\Users\pan_chenc"     
$allFiles=get-childitem -path $filePath | Where-Object { $_.Name -match '^rds_backup_logs.*\.xlsx' } 
foreach ($files in $allFiles)     
{       
   $daypan=((get-date)-$files.lastwritetime).days       
   if ($daypan -gt $TimeOutDays)       
   {         
     remove-item $files.fullname -Recurse -force       
    }     
}




$arnlist = @{}
$rdsInstanceInfo= @{}

$projectName=@{}

$date = Get-Date
$startdate=$date.AddDays(-7)

##start and end date is required in the aliyun polardb command, and they must be in the "yyyy-MM-dd'T'HH:mm'Z'" pattern
$startdate=$startdate.ToString("yyyy-MM-dd'T'00:00'Z'")


$enddate=$date.ToString("yyyy-MM-dd'T'00:00'Z'")

$todaydate=$date.ToString("yyyy-MM-dd_HHmmss")


$region=@()

$region=@('cn-hangzhou','cn-shanghai','cn-hongkong','cn-qingdao','cn-beijing','cn-zhangjiakou','cn-huhehaote','cn-wulanchabu','cn-shenzhen','cn-chengdu')
#$region=@('cn-hangzhou','cn-shanghai','cn-hongkong')


$totalissue=0
$todayissue=0
$x=@()
$count=0

$f1=@()
$f2=@()

$outputexcelfilename="rds_backup_logs_"+$todaydate+".xlsx"

#export-excel ./$outputexcelfilename


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


$projectName.add('rm-uf6v0llb81ow15fs0','OEF')
$projectName.add('rm-uf6yh117967v21565','TIPPlus')
$projectName.add('rm-uf6qjomq91px0d701','NCC')
$projectName.add('rm-uf6s5bb88awso766m','Handsfree')
$projectName.add('rm-uf6cg9ynh0a7e8n80','DW/BI')
$projectName.add('rm-uf6mly26nxwk75m24','NCC')
$projectName.add('rm-uf6mlx2j5w3o9va93','Smartstock')
$projectName.add('rm-uf632p0n7h6pz1d26','NCC')
$projectName.add('rm-uf6bikpp653oj099p','We66')
$projectName.add('rm-uf6fw0et9abaa000z','NCC')
$projectName.add('rm-uf6g08jionwt85522','Survey')
$projectName.add('rm-uf6ww7k53t627lr8r','Smartstock')
$projectName.add('rm-uf6f2ti4x2z3jj16u','Smartstock')
$projectName.add('rm-uf64183e5sczkwq4e','TIPPlus')
$projectName.add('rm-uf66447r016w93gsd','We66')
$projectName.add('rm-uf64ou3g35ia0fo4w','Handsfree')
$projectName.add('rm-uf65p904z482wiwjn','We66')
$projectName.add('rm-uf6fg5b3ppg2z4bs6','We66')
$projectName.add('rm-uf673w8koo3w903r9','Esign')
$projectName.add('rm-j6c79312s1u68c6ld','Corpweb')
$projectName.add('rm-j6cjk9497k8e2gpp4','Website')
$projectName.add('rm-j6cql7j1751rrx36m','Website')
$projectName.add('rm-j6c85701vx10py5j3','Website')
$projectName.add('rm-j6clh8mutl3m829s8','Website')
$projectName.add('rm-j6cc16826yrz50wit','Website')
$projectName.add('rm-j6c78a9kdwqnsvbl1','Corpweb')
$projectName.add('rm-j6ci5uma5yyxlgb16','Website')
$projectName.add('rm-j6cg15ysi8drzmw7r','Corpweb')
$projectName.add('pc-bp13uoi3lpn9kr93e','TIP')
$projectName.add('pc-uf63x3yk4468s3cg2','TIP')
$projectName.add('pc-uf6j11obfthmx27i8','TIP')
$projectName.add('rm-uf6mn06na904h4717','CFD')
$projectName.add('rm-uf6c65b5d6335h80k','OEF')
$projectName.add('rm-uf60y0gi828h9s54q','DMP')
$projectName.add('rm-uf6512iegrt67z10h','NCC')
$projectName.add('rm-uf60o0r99vl62et1i','CFD')
$projectName.add('rm-uf698lgr8qc5o8161','BRI')
$projectName.add('rm-uf6mhd9f2ro0cst1z','BRI')




foreach ($regionid in $region)
{

     foreach ($s in $arnlist.keys)
     {
     aliyun configure set --profile akProfile --mode AK --region $regionid --access-key-id LTAI5tC2z9SZFZYBhZ3k7rR4 --access-key-secret R51oE1X5h3xrSoBoq5zI7hwmSMff8y
     $bb=aliyun sts AssumeRole --region $regionid --RoleSessionName pan_chenc --RoleArn $arnlist.$s
     $cc=$bb|convertfrom-json
     aliyun configure set --profile stsTokenProfile --mode StsToken --region $regionid --access-key-id $cc.credentials.accesskeyid --access-key-secret $cc.credentials.AccessKeySecret --sts-token $cc.credentials.SecurityToken
     $rdsinstancename=aliyun rds DescribeDBInstances  --RegionId $regionid
     $rdsinstancename_array=$rdsinstancename|convertfrom-json
     $rdsdbinstanceid=($rdsinstancename_array.items.dbinstance.DBInstanceId -split "`n")
     $rdsdbinstanceEngine=($rdsinstancename_array.items.dbinstance.Engine -split "`n")
     $rdsdbinstanceDescription=($rdsinstancename_array.items.dbinstance.DBInstanceDescription -split "`n")
     $rdsdbinstanceStorageType=($rdsinstancename_array.items.dbinstance.DBInstanceStorageType -split "`n")
          
     
     
     
        if (!$rdsdbinstanceid) 
           {
     	  #"There is no rds instance in " + $s | out-file ./rds_backup_logs.txt -Append -Width 1000
     	  $x=$x+"There is no rds instance in $s from $regionid"
     	  }
        else
           {   
           $rdsInstanceInfo= @{}
           for ($o=0; $o -lt $rdsdbinstanceid.length; $o=$o+1)
             {$rdsInstanceInfo.add($rdsdbinstanceid[$o],$rdsdbinstanceEngine[$o])}
     	  
     	  $rdsInstanceInfo_applicationname= @{}
           for ($o=0; $o -lt $rdsdbinstanceid.length; $o=$o+1)
             {$rdsInstanceInfo_applicationname.add($rdsdbinstanceid[$o],$rdsdbinstanceDescription[$o])}
      
     	  $rdsInstanceInfo_StorageType= @{}
           for ($o=0; $o -lt $rdsdbinstanceid.length; $o=$o+1)
             {$rdsInstanceInfo_StorageType.add($rdsdbinstanceid[$o],$rdsdbinstanceStorageType[$o])}
           
           
           foreach ($i in $rdsInstanceInfo.keys)
           {
           $hh=aliyun rds DescribeBackups --DBInstanceId $i
           $gg=$hh|convertfrom-json
           #$gg.items.backup|Select-Object @{name="AliyunAccountName";expression={$s}},@{name="ApplicationName";expression={$rdsInstanceInfo_applicationname.$i}},@{name="Engine";expression={$rdsInstanceInfo.$i}},@{name="DBInstanceId";expression={$_.DBInstanceId}},@{name="BackupType";expression={$_.BackupType}},@{name="BackupStartTime";expression={$_.BackupStartTime}},@{name="BackupEndTime";expression={$_.BackupEndTime}},@{name="BackupStatus";expression={$_.BackupStatus}},@{name="BackupMode";expression={$_.BackupMode}},@{name="BackupMethod";expression={$_.BackupMethod}},@{name="BackupSize";expression={$_.BackupSize}} |Format-Table -AutoSize -Wrap | out-file ./rds_backup_logs.txt -Append -Width 1000
           #$gg.items.backup|Select-Object @{name="AliyunAccountName";expression={$s}},@{name="ApplicationName";expression={$rdsInstanceInfo_applicationname.$i}},@{name="Engine";expression={$rdsInstanceInfo.$i}},@{name="DBInstanceId";expression={$_.DBInstanceId}},@{name="BackupType";expression={$_.BackupType}},@{name="BackupStartTime";expression={$_.BackupStartTime}},@{name="BackupEndTime";expression={$_.BackupEndTime}},@{name="BackupStatus";expression={$_.BackupStatus}},@{name="BackupMethod";expression={$_.BackupMethod}},@{name="BackupSize";expression={$_.BackupSize}} |Format-Table -AutoSize -Wrap | out-file ./rds_backup_logs.txt -Append -Width 1000
           $g2=$gg.items.backup|Select-Object @{name="AliyunAccountName";expression={$s}},@{name="ProjectName";expression={$projectName.$i}},@{name="Region";expression={$regionid}},@{name="ApplicationName";expression={$rdsInstanceInfo_applicationname.$i}},@{name="Engine";expression={$rdsInstanceInfo.$i}},@{name="StorageType";expression={$rdsInstanceInfo_StorageType.$i}},@{name="DBInstanceId";expression={$_.DBInstanceId}},@{name="BackupType";expression={$_.BackupType}},@{name="BackupStartTime";expression={$_.BackupStartTime}},@{name="BackupEndTime";expression={$_.BackupEndTime}},@{name="BackupStatus";expression={$_.BackupStatus}},@{name="BackupMethod";expression={$_.BackupMethod}},@{name="BackupSize";expression={$_.BackupSize}} 
           
     	  $f1=$f1+$g2
           
     	  ##the recent status is only listed in the first place, so only need to fetch the zero index
           $kk=$gg.items.backup.backupstatus
           if (!$kk[0] -eq "Success"){
              $todayissue=$todayissue+1
              $count=$count+1
           }else{
              $count=$count+1
           }
     
     	  
           foreach ($i in $kk)
           {
             #$count=$count+1
             if (!$i -eq "Success")
               {$totalissue=$totalissue+1}	  
           }
     
           }
           }
     
     }
     

     
     foreach ($s in $arnlist.keys)
     {
     aliyun configure set --profile akProfile --mode AK --region $regionid --access-key-id LTAI5tC2z9SZFZYBhZ3k7rR4 --access-key-secret R51oE1X5h3xrSoBoq5zI7hwmSMff8y
     $bb=aliyun sts AssumeRole --region $regionid --RoleSessionName pan_chenc --RoleArn $arnlist.$s
     $cc=$bb|convertfrom-json
     aliyun configure set --profile stsTokenProfile --mode StsToken --region $regionid --access-key-id $cc.credentials.accesskeyid --access-key-secret $cc.credentials.AccessKeySecret --sts-token $cc.credentials.SecurityToken
     
     $polardbclustername=aliyun polardb DescribeDBClusters --RegionId $regionid
     $polardbclustername_array=$polardbclustername|convertfrom-json
     $polardbclustername_dbclusterid=($polardbclustername_array.Items.DBCluster.DBClusterId -split "`n")
     $polardbclustername_dbtype=($polardbclustername_array.Items.DBCluster.Engine -split "`n")
     $polardbclustername_applicationname=($polardbclustername_array.Items.DBCluster.DBClusterDescription -split "`n")
     $polardbclusternameStorageType=($polardbclustername_array.items.DBCluster.DBClusterStorageType -split "`n")
     
     
        if (!$polardbclustername_dbclusterid)
           {
     	  #"There is no polardb cluster in " + $s | out-file ./rds_backup_logs.txt -Append -Width 1000
     	  $x=$x+"There is no polardb instance in $s from $regionid"
     	  }
        else
           {
           $polardbInstanceInfo= @{}
           for ($o=0; $o -lt $polardbclustername_dbclusterid.length; $o=$o+1)
             {$polardbInstanceInfo.add($polardbclustername_dbclusterid[$o],$polardbclustername_dbtype[$o])}
           
           $polardbInstanceInfo_applicationname= @{}
           for ($o=0; $o -lt $polardbclustername_dbclusterid.length; $o=$o+1)
             {$polardbInstanceInfo_applicationname.add($polardbclustername_dbclusterid[$o],$polardbclustername_applicationname[$o])}

     	   $polardbInstanceInfo_StorageType= @{}
           for ($o=0; $o -lt $polardbclustername_dbclusterid.length; $o=$o+1)
             {$polardbInstanceInfo_StorageType.add($polardbclustername_dbclusterid[$o],$polardbclusternameStorageType[$o])}
           
           
           foreach ($i in $polardbInstanceInfo.keys)
             {
             $hh=aliyun polardb DescribeBackups --DBClusterId $i --StartTime $startdate --EndTime $enddate
             $gg=$hh|convertfrom-json
             $g3=$gg.items.backup|Select-Object @{name="AliyunAccountName";expression={$s}},@{name="ProjectName";expression={$projectName.$i}},@{name="Region";expression={$regionid}},@{name="ApplicationName";expression={$polardbInstanceInfo_applicationname.$i}},@{name="Engine";expression={$polardbInstanceInfo.$i}},@{name="StorageType";expression={$polardbInstanceInfo_StorageType.$i}},@{name="DBInstanceId";expression={$i}},@{name="BackupType";expression={$_.BackupType}},@{name="BackupStartTime";expression={$_.BackupStartTime}},@{name="BackupEndTime";expression={$_.BackupEndTime}},@{name="BackupStatus";expression={$_.BackupStatus}},@{name="BackupMethod";expression={$_.BackupMethod}},@{name="BackupSize";expression={$_.BackupSetSize}} 
     
     	  $f2=$f2+$g3
     
           $kk=$gg.items.backup.backupstatus
           if (!$kk[0] -eq "Success")
           {
              $todayissue=$todayissue+1
              $count=$count+1
           }else
           {
              $count=$count+1
           }
     	  
           foreach ($i in $kk)
           {
             #$count=$count+1
             if (!$i -eq "Success")
               {$totalissue=$totalissue+1}
           }
     
             }
           }
     }
}



#$f1 | Format-Table -AutoSize -Wrap | out-file ./rds_backup_logs.txt -Append -Width 1000
$f1 | export-excel ./$outputexcelfilename -Append -AutoSize -BoldTopRow 


#$f2 | Format-Table -AutoSize -Wrap | out-file ./rds_backup_logs.txt -Append -Width 1000
$f2 | export-excel ./$outputexcelfilename -Append -AutoSize -BoldTopRow


## column name will only be fetched from the first data content, the data after that will not be display on sheet, so the string messages must be display on the tail of the sheet.
#$x | export-excel ./$outputexcelfilename -Append -AutoSize -BoldTopRow

$objExcel = New-Object -ComObject excel.application
$path = "C:\Users\pan_chenc\" #待打开文件
$filefullpath=$path+$outputexcelfilename
$workbook = $objExcel.workbooks.open($filefullpath) #获取工作簿对象

$ws=$workbook.WorkSheets.item(1)#获取工作表对象，也可以通过item("Sheet1")
$ws.UsedRange.select()
$ws.UsedRange.cells.borders.Weight = 3
$workbook.save()
$workbook.close()#关闭工作簿
$objExcel.Quit()#退出Excel程序

$From = "chencpan@hanglung.com"
$To = "chencpan@hanglung.com"
$Copy = "chencpan@hanglung.com"
$Attachment = "./$outputexcelfilename"
$Subject = "Aliyun RDS/polardb backup daily report"
$Body = "$todayissue abnormality was found for today.`n$totalissue abnormality was found in today's report for past 7 days."
$SMTPServer = "cmo-smtp01.hanglung.net"
$SMTPPort = "587"
Send-MailMessage -From $From -to $To -Cc $Copy -Subject $Subject -Body $Body -SmtpServer $SMTPServer -Port $SMTPPort -Attachments $Attachment






#$xlFixedFormat = "Microsoft.Office.Interop.Excel.xlFixedFormatType" -as [type] #设置excel文件类型
#$objExcel = New-Object -ComObject excel.application #创建excel对象
#$objExcel.visible = $false 
#$path = "C:\Users\Administrator\Desktop\test.xls" #待打开文件
#$objExcel.workbooks.Add()#创建新的工作簿
#$workbook = $objExcel.workbooks.open($path) #获取工作簿对象
#$ws=$workbook.WorkSheets.item(1)#获取工作表对象，也可以通过item("Sheet1")
#$workbook.activate()#激活工作簿
#$ws.activate()#激活工作表
#$workbook.save()#保存工作簿
#$workbook.saveas("C:\Users\Administrator\desktop\save.xlsx")#另存工作簿
#$workbook.close()#关闭工作簿
#$objExcel.Quit()#退出Excel程序
#
#
#
#
#$xlFixedFormat = "Microsoft.Office.Interop.Excel.xlFixedFormatType" -as [type] #设置excel文件类型
#$objExcel = New-Object -ComObject excel.application #创建excel对象
#$objExcel.visible = $false 
#





#$outputexcelfilename='rds_backup_logs_2023-05-10_143907.xlsx'
#
#$objExcel = New-Object -ComObject excel.application
#$path = "C:\Users\pan_chenc\" #待打开文件
#$filefullpath=$path+$outputexcelfilename
#$workbook = $objExcel.workbooks.open($filefullpath) #获取工作簿对象
#
#$ws=$workbook.WorkSheets.item(1)#获取工作表对象，也可以通过item("Sheet1")
#$ws.range("1:1").select()#选择第一行
#$ws.range("1:1").font.Size = 12#设置字体大小
#$ws.range("1:1").font.bold = "true"#设置加粗
#$workbook.save()
#$workbook.close()#关闭工作簿
#$objExcel.Quit()#退出Excel程序
