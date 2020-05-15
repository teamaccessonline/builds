
<#
	.DESCRIPTION
		This script create an IIS Website
	.EXAMPLES
				.\create-website.ps1 -Body '{"site_name":"testsite.acme.com", "http_port":"80", "https_port":"443","folder":"header.acme.com", "computer_ip":"10.1.20.6", "authentication": "kerberos" }'

	.NOTES
       
#>

param(
    $body
    
)

# This Section Parses the body Parameter
# You will need to customize this section to consume the Json correctly for your application
$newbody = $body | ConvertFrom-Json

$site_name = $newbody.site_name
#Write-Host "Sitename: $site_name"
$http_port = $newbody.http_port
#Write-Host " http_port: $http_port"
$https_port = $newbody.https_port
#Write-Host "https_port: $https_port"
$folder = $newbody.folder
#Write-Host " folder: $folder"
$computer_ip = $newbody.computer_ip
#Write-Host "Computer IP: $computer_ip"
$authentication = $newbody.authentication
#Write-Host "Authentication: $authentication"


$IISPath = "IIS:\AppPools"
$endpointPath = "C:\infra\powershell\ad_api\endpoints\POST"
cd $IISPath
if (Test-Path ".\$site_name") {
 Write-Host "Pool exists."
 cd $endpointPath
 
 } else {
 New-WebAppPool $site_name
 cd $endpointPath
 }



  
 

 New-WebSite -Name $site_name -Port $http_port -HostHeader $site_name -PhysicalPath C:\infra\websites\iis\$folder -IPAddress $computer_ip -ApplicationPool $site_name -Force
 New-WebBinding -Name $site_name -HostHeader $site_name -IP $computer_ip -Port $https_port -Protocol https
 

Switch ($authentication)

{ 

	"none" {Set-WebConfigurationProperty -Filter "/system.webServer/security/authentication/anonymousAuthentication" -Name Enabled -Value True -PSPath IIS:\ -Location "$site_name" }

	"kerberos" {

		Set-WebConfigurationProperty -Filter /system.webServer/security/authentication/windowsAuthentication -Name Enabled -Value True -PSPath IIS:\ -Location $site_name 
		Set-WebConfigurationProperty -Filter /system.webServer/security/authentication/windowsAuthentication -Name useKernelMode -Value False -PSPath IIS:\ -Location $site_name 
		Remove-WebConfigurationProperty -filter system.webServer/security/authentication/windowsAuthentication/providers -name "." -PSPath IIS:\ -Location $site_name
		Add-WebConfiguration -Filter system.webServer/security/authentication/windowsAuthentication/providers  -Value Negotiate:Kerberos -PSPath IIS:\ -Location $site_name
		Set-WebConfigurationProperty -Filter /system.webServer/security/authentication/anonymousAuthentication -Name Enabled -Value False -PSPath IIS:\ -Location $site_name 
		
	}
	
	"basic" {
		Set-WebConfigurationProperty -Filter "/system.webServer/security/authentication/anonymousAuthentication" -Name Enabled -Value False -PSPath IIS:\ -Location "$site_name" 
		Set-WebConfigurationProperty -Filter "/system.webServer/security/authentication/basicAuthentication" -Name Enabled -Value True -PSPath IIS:\ -Location "$site_name"
		Set-WebConfigurationProperty -Filter "/system.webServer/security/authentication/basicAuthentication" -Name defaultLogonDomain -Value f5lab.local -PSPath IIS:\ -Location "$site_name"
		Set-WebConfigurationProperty -Filter "/system.webServer/security/authentication/basicAuthentication" -Name realm -Value F5LAB.LOCAL -PSPath IIS:\ -Location "$site_name"
		}




}
 
 Start-WebSite -Name $site_name
 
 #Sets the error message based on success or failure 
 
 if ($?) {
 	$status = "Success"
    $jsonresponse = New-Object -TypeName psobject
	$jsonresponse| Add-Member -MemberType NoteProperty -Name status -Value $status
	$jsonresponse| Add-Member -MemberType NoteProperty -Name site_name -Value $site_name
    $jsonresponse| Add-Member -MemberType NoteProperty -Name http_port -Value $http_port
	$jsonresponse| Add-Member -MemberType NoteProperty -Name https_port -Value $https_port
    $jsonresponse| Add-Member -MemberType NoteProperty -Name folder -Value $folder
    $jsonresponse| Add-Member -MemberType NoteProperty -Name computer_ip -Value $computer_ip
	 $jsonresponse| Add-Member -MemberType NoteProperty -Name authentication -Value $authentication
 
 	$Message = $jsonresponse | Select-Object status, site_name, http_port, https_port, folder, computer_ip, authentication
 
    
 } else {


	$status = "Fail"
	$jsonresponse| Add-Member -MemberType NoteProperty -Name status -Value $status
	$jsonresponse| Add-Member -MemberType NoteProperty -Name site_name -Value $site_name
    $jsonresponse| Add-Member -MemberType NoteProperty -Name http_port -Value $http_port
	$jsonresponse| Add-Member -MemberType NoteProperty -Name https_port -Value $https_port
    $jsonresponse| Add-Member -MemberType NoteProperty -Name folder -Value $folder
    $jsonresponse| Add-Member -MemberType NoteProperty -Name computer_ip -Value $computer_ip
	$jsonresponse| Add-Member -MemberType NoteProperty -Name authentication -Value $authentication
 
 	$Message = $jsonresponse | Select-Object status, site_name, http_port, https_port, folder, computer_ip, authentication
 }
 
 return $message




