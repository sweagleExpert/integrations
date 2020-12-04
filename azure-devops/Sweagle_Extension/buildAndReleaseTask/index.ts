import tl = require('azure-pipelines-task-lib/task');
import https = require('https');
import tls = require('tls');
import fs = require('fs');
const querystring = require('querystring');

const inputOperation: string = manageInput ('operation','info');
const inputSweagleHost: string = manageInput ('tenant', 'testing.sweagle.com');
const inputSweaglePort: string = manageInput ('port', '443');
var startTime = new Date();

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
  var inputProxyPassword: string = manageInput ('proxyPassword','');

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
    headers: { 'Accept': '*/*', 'Authorization': 'Bearer ' + manageInput ('token') }
  };

  console.log("API PATH= "+apiMethod+" "+apiPath);

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

// Add result of testList to a validatorList
function manageTestList(testList: any, validatorList: any, status: string, type: string) {
  for (var testArray in testList) {
    //console.log("TEST ARRAY="+testArray);
    if (Array.isArray(testList[testArray])) {
      if (testArray.indexOf("Parsers") > 0) {
        // this is a validator error
        testList[testArray].forEach((testresult) => { validatorList[testresult.validatorName] = {status: status, type: type, message: testresult.errorDescription}; });
      } else {
        // This is a metadata error
        testList[testArray].forEach((testresult) => { validatorList[testArray+"-"+testresult.key] = {status: status, type: type, message: testresult.path + "/" + testresult.key + " "+ testArray + ", expected " + testresult.expected}; });
      }
    };
  };
  return validatorList;
}

// Generate a JUnit XML output file
async function generateXmlOutput(jsonResponse: any, cds: string, validator: string = '') {

  //console.log("CDS="+cds);
  //console.log("VALIDATOR="+validator);
  //console.log("JSON="+JSON.stringify(jsonResponse, null, 5));

  const { create } = require('xmlbuilder2');
  var endTime = new Date();
  var elapseTime = (endTime.getTime() - startTime.getTime()) / 1000;
  var root = create({ version: '1.0', encoding: 'UTF-8' })

  if (validator != '') {
    // One validator defined, this is result for a single validation
    var outputFile = "./testResult-validator-"+validator+".xml"
    if ( jsonResponse.result ) {
      var item = root.ele('testsuite', { name: 'sweagle', tests: '1', failures:'0', hostname: inputSweagleHost, time: elapseTime, timestamp: startTime.toISOString() })
          .ele('testcase', { name: validator, classname: cds });
    } else {
      var item = root.ele('testsuite', { name: 'sweagle', tests: '1', failures:'1', hostname: inputSweagleHost, time: elapseTime, timestamp: startTime.toISOString() })
          .ele('testcase', { name: validator, classname: cds })
            .ele('failure', { message: jsonResponse.description, type: "ERROR" }).up();
    }
  } else {
    // No validator defined, this is validationStatus result
    var outputFile = "./testResults-cds-"+cds+".xml";
    // As validation result doesn't returns the list of OK validators, we will get full list of assigned validators to complete the test report
    // Get CDS Id in order to retrieve assigned validators
    //var cdsId = await getCdsId(cds);
    var cdsId = jsonResponse.summary.includeId;
    //console.log("CDS ID="+cdsId);
    var assignedValidators = await getAssignedParsers(cdsId, 'VALIDATOR');
    //console.log("assignedValidators=");
    //console.log(assignedValidators);
    if (jsonResponse.summary.warnings > 0) { assignedValidators = manageTestList(jsonResponse.warnings, assignedValidators, "failure", "WARNING"); };
    if (jsonResponse.summary.errors > 0) { assignedValidators = manageTestList(jsonResponse.errors, assignedValidators, "failure", "ERROR"); };
    if (jsonResponse.summary.problems > 0) { assignedValidators = manageTestList(jsonResponse.problems, assignedValidators, "error", "CRITICAL"); };
    //console.log("assignedValidators AFTER ADDITION=");
    //console.log(assignedValidators);

    // Build XML file
    var nbValidators = Object.keys(assignedValidators).length;
    //var nbSuccess = Object.keys(assignedValidators).length - jsonResponse.summary.problems - jsonResponse.summary.errors;
    var item = root.ele('testsuite', { name: 'Sweagle Validators', tests: nbValidators, errors: jsonResponse.summary.problems, failures: jsonResponse.summary.errors, hostname: inputSweagleHost, time: elapseTime, timestamp: startTime.toISOString() });
    var item2;
    for (var testresult in assignedValidators) {
      if (assignedValidators[testresult].status == "Valid") {
        item2 = item.ele('testcase', { name: testresult, classname: cds }).up();
      } else {
        item2 = item.ele('testcase', { name: testresult, classname: cds })
          .ele(assignedValidators[testresult].status, { message: assignedValidators[testresult].message, type: assignedValidators[testresult].type }).up()
        .up();
      }
    }
  }

  // convert the XML tree to string
  const xml = root.end({ prettyPrint: true });
  //console.log(xml);
  // write xml to output file
  fs.writeFile(outputFile, xml, function (err) {
    if (err) { tl.setResult(tl.TaskResult.Failed, err.message); }
  });
  return outputFile;
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
      var inputOutputFile: string = manageInput('outputFile');
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
        if (inputOutputFile != "") {
          console.log("Export successfull, check output in '"+inputOutputFile+"' file");
          tl.setResult(tl.TaskResult.Succeeded, "Export successfull, check detailed result in '"+inputOutputFile+"' file");
          fs.writeFile(inputOutputFile, data.toString(), function (err) {
            if (err) { tl.setResult(tl.TaskResult.Failed, err.message); }
          });
        } else {
          console.log("Export successfull, check output in 'response' variable");
          tl.setResult(tl.TaskResult.Succeeded, "Export successfull, check detailed result in 'response' variable");
          return data;
        }
      });
    } catch (err) {
        tl.setResult(tl.TaskResult.Failed, err.message);
    }
}

// Return list of assigned validators of a CDS based on its Id
// ParserType should be VALIDATOR or EXPORTER
async function getAssignedParsers(cdsId: string, parserType: string) {
    try {
      // Calculate API URL
      var apiPath = "/api/v1/tenant/metadata-parser/assigned?parserType="+parserType+"&status=published&id="+cdsId;
      // Launch the API
      return callSweagleAPI(apiPath, 'GET').then((data) => {
        //console.log("VALIDATORS ASSIGNED="+data.toString());
        var jsonResponse = JSON.parse(data.toString());
        var entities = jsonResponse._entities;
        var len = Object.keys(entities).length;
        var parsersList = {};
        for (var i = 0; i < len; i++) {
          parsersList[entities[i].name] = {status: 'Valid', type: '', message: ''};
        }
        return parsersList;
      });
    } catch (err) {
      //console.log(err);
      tl.setResult(tl.TaskResult.Failed, err.message);
    }
}

// Return the ID of a CDS based on its name
async function getCdsId(cds: string) {
  try {
    // Calculate API URL
    var apiPath = "/api/v1/data/include?name="+querystring.escape(cds);
    //var jsonResponse;
    // Launch the API
    return callSweagleAPI(apiPath, 'GET').then((data) => {
      var jsonResponse = JSON.parse(data.toString());
      //console.log("RESPONSE GET CDS ID="+JSON.stringify(jsonResponse._entities[0].master.id));
      return jsonResponse._entities[0].master.id;
    });
  } catch (err) {
    tl.setResult(tl.TaskResult.Failed, err.message);
  }
}

async function info() {
    callSweagleAPI("/info", "GET").then((data) => {
        console.log("RESPONSE:" + data);
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
    apiPath += "&onlyParent=" + inputOnlyParent;
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
    var inputXmlTestResult: string = manageInput('xmlTestResult', 'true');

    // Calculate API URL
    var apiPath = "/api/v1/tenant/metadata-parser/validate";
    apiPath += "?mds=" + querystring.escape(inputCds);
    apiPath += "&parser=" + querystring.escape(inputValidator);
    apiPath += "&arg=" + querystring.escape(inputArg);
    apiPath += "&forIncoming=" + inputForIncoming;
    apiPath += "&mdsArgs=" + querystring.escape(inputCdsArgs);
    apiPath += "&mdsTags=" + querystring.escape(inputCdsTags);

    // Launch the API
    var response = (await callSweagleAPI(apiPath)).toString();
    tl.setVariable("response", response);
    var jsonResponse = JSON.parse(response);
    var whereToCheckResult = "check detailed result in 'response' variable"
    // If publishTestResult is enabled, create the Junit XML test result file
    var outputFile = await generateXmlOutput(jsonResponse, inputCds, inputValidator);
    if (inputXmlTestResult) {
      whereToCheckResult = "check detailed result in '"+outputFile+"' file"
    }
    // Manage the result status of the ADO tasks
    if ( jsonResponse.result ) {
      console.log("Validation successfull, " + whereToCheckResult);
      tl.setResult(tl.TaskResult.Succeeded, "Validation successfull, " + whereToCheckResult);
    } else {
      tl.setResult(tl.TaskResult.Failed, response);
    }
    return jsonResponse;
  } catch (err) {
    console.log(err);
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
    var inputXmlTestResult: string = manageInput('xmlTestResult', 'true');
    var maxRetries = 5;

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
    while (!ready && nbRetry<maxRetries && !noCDSFound) {
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
      var response = (await callSweagleAPI(apiPrefix + apiPath, "GET")).toString();
      //console.log("Validation Results:" + dataString);
      tl.setVariable("response", response);
      var jsonResponse = JSON.parse(response);
      var whereToCheckResult = "check detailed result in 'response' variable";
      // If publishTestResult is enabled, create the Junit XML test result file
      if (inputXmlTestResult) {
        var outputFile = await generateXmlOutput(jsonResponse, inputCds);
        whereToCheckResult = "check detailed result in '"+outputFile+"' file";
      }
      // Manage the result status of the ADO tasks
      if ( jsonResponse.summary.errors > 0 ) {
        tl.setResult(tl.TaskResult.Failed, response);
      } else {
        tl.setResult(tl.TaskResult.Succeeded, "Validation successfull, " + whereToCheckResult);
      }
      return jsonResponse;
    }

  } catch (err) {
      tl.setResult(tl.TaskResult.Failed, err.message);
  }
}


main();
