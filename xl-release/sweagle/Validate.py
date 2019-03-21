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

print ("*** First, check status with SWEAGLE standard validator")
url = "{0}/api/v1/data/include/validate?name={1}&format=json&forIncoming=true".format(sweagleTenant['url'], mds)
#For DEBUG print('* url: {0}'.format(url))
r = requests.get(url, headers=headers, verify=False)

if r.status_code == requests.codes.ok:
    response = r.json()
    #print("* SWEAGLE response: {}".format(json.dumps(response)))
    print ""
    if int(response['summary']['errors']) > 0:
        status = False
        print "*** BROKEN CONFIGURATION: " + json.dumps(response['errors'])
        errorMsg = json.dumps(response['errors'])
    else:
        print "standard validators passed successfully"
else:
    raise Exception("%s: HTTP response code %s (%s)" % (url, r.status_code, r.json()))

print ("")
print ("*** Second, check status with SWEAGLE custom validator(s)")
for validator in validators.split():
    print ("* Check status for validator: " + validator)
    url = "{0}/api/v1/tenant/metadata-parser/validate?mds={1}&parser={2}&forIncoming=true".format(sweagleTenant['url'],
        mds, validator)
    r = requests.post(url, headers=headers, verify=False)
    if r.status_code == requests.codes.ok:
        response = r.json()
        #print("* SWEAGLE response: {}".format(json.dumps(response)))
        if response['result'] == False:
            status = False
            print "*** BROKEN CONFIGURATION: " + json.dumps(response['description'])
            errorMsg = errorMsg + "\r\n" + json.dumps(response['description'])
        else:
            print " - validator passed successfully"
    else:
        raise Exception("%s: HTTP response code %s (%s)" % (url, r.status_code, r.json()))

if status == False:
        print ""
        #task.fail ()
        sys.exit(1)
