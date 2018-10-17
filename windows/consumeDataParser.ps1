# This powershell script download metadata from Sweagle platform using REST API
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

# Define path and parser you want to use to extract your data
# Each variable of the parser is separated by "," in args variable
$mdsName = "sweagleDemo"
$parserName="returnValueforKey"
$args="testkey3"
$outputFormat="json"

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

$downloadUrl = "https://$sweagleTenant/api/v1/tenant/metadata-parser/parse?mds=$mdsName&parser=$parserName&args=$args&format=$outputFormat"
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", $authHeader)
$headers.Add("Accept", 'application/json')

$response = Invoke-RestMethod -Uri $downloadUrl -Headers $headers -ContentType 'application/json' -Method POST -Verbose
echo "********** upload data response: $response"
