param ([string]$SiteName)

$SiteNameList=('Center','Forum','Heartland','Olympia','Palace','Parc','Plaza','River','SpringCity','GG')

if (!$SiteName -Or $SiteNameList -notContains $SiteName){
	write-output "Please input a name of Site  as parameter to restore in DR environment. The Site name must be one of below: `n'Center'`n'GG'`n'Forum'`n'Heartland'`n'Olympia'`n'Palace'`n'Parc'`n'Plaza'`n'River'`n'SpringCity'`n"
	$commandName=$MyInvocation.MyCommand.Name
	write-output "Usage example: .\$commandName Plaza"
	exit
}else {write-output "Now start restoring DR environment from backup of $SiteName"}


##Defining functions and variables and data dictionary

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
$StoreName=@{}
$today=(Get-Date).tostring('yyyyMMdd')
$date=(Get-Date).adddays(-1)



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

$StoreName.add('Plaza','Plaza')
$StoreName.add('Grand Gateway','GG66')
$StoreName.add('Forum','Forum')
$StoreName.add('Palace','Palace')
$StoreName.add('Center','Center')
$StoreName.add('Parc','Parc')
$StoreName.add('Riverside','Riverside')
$StoreName.add('Olympia','Olympia')
$StoreName.add('SpringCity','SpringCity')
$StoreName.add('Heartland','Heartland')


Stop-Service -Name "Apache Tomcat 7.0 hdhld" -Force
Stop-Service -Name "Apache Tomcat 7.0 mpos" -Force


## Copying HLD folder overwrite the destination

write-output "Start copying HLD folder at $(get-date)"
$FullPathAndName="D:\HLD_FROM_ALL_SITES\"+$SiteName+"\*"
copy-item $FullPathAndName -Destination "D:\java\apache-tomcat-hdhld\webapps" -Force -Recurse
write-output "Copying HLD folder completed at $(get-date)"


## Modify D:\java\apache-tomcat-mpos\webapps\cre-pos\WEB-INF\classes\sql\PosDefaultConfig.sql

write-output "Start modify D:\java\apache-tomcat-mpos\webapps\cre-pos\WEB-INF\classes\sql\PosDefaultConfig.sql at $(get-date)"
$RQcode=$MallcooRQcode.$SiteName
$folderPath = "D:\java\apache-tomcat-mpos\webapps\cre-pos\WEB-INF\classes\sql"
$searchString = "https:\/\/m.mallcoo.cn\/a\/custom\/\d{5}"
$replaceString = "https://m.mallcoo.cn/a/custom/$RQcode"
$filename="PosDefaultConfig.sql"

replace_string $folderPath $searchString $replaceString $filename
write-output "Modify D:\java\apache-tomcat-mpos\webapps\cre-pos\WEB-INF\classes\sql\PosDefaultConfig.sql completed at $(get-date)"



## Modify D:\java\apache-tomcat-mpos\webapps\cre-pos\WEB-INF\classes\cre-pos.properties

write-output "Start modify D:\java\apache-tomcat-mpos\webapps\cre-pos\WEB-INF\classes\cre-pos.properties at $(get-date)"
$filename="cre-pos.properties"
$folderPath = "D:\java\apache-tomcat-mpos\webapps\cre-pos\WEB-INF\classes"

$number=$SiteNumber.$SiteName
$searchString = "^mpos\-core\.member\.dqMallId\=\d{9}"
$replaceString = "mpos-core.member.dqMallId=$number"
replace_string $folderPath $searchString $replaceString $filename

$StoreName=$StoreSiteName.$SiteName
$searchString = "^mpos\-core\.config\.store\=.*$"
$replaceString = "mpos-core.config.store=$StoreName"
replace_string $folderPath $searchString $replaceString $filename
write-output "Modify D:\java\apache-tomcat-mpos\webapps\cre-pos\WEB-INF\classes\cre-pos.properties completed at $(get-date)"





## Modify D:\java\apache-tomcat-hdhld\webapps\HLD\WEB-INF\classes\hibernate.properties

write-output "Start modify D:\java\apache-tomcat-hdhld\webapps\HLD\WEB-INF\classes\hibernate.properties at $(get-date)"
$folderPath = "D:\java\apache-tomcat-hdhld\webapps\HLD\WEB-INF\classes"
$filename="hibernate.properties"

$searchString = "^sales\-server\.config\.mposServer\=.*$"
$replaceString = "sales-server.config.mposServer=http://172.28.0.93:7580/cre-pos"
replace_string $folderPath $searchString $replaceString $filename

$searchString = "^jdbc\.url\=.*$"
$replaceString = "jdbc.url=jdbc:oracle:thin:@//172.28.0.61:1521/HDAPP"
replace_string $folderPath $searchString $replaceString $filename

$searchString = "^jdbc\.username\=.*$"
$replaceString = "jdbc.username=hd40"
replace_string $folderPath $searchString $replaceString $filename

$searchString = "^jdbc\.password\=.*$"
$replaceString = "jdbc.password=heading1234"
replace_string $folderPath $searchString $replaceString $filename
write-output "Modify D:\java\apache-tomcat-hdhld\webapps\HLD\WEB-INF\classes\hibernate.properties completed at $(get-date)"



##Keep monitoring if restore process has been completed in database server

$req=''

do{
Start-Sleep -s 3

try{
   Clear-Variable -Name req
   $req = Invoke-WebRequest -uri "http://172.28.0.61:8280/cre-web" | select statuscode
} catch{
   Write-Output "Status Code --- $($_.Exception.Response.StatusCode.Value__) "
}

}while ($req.statuscode -lt 200 -or $req.statuscode -gt 399)




## Starting services


write-output "Start services at $(get-date)"
Start-Service -Name "Apache Tomcat 7.0 hdhld"
Start-Service -Name "Apache Tomcat 7.0 mpos"
write-output "Start services completed at $(get-date)"
