import requests
from requests.auth import HTTPBasicAuth
import java.net as jnet 
import json
from xml.dom import minidom


if sweagleTenant is None:
    print ( "No SWEAGLE tenant provided." )
    sys.exit(1)

if xlDeployServer is None:
	print "No Xl Deploy server provided."
	sys.exit(1)

lxlddictionaries = []

try:
	requestxld = HttpRequest(xlDeployServer, xldUser, xldPassword)
	url = xlDeployServer["url"]
	if not url.endswith("/"):
		uriprefix = ""
	else:
		uriprefix = "/"
	#End if

	api_uri_dic = uriprefix + "deployit/repository/ci/" + environment
	
	print ("\r *** Get list of Dictionaries from XLD")
	try:
		response = requestxld.get(api_uri_dic, body="", contentType='application/xml')
	except jnet.UnknownHostException as ukhe:
		raise Exception("get dictionaries error : " + str(ukhe) + "\n")

	if response.getStatus() != 200:
		raise Exception("get dictionaries error. Status = [" + str(response.getStatus()) + "] Error : " + response.getResponse())
	#End if
    
	#For DEBUG 
	print ("\r - XLD response: " + response.getResponse())

	xmldoc = minidom.parseString(response.getResponse())

	if xmldoc.getElementsByTagName('ci').length == 0:
		raise Exception ("No dictionaries found for the environment " + environment)

	for resultItem in xmldoc.getElementsByTagName('ci'):
		ref = resultItem.getAttribute("ref")
		lxlddictionaries.append(ref)
	#Fin for resultItem

	for lxlddictionary in lxlddictionaries:
		lxldkeyvalues = dict()
		
		print ("\r *** Get Dictionary data from XLD")
		api_uri_dictionary = uriprefix +  "deployit/repository/ci/" + lxlddictionary
		try:
			response = requestxld.get(api_uri_dictionary, body="", contentType='application/json')
		except jnet.UnknownHostException as ukhe:
			raise Exception("get dictionaries error : " + str(ukhe) + "\n")

		if response.getStatus() != 200:
			raise Exception("get dictionaries error. Status = [" + str(response.getStatus()) + "] Error : " + response.getResponse())
		#End if

        #For DEBUG 
		print("\r - Dictionary :" + response.getResponse())
		
		#data = {}
		#data['type'] = 'udm.Dictionary'
		#data['id'] = lxlddictionary
		#xmldoc = minidom.parseString(response.getResponse())
		#for resultItem in xmldoc.getElementsByTagName('entries').item(0).getElementsByTagName("entry"):
		#	xldkey   = resultItem.getAttribute('key')
		#	if resultItem.firstChild is None:
		#		xldvalue = ""
		#	else:
		#		xldvalue = resultItem.firstChild.nodeValue
		#	#Fin if
		#	
		#	
		#	if xldvalue is None:
		#		xldvalue = ""
		#
		#	lxldkeyvalues[xldkey] = xldvalue
		#Fin for all items in Dictionnary
		#data = json.loads(lxldkeyvalues)
		data = response.getResponse()
		
		print("\r - Send Dictionary " + lxlddictionary + "to SWEAGLE")
		nodePath = lxlddictionary.replace("/", ",")
		
		headers = {"Authorization": "Bearer {0}".format(sweagleTenant['token']),
			"Accept": "application/json",
			"Content-Type": "application/json"}
		
		url = ("{0}/api/v1/data/bulk-operations/dataLoader/upload?"
			"nodePath={1}&format=json&allowDelete=false&onlyParent=true"
			"&autoApprove=true&storeSnapshotResults=false&validationLevel=warn"
			"&encoding=utf-8".format(sweagleTenant['url'], nodePath))
		
		#For DEBUG print('\r * url: {0}'.format(url))
		#For DEBUG print('\r * data: {0}'.format(data))
		#For DEBUG print('\r * headers: {0}'.format(headers))
		r = requests.post(url, headers=headers, data=data, verify=False)
		
		if r.status_code == requests.codes.ok:
			response = r.json()
			print("\r * SWEAGLE response: {}".format(json.dumps(response)))
			print ""
		else:
			raise Exception("%s: HTTP response code %s (%s)" % (url, r.status_code, r.json()))
	#Fin for lxlddictionary

except Exception as e:
	raise e