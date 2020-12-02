import ma = require('azure-pipelines-task-lib/mock-answer');
import tmrm = require('azure-pipelines-task-lib/mock-run');
import path = require('path');
var params = require ('./envParameters.js');

let taskPath = path.join(__dirname, '..', 'index.js');
let tmr: tmrm.TaskMockRunner = new tmrm.TaskMockRunner(taskPath);

tmr.setInput('operation', 'validate');
tmr.setInput('tenant', params.sweagleEnv.tenant);
tmr.setInput('token', params.sweagleEnv.token);
tmr.setInput('cds', 'test40');
tmr.setInput('forIncoming', 'false');
tmr.setInput('validator', 'passwordChecker');

tmr.run();
