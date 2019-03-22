import requests
from requests.auth import HTTPBasicAuth
import json

if sweagleTenant is None:
    print ( "No SWEAGLE tenant provided." )
    sys.exit(1)

headers = {"Authorization": "Bearer {0}".format(sweagleTenant['token']),
            "Accept": "application/json",
            "Content-Type": "application/json"}

nodePath = nodePath.replace("/", ",")
			
url = ("{0}/api/v1/data/bulk-operations/dataLoader/upload?"
    "nodePath={1}&format=json&allowDelete=false&onlyParent=true"
    "&autoApprove=true&storeSnapshotResults=false&validationLevel=warn"
    "&encoding=utf-8".format(sweagleTenant['url'], nodePath))

data = content

#For DEBUG
#print('\r * url: {0}'.format(url))
#print('\r * headers: {0}'.format(headers))
r = requests.post(url, headers=headers, data=data, verify=False)

if r.status_code == requests.codes.ok:
    response = r.json()
    print("\r * SWEAGLE response: {}".format(json.dumps(response)))
    print ""
else:
    raise Exception("%s: HTTP response code %s (%s)" % (url, r.status_code, r.json()))
