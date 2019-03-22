import requests
from requests.auth import HTTPBasicAuth
import json

HTTP_CODE_OK = 200
HTTP_ERROR_404 = 404

if sweagleTenant is None:
    print ( "No SWEAGLE tenant provided." )
    sys.exit(1)

if xlDeployServer is None:
	print "No Xl Deploy server provided."
	sys.exit(1)


headers = {"Authorization": "Bearer {0}".format(sweagleTenant['token']),
            "Accept": "application/json",
            "Content-Type": "application/json"}
#For DEBUG print('* headers: {0}'.format(headers))

mds = dicname.replace("/", "-")
# Get last part of dicname, which will be SWEAGLE nodename
nodeName = dicname.rpartition('/')[2]
#For DEBUG print ("\r mds: " + mds)
#For DEBUG print ("\r nodeName: " + nodeName)

print ("\r *** Store snapshot before downloading config")
url = "{0}/api/v1/data/include/snapshot/byname?name={1}&level=warn&description=XL-Deploy".format(sweagleTenant['url'], mds)
#For DEBUG print('* url: {0}'.format(url))
r = requests.post(url, headers=headers, verify=False)
if r.status_code == requests.codes.ok:
	content = r.json()
	#For DEBUG print("\r * SWEAGLE response: {}".format(json.dumps(content)))
else:
    raise Exception("%s: HTTP response code %s (%s)" % (url, r.status_code, r.json()))

print ("\r *** Now, get snapshot config")
url = "{0}/api/v1/tenant/metadata-parser/parse?mds={1}&parser=retrieveAllDataFromNode&args={2}&format=JSON".format(sweagleTenant['url'],
        mds, nodeName)
#For DEBUG print('* url: {0}'.format(url))
r = requests.post(url, headers=headers, verify=False)
if r.status_code == requests.codes.ok:
    content = r.json()
    print("\r * SWEAGLE response: {}".format(json.dumps(content)))
else:
    raise Exception("%s: HTTP response code %s (%s)" % (url, r.status_code, r.json()))

print ("\r *** Final, upload config to XL-Deploy Dictionary")

requestxld = HttpRequest(xlDeployServer, xldUser, xldPassword)

url = "/deployit/repository/ci/{0}".format(dicname)
# BEGIN: This is to use if SWEAGLE contains only key/values of the dictionary
#data = {}
#data['type'] = 'udm.Dictionary'
#data['id'] = dicname
#data['entries']= content
# END: This is to use if SWEAGLE contains only key/values of the dictionary
# BEGIN: This is to use if SWEAGLE contains the full XLD dictionary object
data = content
data['restrictToContainers'] = []
data['restrictToApplications'] = []
# END: This is to use if SWEAGLE contains the full XLD dictionary object

#For DEBUG print('\r * url: {0}'.format(url))
#For DEBUG print("\r * body: {0}".format(json.dumps(data)))

print ("\r * Check if dictionary already exists")
r = requestxld.get(url, contentType = 'application/json')
if r.getStatus() == HTTP_ERROR_404 and r.getResponse().find("not found") :
	print ("\r * Dictionary doesn't exists, create it")
	r = requestxld.post(url, json.dumps(data), contentType = 'application/json')
	if r.getStatus() == HTTP_CODE_OK:
		print("\r * XL-Deploy response: {}".format(r.getResponse()))
		sys.exit(0)

if r.getStatus() != HTTP_CODE_OK:
		print "\r ERROR : %s" % (r.getResponse())
		print "\r Return http code : %s\n" % (r.getStatus())
		raise Exception("\r Import Dictionary error. Please see the error message above")

print ("\r * Dictionary exists, update it")
# But first, get the restrictToContainers part
# For DEBUG print ("\r * Dictionary content : {0}".format(r.getResponse()))
json_dict = json.loads(r.getResponse())
data['restrictToContainers'] = json_dict["restrictToContainers"]
data['restrictToApplications'] = json_dict["restrictToApplications"]
#For DEBUG print("\r * body: {0}".format(json.dumps(data)))

r = requestxld.put(url, json.dumps(data), contentType = 'application/json')
if r.getStatus() != HTTP_CODE_OK:
		print "\r ERROR : %s" % (r.getResponse())
		print "\r Return http code : %s\n" % (r.getStatus())
		raise Exception("\r Import Dictionary error. Please see the error message above")

print("\r * XL-Deploy response: {}".format(r.getResponse()))
