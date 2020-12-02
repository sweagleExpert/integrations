import ma = require('azure-pipelines-task-lib/mock-answer');
import tmrm = require('azure-pipelines-task-lib/mock-run');
import path = require('path');
var params = require ('./envParameters.js');

let taskPath = path.join(__dirname, '..', 'index.js');
let tmr: tmrm.TaskMockRunner = new tmrm.TaskMockRunner(taskPath);

tmr.setInput('operation', 'export');
tmr.setInput('tenant', params.sweagleEnv.tenant);
tmr.setInput('token', 'BAD_TOKEN');
tmr.setInput('cds', 'infrastructure.vm1');
tmr.setInput('format', 'JSON');
tmr.setInput('exporter', 'all');

tmr.run();
