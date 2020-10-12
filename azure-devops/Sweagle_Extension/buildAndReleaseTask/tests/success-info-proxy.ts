import ma = require('azure-pipelines-task-lib/mock-answer');
import tmrm = require('azure-pipelines-task-lib/mock-run');
import path = require('path');

let taskPath = path.join(__dirname, '..', 'index.js');
let tmr: tmrm.TaskMockRunner = new tmrm.TaskMockRunner(taskPath);

tmr.setInput('operation', 'info');
tmr.setInput('tenant', 'testing.sweagle.com');
tmr.setInput('proxyHost', '51.103.39.227');
tmr.setInput('proxyPort', '3128');

tmr.run();