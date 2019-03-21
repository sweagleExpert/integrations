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

print ("Store snapshot before downloading config")
url = "{0}/api/v1/data/include/snapshot/byname?name={1}&level=warn&description=XL-Deploy".format(sweagleTenant['url'], mds)
#For DEBUG print('* url: {0}'.format(url))
r = requests.post(url, headers=headers, verify=False)
if r.status_code == requests.codes.ok:
    content = r.json()
    print("* SWEAGLE response: {}".format(json.dumps(content)))
else:
    raise Exception("%s: HTTP response code %s (%s)" % (url, r.status_code, r.json()))

print ("Now get snapshot config")
url = "{0}/api/v1/tenant/metadata-parser/parse?mds={1}&parser={2}&args={3}&format=JSON".format(sweagleTenant['url'],
        mds, parser, args, format)
#For DEBUG
#print('* url: {0}'.format(url))
r = requests.post(url, headers=headers, verify=False)
if r.status_code == requests.codes.ok:
    content = r.json()
    print("* SWEAGLE response: {}".format(json.dumps(content)))
else:
    raise Exception("%s: HTTP response code %s (%s)" % (url, r.status_code, r.json()))
