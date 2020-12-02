import ma = require('azure-pipelines-task-lib/mock-answer');
import tmrm = require('azure-pipelines-task-lib/mock-run');
import path = require('path');
var params = require ('./envParameters.js');

let taskPath = path.join(__dirname, '..', 'index.js');
let tmr: tmrm.TaskMockRunner = new tmrm.TaskMockRunner(taskPath);

tmr.setInput('operation', 'upload');
tmr.setInput('tenant', params.sweagleEnv.tenant);
tmr.setInput('token', params.sweagleEnv.token);
tmr.setInput('nodePath', 'infrastructure,azure,vm1');
tmr.setInput('filePath', './tests/inputs/sample.json');
tmr.setInput('format', 'JSON');
tmr.setInput('autoApprove', 'true');

tmr.run();
