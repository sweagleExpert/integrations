# This powershell script upload metadata to Sweagle platform using REST API
# Version 0.1
# Author : Dimitris Finas

# Force execution policy to allow Rescript to run
# Use UNRESTRICTED if you should run this script remotely
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy REMOTESIGNED

# Parameters used for API calls
$sweagleTenant="testing.sweagle.com"
$sweagleUserName="TBD"
$sweagleUserPassword="TBD"
$sweagleAuthString="TBD"

# Define Path and metadata where you want to upload your data
# path is defined by each of the node names separated by ,
$nodePath = "sweagleDemo"
# it is defined by each pair key = value
$payload = @{testkey = "test-value"; testkey2 = "test-value17"; testcomponent = @{ testkey3 = "test-value3"}}


#general settings for the REST data upload
$argFormat="json"
$argDeleteData="false"
$argDcsApprove="true"
$argCreateSnapshot="true"
$argSnapshotLevel="error"


# Function to get Sweagle token
function getAccessToken ($tenant, $user, $pwd, $authString)
{
$authUrl = "https://$tenant/oauth/token?grant_type=password&username=$user&password=$pwd"
$headers = @{ Authorization = "Basic $authString" }

$response = Invoke-RestMethod -Uri $authUrl -Headers $headers -Method POST -ContentType 'application/json'

$token_type = $response.token_type
$access_token = $response.access_token
$authHeader = "$token_type $access_token"

return $authHeader
}


$authHeader = getAccessToken $sweagleTenant $sweagleUserName $sweagleUserPassword $sweagleAuthString
echo "********** token received : $authHeader"

$uploadUrl = "https://$sweagleTenant/api/v1/data/bulk-operations/dataLoader/upload?nodePath=$nodePath&format=$argFormat&autoApprove=$argDcsApprove&storeSnapshotResults=$argCreateSnapshot&allowDelete=$argDeleteData"
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", $authHeader)
$headers.Add("Accept", 'application/json')

$body = ConvertTo-Json $payload

#echo "For debugging purpose:"
#echo $uploadUrl
#echo $body

$response = Invoke-RestMethod -Uri $uploadUrl -Headers $headers -ContentType 'application/json' -Method POST -Body $body -Verbose
echo "********** upload data response: $response"
