
<#
	.DESCRIPTION
		This script deletes a DNS records 
	.EXAMPLES
			A Record
				.\delete-dns-records.ps1 -Body '{"record_type":"a", "hostname":"testapp", "zone":"acme.com", "computer_ip":"10.1.20.150" }'
			PTR Record
	.NOTES
       Deletes all record types
#>

param(
    $body
    
)

# This Section Parses the body Parameter
# You will need to customize this section to consume the Json correctly for your application
$newbody = $body | ConvertFrom-Json

$record_type = $newbody.record_type
#Write-Host "Type: $record_type"
$hostname = $newbody.hostname
#Write-Host " HostName: $name"
$zone = $newbody.zone
#Write-Host " Zone Name: $zone"
$computer_ip = $newbody.computer_ip
#Write-Host "Computer IP: $computer_ip"

$record_type = $record_type.ToUpper()
$hostname = $hostname.ToLower()
$computer_ip = $computer_ip.ToLower()
$zone = $zone.ToLower()


 
 
 Remove-DnsServerResourceRecord -ZoneName $Zone -RRType $record_type -Name $hostname -RecordData $computer_ip -ComputerName "dc1.f5lab.local" -Force
 
 #Sets the error message based on success or failure 
 
 if ($?) {
 	$status = "Success"
    $jsonresponse = New-Object -TypeName psobject
	$jsonresponse| Add-Member -MemberType NoteProperty -Name status -Value $status
	$jsonresponse| Add-Member -MemberType NoteProperty -Name record_type -Value $record_type
    $jsonresponse| Add-Member -MemberType NoteProperty -Name hostname -Value $hostname
    $jsonresponse| Add-Member -MemberType NoteProperty -Name zone -Value $zone
    $jsonresponse| Add-Member -MemberType NoteProperty -Name computer_ip -Value $computer_ip
 
 	$Message = $jsonresponse | Select-Object status, record_type, hostname, zone, computer_ip
 
    
 } else {


 $status = "Fail"
 $jsonresponse = New-Object -TypeName psobject
 $jsonresponse| Add-Member -MemberType NoteProperty -Name status -Value $status
 $jsonresponse| Add-Member -MemberType NoteProperty -Name record_type -Value $record_type
 $jsonresponse| Add-Member -MemberType NoteProperty -Name hostname -Value $hostname
 $jsonresponse| Add-Member -MemberType NoteProperty -Name zone -Value $zone
 $jsonresponse| Add-Member -MemberType NoteProperty -Name computer_ip -Value $computer_ip
 
 $Message = $jsonresponse | Select-Object status, record_type, hostname, zone, computer_ip
 }
 
 return $message




