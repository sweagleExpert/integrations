import requests
from requests.auth import HTTPBasicAuth

if sweagleTenant is None:
    print ( "No SWEAGLE tenant provided." )
    sys.exit(1)

headers = { "Accept": "application/json",
            "Content-Type": "application/json" }
url = "{0}/info".format(sweagleTenant['url'])
#print('* url: {0}'.format(url))
r = requests.get(url, headers=headers, verify=False)

if r.status_code == requests.codes.ok:
    response = r.json()
    print("* SWEAGLE version: " + response['build']['version'])
else:
    raise Exception("%s: HTTP response code %s (%s)" % (url, r.status_code, r.json()))
