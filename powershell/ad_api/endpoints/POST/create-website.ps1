
<#
	.DESCRIPTION
		This script create an IIS Website
	.EXAMPLES
				.\create-website.ps1 -Body '{"site_name":"solution7.acme.com", "http_port":"80", "https_port":"443", "computer_ip":"10.1.20.6", "authentication": "saml", "idp_name": "idp.acme.com" }'

	.NOTES
		Supports basic,saml, anonymous, and Kerberos configurations.
       
#>



param(
    $body
    
)

import-module webadministration

# This Section Parses the body Parameter
# You will need to customize this section to consume the Json correctly for your application
$newbody = $body | ConvertFrom-Json

$site_name = $newbody.site_name
#Write-Host "Sitename: $site_name"
$http_port = $newbody.http_port
#Write-Host " http_port: $http_port"
$https_port = $newbody.https_port
#Write-Host "https_port: $https_port"
$computer_ip = $newbody.computer_ip
#Write-Host "Computer IP: $computer_ip"
$authentication = $newbody.authentication
#Write-Host "Authentication: $authentication"
$idp_name = $newbody.idp_name
#Write-Host "idp_name: $idp_name"



$websitebase = "c:\infra\websites"

 if(Test-Path IIS:\AppPools\$site_name)
{
"AppPool is already there"
}
else
{
"AppPool is not present"
"Creating new AppPool"
New-WebAppPool $site_name -Force
}



Switch ($authentication)

{ 

	"none" {
	
		New-WebSite -Name $site_name -Port $http_port -HostHeader $site_name -PhysicalPath $websitebase\$site_name -IPAddress $computer_ip -ApplicationPool $site_name -Force
		New-WebBinding -Name $site_name -HostHeader $site_name -IP $computer_ip -Port $https_port -Protocol https
 
		Set-WebConfigurationProperty -Filter "/system.webServer/security/authentication/anonymousAuthentication" -Name Enabled -Value True -PSPath IIS:\ -Location "$site_name"
	}
	"kerberos" {
		New-WebSite -Name $site_name -Port $http_port -HostHeader $site_name -PhysicalPath $websitebase\$site_name -IPAddress $computer_ip -ApplicationPool $site_name -Force
		New-WebBinding -Name $site_name -HostHeader $site_name -IP $computer_ip -Port $https_port -Protocol https
 

		Set-WebConfigurationProperty -Filter /system.webServer/security/authentication/windowsAuthentication -Name Enabled -Value True -PSPath IIS:\ -Location $site_name 
		Set-WebConfigurationProperty -Filter /system.webServer/security/authentication/windowsAuthentication -Name useKernelMode -Value False -PSPath IIS:\ -Location $site_name 
		Remove-WebConfigurationProperty -filter system.webServer/security/authentication/windowsAuthentication/providers -name "." -PSPath IIS:\ -Location $site_name
		Add-WebConfiguration -Filter system.webServer/security/authentication/windowsAuthentication/providers  -Value Negotiate:Kerberos -PSPath IIS:\ -Location $site_name
		Set-WebConfigurationProperty -Filter /system.webServer/security/authentication/anonymousAuthentication -Name Enabled -Value False -PSPath IIS:\ -Location $site_name 
		
	}	
	"basic" {
	
		New-WebSite -Name $site_name -Port $http_port -HostHeader $site_name -PhysicalPath $websitebase\$site_name -IPAddress $computer_ip -ApplicationPool $site_name -Force
		New-WebBinding -Name $site_name -HostHeader $site_name -IP $computer_ip -Port $https_port -Protocol https
 
		Set-WebConfigurationProperty -Filter "/system.webServer/security/authentication/anonymousAuthentication" -Name Enabled -Value False -PSPath IIS:\ -Location "$site_name" 
		Set-WebConfigurationProperty -Filter "/system.webServer/security/authentication/basicAuthentication" -Name Enabled -Value True -PSPath IIS:\ -Location "$site_name"
		Set-WebConfigurationProperty -Filter "/system.webServer/security/authentication/basicAuthentication" -Name defaultLogonDomain -Value f5lab.local -PSPath IIS:\ -Location "$site_name"
		Set-WebConfigurationProperty -Filter "/system.webServer/security/authentication/basicAuthentication" -Name realm -Value F5LAB.LOCAL -PSPath IIS:\ -Location "$site_name"
	}
	"saml" {
		if(Test-Path $websitebase\$site_name) {
				Stop-WebSite -Name $site_name
				Remove-Item $websitebase\$site_name -Recurse -Force
				Copy-Item -Path $websitebase\simplesamlphptemplate -Destination $websitebase\$site_name -Recurse
			}
			else {
				Copy-Item -Path $websitebase\simplesamlphptemplate -Destination $websitebase\$site_name -Recurse
			}
	
		Start-Sleep -Seconds 5
		
		(Get-Content $websitebase\$site_name\config\authsources.php).replace("SITENAME", $site_name) | Set-Content $websitebase\$site_name\config\authsources.php
		
		(Get-Content $websitebase\$site_name\config\authsources.php).replace("IDPNAME", $idp_name) | Set-Content $websitebase\$site_name\config\authsources.php
		(Get-Content $websitebase\$site_name\metadata\saml20-idp-remote.php).replace("IDPNAME", $idp_name) | Set-Content $websitebase\$site_name\metadata\saml20-idp-remote.php
		
		New-WebSite -Name $site_name -Port $http_port -HostHeader $site_name -PhysicalPath $websitebase\$site_name\www -IPAddress $computer_ip -ApplicationPool $site_name -Force
		New-WebBinding -Name $site_name -HostHeader $site_name -IP $computer_ip -Port $https_port -Protocol https
 
		Set-WebConfigurationProperty -Filter "/system.webServer/security/authentication/anonymousAuthentication" -Name Enabled -Value True -PSPath IIS:\ -Location "$site_name" 
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
    $jsonresponse| Add-Member -MemberType NoteProperty -Name computer_ip -Value $computer_ip
	$jsonresponse| Add-Member -MemberType NoteProperty -Name authentication -Value $authentication
 
 	$Message = $jsonresponse | Select-Object status, site_name, http_port, https_port, computer_ip, authentication
 
    
 } else {


	$status = "Fail"
	$jsonresponse| Add-Member -MemberType NoteProperty -Name status -Value $status
	$jsonresponse| Add-Member -MemberType NoteProperty -Name site_name -Value $site_name
    $jsonresponse| Add-Member -MemberType NoteProperty -Name http_port -Value $http_port
	$jsonresponse| Add-Member -MemberType NoteProperty -Name https_port -Value $https_port
    $jsonresponse| Add-Member -MemberType NoteProperty -Name computer_ip -Value $computer_ip
	$jsonresponse| Add-Member -MemberType NoteProperty -Name authentication -Value $authentication
 
 	$Message = $jsonresponse | Select-Object status, site_name, http_port, https_port, computer_ip, authentication
 }
 
 return $message




