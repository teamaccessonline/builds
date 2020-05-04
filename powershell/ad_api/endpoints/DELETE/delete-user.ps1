<#
	.DESCRIPTION
		This script deletes a user account from Active Directory
	.EXAMPLE
        delete-user.ps1 -RequestArgs  useridentity=user3
	.NOTES
        This will return a status message of Success or Failure
#>

param(
    $RequestArgs
    
)
 
 if (!$RequestArgs) {
  return "useridentity parameter must be supplied in query string. Example https://10.1.20.6/user?useridentity="

 }

 $Property, $user = $RequestArgs.split("=")

 Remove-ADUser $user -Confirm:$False
 if ($?) {
    $status = "Success"
    $jsonresponse = New-Object -TypeName psobject
    $jsonresponse| Add-Member -MemberType NoteProperty -Name status -Value $status
    $jsonresponse| Add-Member -MemberType NoteProperty -Name useridentity -Value $user

 
 	$Message = $jsonresponse | Select-Object status, useridentity
 } else {
      $status = "Fail"
    $jsonresponse = New-Object -TypeName psobject
    $jsonresponse| Add-Member -MemberType NoteProperty -Name status -Value $status
    $jsonresponse| Add-Member -MemberType NoteProperty -Name useridentity -Value $user

 
 	$Message = $jsonresponse | Select-Object status, useridentity
 }
 return $Message
 
 