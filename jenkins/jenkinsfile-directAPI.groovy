import groovy.json.JsonSlurper

def SWEAGLE_TENANT = "https://testing.sweagle.com"
def SWEAGLE_TOKEN = "02eb161a-d8e6-43a6-883e-affcdd0b5975"

def CONFIG_FILE = "./conf/toto.json"
def CONFIG_FORMAT = "json"
def SWEAGLE_PATH = "test-token"
def SWEAGLE_MDS = "test-token"
def SWEAGLE_VALIDATORS = "noEmptyValues noDevValue"
def SWEAGLE_EXPORTER = "all"
def SWEAGLE_EXPORTER_ARGS = ""
def SWEAGLE_EXPORTER_FORMAT = "JSON"
def SWEAGLE_EXPORTER_OUTPUT = "<OPTIONAL, TARGET FILE TO EXPORT CONFIG DATA TO, DEFAULT OUTPUT IS SCREEN> ex: /release/node1-conf.json"
def SWEAGLE_SNAPSHOT_TAG = ""


node {
    //checkout scm

    stage('Test API - CheckVersion') {
      echo '######################################################'
      echo '### Check Version'
      def api = "/info"
      def response = callSweagleAPI('GET',api)
      println "API response: "+response
    }

    stage('UploadConfig') {
      echo '######################################################'
      echo '### Upload Configuration files to SWEAGLE'
      def argDcsApprove="true"
      def argDeleteData="false"
      def argEncoding="utf-8"
      def argIdentifierWords=""
      def argOnlyParent="true"
      def argSnapshotCreate="false"
      def argSnapshotLevel="warn"
      //String body = new File(CONFIG_FILE).text
      def body = '{"id": 122}'
      def api="/api/v1/data/bulk-operations/dataLoader/upload?nodePath="+SWEAGLE_PATH+
        "&format="+CONFIG_FORMAT+"&allowDelete="+argDeleteData+"&onlyParent="+argOnlyParent+"&autoApprove="+argDcsApprove+
        "&storeSnapshotResults="+argSnapshotCreate+"&validationLevel="+argSnapshotLevel+"&encoding="+argEncoding+
        "&identifierWords="+argIdentifierWords
      def sweagleUrl = new URL(SWEAGLE_TENANT + api)
      println ("sweagleUrl="+sweagleUrl)
      def sweagleCall = sweagleUrl.openConnection() as HttpURLConnection
      sweagleCall.setRequestMethod('POST')
      sweagleCall.setDoOutput(true)
      sweagleCall.setRequestProperty("Accept", '*/*')
      sweagleCall.setRequestProperty("Content-Type", 'application/json')
      sweagleCall.setRequestProperty("Authorization", 'Bearer ' + SWEAGLE_TOKEN)
      sweagleCall.outputStream.write(body.getBytes("UTF-8"))
      sweagleCall.connect()
      def response = [:]
      println "API responseCode: "+sweagleCall.responseCode
      if (sweagleCall.responseCode == 200 || sweagleCall.responseCode == 201) {
        println "# Upload successfull"
      } else {
        response = new JsonSlurper().parseText(sweagleCall.errorStream.getText('UTF-8'))
        println "API response: "+response
        error("### Upload failed.")
      }
    }

    stage('CheckConfig') {
      echo '######################################################'
      echo '### Ask SWEAGLE to check your configuration'
      def errorFound = 0
      def forIncoming = true
      def validators = SWEAGLE_VALIDATORS.split()
      for (i=0; i<validators.length; i++) {
        println("# Check with validator: "+validators[i])
        def api = "/api/v1/tenant/metadata-parser/validate?mds="+SWEAGLE_MDS+"&parser="+validators[i]+"&forIncoming="+forIncoming
        def response = new JsonSlurper().parseText(callSweagleAPI('POST', api))
        println ("API response="+response)
        if (response.errorFound && response.description.error == 'NotFoundException') {
          println "### No pending metadataset, validate last snapshot instead"
          forIncoming = false
          api="/api/v1/tenant/metadata-parser/validate?mds="+SWEAGLE_MDS+"&parser="+validators[i]+"&forIncoming="+forIncoming
          response = new JsonSlurper().parseText(callSweagleAPI('POST', api))
        }
        if (response.errorFound) {
          // This is parser failure
          errorFound = errorFound + 1
          println "# Validator "+validators[i]+" failed with error:"+response.description
        } else {
          // This is ok (code 2xx)
          println "# Validator "+validators[i]+" passed successfully"
        }
      }
      if (errorFound > 0) { error("### VALIDATION FAILED. NB OF VALIDATORS FAILED: "+errorFound) }
      else { println "### VALIDATION PASSED SUCCESSFULLY" }
    }

    stage('DownloadConfig') {
      echo '######################################################'
      echo '### Retrieve lastest valid configuration from SWEAGLE'
      echo '### SWEAGLE will also fill token values, if any'

      println "# Store the config snapshot in order to be able to retrieve it"
      def api="/api/v1/data/include/snapshot/byname?name="+SWEAGLE_MDS+"&level=warn"
      def response = new JsonSlurper().parseText(callSweagleAPI('POST',api))
      if (response.errorFound) {
        error("### SNAPSHOT FAILED. ERROR IS: "+response.description)
      }

      println "# Snapshot successfull, get last config"
      api="/api/v1/tenant/metadata-parser/parse?mds="+SWEAGLE_MDS+"&parser="+SWEAGLE_EXPORTER+ \
      "&args="+SWEAGLE_EXPORTER_ARGS+"&format="+SWEAGLE_EXPORTER_FORMAT+"&tag="+SWEAGLE_SNAPSHOT_TAG+"&picture=false"
      def rawResponse = callSweagleAPI('POST',api)
      println("raw="+rawResponse)
      response = new JsonSlurper().parseText(rawResponse)
      if (response.errorFound) { error("### DOWNLOAD FAILED. ERROR IS: "+response.description) }
      def index=rawResponse.indexOf("\"description\":")
      if (index == -1) { error ("### DOWNLOAD FAILED. UNABLE TO GET CONTENT") }
      def fileContent = rawResponse.substring(index+14,rawResponse.length()-1)
      println " response file: "+ fileContent
      println("### DOWNLOAD SUCCESSFULL")
    }

}

// Function to call a SWEAGLE API
def callSweagleAPI(method, api) {
  def errorFound = false
  def SWEAGLE_TENANT = "https://testing.sweagle.com"
  def SWEAGLE_TOKEN = "02eb161a-d8e6-43a6-883e-affcdd0b5975"
  def sweagleCall = new URL(SWEAGLE_TENANT + api).openConnection() as HttpURLConnection
  sweagleCall.setRequestMethod(method)
  sweagleCall.setRequestProperty("Accept", '*/*')
  sweagleCall.setRequestProperty("Content-Type", 'application/json')
  sweagleCall.setRequestProperty("Authorization", 'Bearer ' + SWEAGLE_TOKEN)
  sweagleCall.connect()
  def response = [:]
  int status = sweagleCall.getResponseCode();
  if (status == HttpURLConnection.HTTP_OK || status == 201) {
    // This is ok (code 2xx)
    response = sweagleCall.inputStream.getText('UTF-8')
  } else if (status == HttpURLConnection.HTTP_MOVED_TEMP || status == HttpURLConnection.HTTP_MOVED_PERM || status == HttpURLConnection.HTTP_SEE_OTHER) {
    // this is a redirect (code 3xx), follow it
    errorFound = true
    response = "Redirect to: "+sweagleCall.getHeaderField("Location");
  } else {
    errorFound = true
    //response = new JsonSlurper().parseText(sweagleCall.errorStream.getText('UTF-8'))
    response = sweagleCall.errorStream.getText('UTF-8')
  }
  return '{"errorFound":'+errorFound+', "description":'+response+'}'
}
