import tl = require('azure-pipelines-task-lib/task');
import https = require('https');
import tls = require('tls');

const querystring = require('querystring');
const inputOperation: string = manageInput ('operation','info');

async function main() {
  switch (inputOperation) {
    case 'info':
      return info();
      break;
    case 'upload':
      return upload();
      break;
    case 'validate':
      return validate();
      break;
    case 'validationStatus':
      return validationStatus();
      break;
    case 'snapshot':
      return snapshot();
      break;
    case 'export':
      return exportCds();
      break;
    default:
      console.log(`Sorry, ${inputOperation} is not understood.`);
  }
}


///////////////////////////////////////////
// HELPER FUNCTIONS
///////////////////////////////////////////
// Call Sweagle API with common error handling
function callSweagleAPI(apiPath: string, apiMethod: string = 'POST', filepath: string = '') {

  const inputProxyHost: string = manageInput ('proxyHost','');
  const inputProxyPort: string = manageInput ('proxyPort','');
  const inputProxyUser: string = manageInput ('proxyUser','');
  const inputProxyPassword: string = manageInput ('proxyPassword','');
  const inputSweagleHost: string = manageInput ('tenant', 'testing.sweagle.com');
  const inputSweaglePort: string = manageInput ('port', '443');

  var agent = https.globalAgent;
  if (inputProxyHost !== '') {
    console.log("Connection with proxy "+inputProxyHost+":"+inputProxyPort);
    var proxy = 'http://'+inputProxyUser+':'+inputProxyPassword+'@'+inputProxyHost+':'+inputProxyPort;
    var HttpsProxyAgent = require('./HttpsProxyAgent');
    agent = new HttpsProxyAgent(proxy);
  }
  var sweagleTenant = {
    agent: agent,
    host: inputSweagleHost,
    port: inputSweaglePort,
    method: apiMethod,
    path: apiPath,
    headers: { 'Authorization': 'Bearer ' + manageInput ('token') }
  };

  console.log("API PATH="+apiPath);

  return new Promise((resolve, reject) => {
    var body = "";
    const req = https.request(sweagleTenant, (res) => {
      res.setEncoding('utf8');

      // This is to parse chunk of data as soon as you receive it, concatenate it
      res.on('data', function (chunk) { body += chunk; });

      // This is to parse last part of the data, return response body or error
      res.on('end', function() {
        // This is to manage errors
        if (res.statusCode < 200 || res.statusCode >= 300) {
          tl.setResult(tl.TaskResult.Failed, 'STATUS: ' + res.statusCode + ' - ERROR: ' + body);
          reject(new Error('statusCode=' + res.statusCode + ' - ERROR: ' + body));
        }
        resolve(body);
      });
    });

    req.on('error', (err) => {
     tl.setResult(tl.TaskResult.Failed, err.message);
     reject(err.message);
    });

     // Add file content if any
     if (filepath !== '') {
       var fs = require('fs');
       var data = fs.readFileSync(filepath);
       req.setHeader('Content-Type', 'text/plain');
       req.setHeader('Accept', 'application/vnd.siren+json');
       req.write(data);
     }

     // send the request
     req.end();
  });
}

// Manage any tasks input by replacing by default values or detecting missing required input
function manageInput(input: string, defaultValue: string = '', required: boolean = false) {
    var out: string | undefined = tl.getInput(input, required);
    out = typeof(out) !== 'undefined' ? out : defaultValue;
    return out;
}

function sleep(ms) {
  return new Promise((resolve) => {
    setTimeout(resolve, ms);
  });
}

///////////////////////////////////////////
// API FUNCTIONS
///////////////////////////////////////////
async function exportCds() {
    try {
      // Get export input parameters and put default values if not provided
      var inputCds: string = manageInput('cds','', true);
      var inputArg: string = manageInput('arg');
      var inputCdsArgs: string = manageInput('cdsArgs');
      var inputCdsTags: string = manageInput('cdsTags');
      var inputExporter: string = manageInput('exporter','all');
      var inputFormat: string = manageInput('format','JSON');
      var inputTag: string = manageInput('tag').replace(/ /g, '_');

      // Calculate API URL
      var apiPath = "/api/v1/tenant/metadata-parser/parse";
      apiPath += "?mds=" + querystring.escape(inputCds);
      apiPath += "&parser=" + querystring.escape(inputExporter);
      apiPath += "&format=" + inputFormat;
      apiPath += "&arg=" + querystring.escape(inputArg);
      apiPath += "&mdsArgs=" + querystring.escape(inputCdsArgs);
      apiPath += "&mdsTags=" + querystring.escape(inputCdsTags);
      apiPath += "&tag=" + querystring.escape(inputTag);

      // Launch the API
      callSweagleAPI(apiPath).then((data) => {
        tl.setVariable("response", data.toString());
        tl.setResult(tl.TaskResult.Succeeded, "Export successfull, check detailed result in 'response' variable");
        return data;
      });
    } catch (err) {
        tl.setResult(tl.TaskResult.Failed, err.message);
    }
}

async function info() {
    callSweagleAPI("/info", "GET").then((data) => {
        console.log("TEST-FINAL:" + data);
        tl.setVariable("response", data.toString());
        tl.setResult(tl.TaskResult.Succeeded, "Info successfull, check detailed result in 'response' variable");
        return data;
    });
}

async function snapshot() {
  try {
    // Get snapshot input parameters and put default values if not provided
    var inputCds: string = manageInput('cds','', true);
    var inputDescription: string = manageInput('description');
    var inputTag: string = manageInput('tag').replace(/ /g, '_');
    var inputValidationLevel: string = manageInput('validationLevel');

    // Calculate API URL
    var apiPath = "/api/v1/data/include/snapshot/byname";
    apiPath += "?name=" + querystring.escape(inputCds);
    apiPath += "&description=" + querystring.escape(inputDescription);
    apiPath += "&level=" + inputValidationLevel;
    apiPath += "&tag=" + querystring.escape(inputTag);

    // launch the API
    callSweagleAPI(apiPath).then((data) => {
      tl.setVariable("response", data.toString());
      tl.setResult(tl.TaskResult.Succeeded, "Snapshot successfull, check detailed result in 'response' variable");
    });
  } catch (err) {
      tl.setResult(tl.TaskResult.Failed, err.message);
  }
}

async function upload() {
  try {
    // Get export input parameters and put default values if not provided
    var inputFilePath: string = manageInput('filePath','', true);
    var inputNodePath: string = manageInput('nodePath','', true);
    var inputAllowDelete: string = manageInput('allowDelete','false');
    var inputAutoApprove: string = manageInput('autoApprove','false');
    var inputAutoRecognize: string = manageInput('autoRecognize','false');
    var inputChangeset: string = manageInput('changeset','');
    var inputDescription: string = manageInput('description','');
    var inputEncoding: string = manageInput('encoding','');
    var inputFormat: string = manageInput('format','JSON');
    var inputIdentifierWords: string = manageInput('identifierWords','');
    var inputOnlyParent: string = manageInput('onlyParent','false');
    var inputStoreSnapshotResults: string = manageInput('storeSnapshotResults','false');
    var inputTag: string = manageInput('tag','').replace(/ /g, '_');
    var inputValidationLevel: string = manageInput('validationLevel','');

    // Calculate API URL
    var apiPath = "/api/v1/data/bulk-operations/dataLoader/upload";
    apiPath += "?nodePath=" + querystring.escape(inputNodePath);
    apiPath += "&allowDelete=" + inputAllowDelete;
    apiPath += "&autoApprove=" + inputAutoApprove;
    apiPath += "&autoRecognize=" + inputAutoRecognize;
    apiPath += "&changeset=" + inputChangeset;
    apiPath += "&description=" + querystring.escape(inputDescription);
    apiPath += "&encoding=" + inputEncoding;
    apiPath += "&format=" + inputFormat;
    apiPath += "&identifierWords=" + querystring.escape(inputIdentifierWords);
    apiPath += "&storeSnapshotResults=" + inputStoreSnapshotResults;
    apiPath += "&tag=" + querystring.escape(inputTag);
    apiPath += "&validationLevel=" + inputValidationLevel;

    // Launch the API
    callSweagleAPI(apiPath, 'POST', inputFilePath).then((data) => {
      var dataString = data.toString();
      console.log("Upload Result:" + dataString);
      tl.setVariable("response", dataString);
      tl.setResult(tl.TaskResult.Succeeded, "Upload successfull, check detailed result in 'response' variable");
      return dataString;
    });
  } catch (err) {
      tl.setResult(tl.TaskResult.Failed, err.message);
  }
}

async function validate() {
  try {
    // Get export input parameters and put default values if not provided
    var inputCds: string = manageInput('cds','', true);
    var inputArg: string = manageInput('arg');
    var inputCdsArgs: string = manageInput('cdsArgs');
    var inputCdsTags: string = manageInput('cdsTags');
    var inputForIncoming: string = manageInput('forIncoming','false');
    var inputValidator: string = manageInput('validator', '', true);

    // Calculate API URL
    var apiPath = "/api/v1/tenant/metadata-parser/validate";
    apiPath += "?mds=" + querystring.escape(inputCds);
    apiPath += "&parser=" + querystring.escape(inputValidator);
    apiPath += "&arg=" + querystring.escape(inputArg);
    apiPath += "&forIncoming=" + inputForIncoming;
    apiPath += "&mdsArgs=" + querystring.escape(inputCdsArgs);
    apiPath += "&mdsTags=" + querystring.escape(inputCdsTags);

    // Launch the API
    callSweagleAPI(apiPath).then((data) => {
      var dataString = data.toString();
      var jsonResponse = JSON.parse(dataString);
      console.log("Validation Results:" + dataString);
      tl.setVariable("response", dataString);
      if ( jsonResponse.result ) {
        tl.setResult(tl.TaskResult.Succeeded, "Validation successfull, check detailed result in 'response' variable");
      } else {
        tl.setResult(tl.TaskResult.Failed, dataString);
      }
      return jsonResponse;
    });
  } catch (err) {
      tl.setResult(tl.TaskResult.Failed, err.message);
  }
}

async function validationStatus() {
  try {
    // Get snapshot input parameters and put default values if not provided
    var inputCds: string = manageInput('cds','', true);
    var inputForIncoming: string = manageInput('forIncoming','false');
    var inputFormat: string = manageInput('format','JSON');
    var inputWithCustomValidations: string = manageInput('withCustomValidations','true');


    // Calculate API URL
    var apiPrefix = "/api/v1/data/include/validation_progress";
    var apiPath = "?name=" + querystring.escape(inputCds);
    apiPath += "&forIncoming=" + inputForIncoming;
    apiPath += "&format=" + inputFormat;
    apiPath += "&withCustomValidations=" + inputWithCustomValidations;

    // Launch the Validation Progress API
    var ready: boolean = false;
    var noCDSFound: boolean = false;
    var dataString: string = "";
    var nbRetry:number = 1;
    while (!ready && nbRetry<5 && !noCDSFound) {
      callSweagleAPI(apiPrefix + apiPath, "GET").then((data) => {
        console.log("XXX RESOLVE:"+data.toString());
        if (data.toString().indexOf("FINISHED") >= 0) { ready = true; }
      })
      .catch(function(rej) {
        //here when you reject the promise
        console.log("XXX REJECT:"+rej.toString());
        if (rej.toString().indexOf("NotFoundException") > 0) { noCDSFound = true; }
      });
      console.log("RETRY"+ nbRetry + " - Validation Progress Results:" + dataString);
      nbRetry++;
      await sleep(1000);
    }
    if (!noCDSFound) {
      // Change to validation API
      apiPrefix = "/api/v1/data/include/validate";
      // Launch the Validation API
      callSweagleAPI(apiPrefix + apiPath, "GET").then((data) => {
          dataString = data.toString();
          var jsonResponse = JSON.parse(dataString);
          console.log("Validation Results:" + dataString);
          tl.setVariable("response", dataString);
          if ( jsonResponse.summary.errors > 0 ) {
            tl.setResult(tl.TaskResult.Failed, dataString);
          } else {
            tl.setResult(tl.TaskResult.Succeeded, "Validation successfull, check result in 'response' variable");
          }
          return jsonResponse;
      });
    }

  } catch (err) {
      tl.setResult(tl.TaskResult.Failed, err.message);
  }
}


main();
