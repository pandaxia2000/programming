param ([string]$SiteName)

$SiteNameList=('Center','Forum','Heartland','Olympia','Palace','Parc','Plaza','River','SpringCity','GG')

if (!$SiteName -Or $SiteNameList -notContains $SiteName){
	write-output "Please input a name of Site  as parameter to restore in DR environment. The Site name must be one of below: `n'Center'`n'GG'`n'Forum'`n'Heartland'`n'Olympia'`n'Palace'`n'Parc'`n'Plaza'`n'River'`n'SpringCity'`n"
	$commandName=$MyInvocation.MyCommand.Name
	write-output "Usage example: .\$commandName Plaza"
	exit
}else {write-output "Now start restoring DR environment from backup of $SiteName"}
