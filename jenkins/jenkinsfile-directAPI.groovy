import groovy.json.JsonSlurper

def CONFIG_DIR = "<DIRECTORY OR FILE WHERE YOU PUT YOUR CONFIG TO UPLOAD TO SWEAGLE> ex: ./conf"
def SWEAGLE_PATH = "<PATH IN DATA MODEL WHERE YOU WANT TO PUT YOUR CONFIG DATA> ex: dimension,node1,node2"
def SWEAGLE_MDS = "<METADATASET YOU WANT TO GET CONFIG DATA FROM> ex: $APP_NAME-$ENV_NAME or dimension"
def SWEAGLE_VALIDATORS = "<OPTIONAL, LIST OF CUSTOM VALIDATORS, SEPARATED BY SPACES, USED TO CHECK YOUR CONFIG> ex: noDevValues noEmptyValues passwordChecker"
def SWEAGLE_EXPORTER = "<EXPORTER USED TO RETRIEVE YOUR CONFIG> ex: all or returnDataForNode"
def SWEAGLE_EXPORTER_ARGS = "<OPTIONAL, EXPORTER ARGUMENTS IF ANY, SEPARATED BY COMMA> ex: node1"
def SWEAGLE_EXPORTER_FORMAT = "<OPTIONAL, FORMAT USED FOR DOWNLOADED CONFIG: PROPS (DEFAULT), YAML, JSON, XML> ex: JSON"
def SWEAGLE_EXPORTER_OUTPUT = "<OPTIONAL, TARGET FILE TO EXPORT CONFIG DATA TO, DEFAULT OUTPUT IS SCREEN> ex: /release/node1-conf.json"
def SWEAGLE_SNAPSHOT_TAG = "<OPTIONAL,TAG OF SNAPSHOT TO GET, DEFAULT IS LATEST SNAPSHOT> ex: v2"


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
      def response = new JsonSlurper().parseText(callSweagleAPI('POST', api, body))
      println "API response: "+response
      if (response.errorFound) { error("### UPLOAD FAILED") }
      else { println "### UPLOAD SUCCESSFULL" }
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
def callSweagleAPI(method, api, def body=null) {
  def errorFound = false
  def SWEAGLE_TENANT = "<YOUR SWEAGLE TENANT> ex: https://testing.sweagle.com"
  def SWEAGLE_TOKEN = "<YOUR API TOKEN, ENSURE IT HAS SUFFICIENT PRIVILEGES> ex: XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
  def sweagleCall = new URL(SWEAGLE_TENANT + api).openConnection() as HttpURLConnection
  sweagleCall.setRequestMethod(method)
  sweagleCall.setRequestProperty("Accept", '*/*')
  sweagleCall.setRequestProperty("Content-Type", 'application/json')
  sweagleCall.setRequestProperty("Authorization", 'Bearer ' + SWEAGLE_TOKEN)
  if (body != null) {
    sweagleCall.setDoOutput(true)
    sweagleCall.outputStream.write(body.getBytes("UTF-8"))
  }
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
