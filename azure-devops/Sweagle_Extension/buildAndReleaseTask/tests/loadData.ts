import ma = require('azure-pipelines-task-lib/mock-answer');
import tmrm = require('azure-pipelines-task-lib/mock-run');
import path = require('path');

let taskPath = path.join(__dirname, '..', 'index.js');
let tmr: tmrm.TaskMockRunner = new tmrm.TaskMockRunner(taskPath);

tmr.setInput('operation', 'upload');
tmr.setInput('tenant', 'testing.sweagle.com');
tmr.setInput('token', '34c193df-6de4-4429-972f-c3c1eb691a53');
tmr.setInput('nodePath', 'infrastructure,azure,vm2,test1');
tmr.setInput('filePath', './tests/inputs/sample.json');
tmr.setInput('format', 'JSON');
tmr.setInput('autoApprove', 'false');

// this should be run with failure-upload-duplicate.ts to raise an alert
tmr.run();