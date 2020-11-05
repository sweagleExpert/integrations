import ma = require('azure-pipelines-task-lib/mock-answer');
import tmrm = require('azure-pipelines-task-lib/mock-run');
import path = require('path');

let taskPath = path.join(__dirname, '..', 'index.js');
let tmr: tmrm.TaskMockRunner = new tmrm.TaskMockRunner(taskPath);

tmr.setInput('operation', 'validationStatus');
tmr.setInput('tenant', 'testing.sweagle.com');
tmr.setInput('token', 'XXX');
tmr.setInput('cds', 'test40');
tmr.setInput('forIncoming', 'false');
tmr.setInput('withCustomValidations', 'true');

tmr.run();
