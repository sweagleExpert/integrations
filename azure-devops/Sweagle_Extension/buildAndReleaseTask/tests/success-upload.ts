import ma = require('azure-pipelines-task-lib/mock-answer');
import tmrm = require('azure-pipelines-task-lib/mock-run');
import path = require('path');

let taskPath = path.join(__dirname, '..', 'index.js');
let tmr: tmrm.TaskMockRunner = new tmrm.TaskMockRunner(taskPath);

tmr.setInput('operation', 'upload');
tmr.setInput('tenant', 'testing.sweagle.com');
tmr.setInput('token', 'XXX');
tmr.setInput('nodePath', 'infrastructure,azure,vm1');
tmr.setInput('filePath', './tests/inputs/sample.json');
tmr.setInput('format', 'JSON');
tmr.setInput('autoApprove', 'true');

tmr.run();
