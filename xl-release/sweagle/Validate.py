import requests
from requests.auth import HTTPBasicAuth
import json

if sweagleTenant is None:
    print ( "No SWEAGLE tenant provided." )
    sys.exit(1)

headers = {"Authorization": "Bearer {0}".format(sweagleTenant['token']),
            "Accept": "application/json",
            "Content-Type": "application/json"}
#For DEBUG print('* headers: {0}'.format(headers))
status = True
# In Jython True=1, False=0
errorMsg = ""
mds = mds.replace("/", "-")


print ("\r *** First, check status with SWEAGLE standard validator")
url = "{0}/api/v1/data/include/validate?name={1}&format=json&forIncoming=true".format(sweagleTenant['url'], mds)
#For DEBUG print('* url: {0}'.format(url))
r = requests.get(url, headers=headers, verify=False)

if r.status_code == requests.codes.ok:
    response = r.json()
    #print("* SWEAGLE response: {}".format(json.dumps(response)))
    print ""
    if int(response['summary']['errors']) > 0:
        status = False
        print "\r *** BROKEN CONFIGURATION: " + json.dumps(response['errors'])
        errorMsg = json.dumps(response['errors'])
    else:
        print "standard validators passed successfully"
else:
    raise Exception("%s: HTTP response code %s (%s)" % (url, r.status_code, r.json()))

print ("\r *** Second, check status with SWEAGLE custom validator(s)")
for validator in validators:
    print ("* Check status for validator: " + validator)
    url = "{0}/api/v1/tenant/metadata-parser/validate?mds={1}&parser={2}&forIncoming=".format(sweagleTenant['url'],
        mds, validator)
    r = requests.post(url + "true", headers=headers, verify=False)
    response = r.json()
    if r.status_code == 404 and response['error'] == "NotFoundException":
        # API got error that pending MDS not found, retry for last valid snapshot
        print ("\r *** No pending MDS found, check last snapshot instead")
        r = requests.post(url + "false", headers=headers, verify=False)

    if r.status_code == requests.codes.ok:
        response = r.json()
        #print("* SWEAGLE response: {}".format(json.dumps(response)))
        if response['result'] == False:
            status = False
            print "\r *** BROKEN CONFIGURATION: " + json.dumps(response['description'])
            errorMsg = errorMsg + "\r\n" + json.dumps(response['description'])
        else:
            print " - validator passed successfully"
    else:
        raise Exception("%s: HTTP response code %s (%s)" % (url, r.status_code, r.json()))

if status == False:
        print ""
        #task.fail ()
        sys.exit(1)
