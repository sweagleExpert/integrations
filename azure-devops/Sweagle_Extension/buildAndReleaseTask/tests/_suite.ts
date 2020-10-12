import * as path from 'path';
import * as assert from 'assert';
import * as ttm from 'azure-pipelines-task-lib/mock-test';

describe('Sample task tests', function () {

    var testProxy = false;

    before( function() {
      it('Load Test Data', function(done: Mocha.Done) {
          this.timeout(10000);
          // This is preparation data for failure-upload-duplicate test
          let tp = path.join(__dirname, 'loadData.js');
          let tr: ttm.MockTestRunner = new ttm.MockTestRunner(tp);
          tr.run();
          console.log(tr.stdout);
          done();
      });
    });

    after(() => {

    });

    // SUCCESS TESTS
    it('Test GetInfo', function(done: Mocha.Done) {
        this.timeout(3000);

        let tp = path.join(__dirname, 'success-info.js');
        let tr: ttm.MockTestRunner = new ttm.MockTestRunner(tp);

        tr.run();
        console.log(tr.succeeded);
        assert.equal(tr.succeeded, true, 'should have succeeded');
        assert.equal(tr.warningIssues.length, 0, "should have no warnings");
        assert.equal(tr.errorIssues.length, 0, "should have no errors");
        console.log(tr.stdout);
        assert.equal(tr.stdout.indexOf('{"build":{"version":"') >= 0, true, 'should display {"build":{"version":"...');
        done();
    });

    it('Test Upload Successfull', function(done: Mocha.Done) {
        this.timeout(5000);

        let tp = path.join(__dirname, 'success-upload.js');
        let tr: ttm.MockTestRunner = new ttm.MockTestRunner(tp);

        tr.run();
        console.log(tr.succeeded);
        assert.equal(tr.succeeded, true, 'should have succeeded');
        assert.equal(tr.warningIssues.length, 0, "should have no warnings");
        assert.equal(tr.errorIssues.length, 0, "should have no errors");
        console.log(tr.stdout);
        //assert.equal(tr.stdout.indexOf('"properties":{"changeset":{"id":') >= 0, true, 'should display ..."properties":{"changeset":{"id":...');
        done();
    });

    it('Test Upload Successfull With Snapshot', function(done: Mocha.Done) {
        this.timeout(5000);

        let tp = path.join(__dirname, 'success-upload-with-snapshot.js');
        let tr: ttm.MockTestRunner = new ttm.MockTestRunner(tp);

        tr.run();
        console.log(tr.succeeded);
        assert.equal(tr.succeeded, true, 'should have succeeded');
        assert.equal(tr.warningIssues.length, 0, "should have no warnings");
        assert.equal(tr.errorIssues.length, 0, "should have no errors");
        console.log(tr.stdout);
        //assert.equal(tr.stdout.indexOf('"properties":{"changeset":{"id":') >= 0, true, 'should display ..."properties":{"changeset":{"id":...');
        done();
    });

    it('Test Validate Successfull', function(done: Mocha.Done) {
        this.timeout(2000);

        let tp = path.join(__dirname, 'success-validate.js');
        let tr: ttm.MockTestRunner = new ttm.MockTestRunner(tp);

        tr.run();
        console.log(tr.succeeded);
        assert.equal(tr.succeeded, true, 'should have succeeded');
        assert.equal(tr.warningIssues.length, 0, "should have no warnings");
        assert.equal(tr.errorIssues.length, 0, "should have no errors");
        console.log(tr.stdout);
        assert.equal(tr.stdout.indexOf('{"result":true') >= 0, true, 'should display {"result":true...');
        done();
    });

    it('Test Validation Status Successfull', function(done: Mocha.Done) {
        this.timeout(6000);

        let tp = path.join(__dirname, 'success-validationStatus.js');
        let tr: ttm.MockTestRunner = new ttm.MockTestRunner(tp);

        tr.run();
        console.log(tr.succeeded);
        assert.equal(tr.succeeded, true, 'should have succeeded');
        assert.equal(tr.warningIssues.length, 0, "should have no warnings");
        assert.equal(tr.errorIssues.length, 0, "should have no errors");
        console.log(tr.stdout);
        assert.equal(tr.stdout.indexOf('Validation successfull') >= 0, true, 'should display "Validation successfull"');
        done();
    });

    it('Test Snapshot Successfull', function(done: Mocha.Done) {
        this.timeout(3000);

        let tp = path.join(__dirname, 'success-snapshot.js');
        let tr: ttm.MockTestRunner = new ttm.MockTestRunner(tp);

        tr.run();
        console.log(tr.succeeded);
        assert.equal(tr.succeeded, true, 'should have succeeded');
        assert.equal(tr.warningIssues.length, 0, "should have no warnings");
        assert.equal(tr.errorIssues.length, 0, "should have no errors");
        console.log(tr.stdout);
        assert.equal(tr.stdout.indexOf('Snapshot successfull') >= 0, true, 'should display "Snapshot successfull"');
        done();
    });

    it('Test Export Successfull', function(done: Mocha.Done) {
        this.timeout(3000);

        let tp = path.join(__dirname, 'success-export.js');
        let tr: ttm.MockTestRunner = new ttm.MockTestRunner(tp);

        tr.run();
        console.log(tr.succeeded);
        assert.equal(tr.succeeded, true, 'should have succeeded');
        assert.equal(tr.warningIssues.length, 0, "should have no warnings");
        assert.equal(tr.errorIssues.length, 0, "should have no errors");
        console.log(tr.stdout);
        assert.equal(tr.stdout.indexOf('{"test39"') >= 0, true, 'should display {"test39"...');
        done();
    });

    // FAILURE TESTS
    it('Test Upload Failed - Duplicate', function(done: Mocha.Done) {
        this.timeout(5000);

        let tp = path.join(__dirname, 'failure-upload-duplicate.js');
        let tr: ttm.MockTestRunner = new ttm.MockTestRunner(tp);
        tr.run();

        console.log(tr.succeeded);
        assert.equal(tr.succeeded, false, 'should have failed');
        assert.equal(tr.warningIssues, 0, "should have no warnings");
        assert.equal(tr.errorIssues.length, 1, "should have 1 error issue");
        assert.equal(tr.stdout.indexOf('already exists in a different changeset') >= 0, true, 'Should display ...already exists in a different changeset...');
        done();
    });

    it('Test Validate Failed - Errors in validators', function(done: Mocha.Done) {
        this.timeout(2000);

        let tp = path.join(__dirname, 'failure-validate-validatorsErrors.js');
        let tr: ttm.MockTestRunner = new ttm.MockTestRunner(tp);

        tr.run();
        console.log(tr.succeeded);
        assert.equal(tr.succeeded, false, 'should have failed');
        assert.equal(tr.warningIssues, 0, "should have no warnings");
        assert.equal(tr.errorIssues.length, 1, "should have 1 error issue");
        var jsonResponse = JSON.parse(tr.errorIssues[0]);
        assert.equal(jsonResponse.failed, true, 'At least one validator in error');
        done();
    });

    it('Test Validation Status Failed - No Pending Data', function(done: Mocha.Done) {
        this.timeout(6000);

        let tp = path.join(__dirname, 'failure-validationStatus-noPendingData.js');
        let tr: ttm.MockTestRunner = new ttm.MockTestRunner(tp);

        tr.run();
        console.log(tr.succeeded);
        assert.equal(tr.succeeded, false, 'should have failed');
        assert.equal(tr.warningIssues, 0, "should have no warnings");
        assert.equal(tr.errorIssues.length, 1, "should have 1 error issue");
        //assert.equal(tr.errorIssues[0], 'STATUS: 404 - ERROR: {"error":"NotFoundException","error_description":"No pending data found"}', 'error issue output');
        assert.equal(tr.stdout.indexOf('{"error":"NotFoundException"') >= 0, true, 'Should display {"error":"NotFoundException" ...');
        done();
    });

    it('Test Validation Status Failed - Errors in validators', function(done: Mocha.Done) {
        this.timeout(6000);

        let tp = path.join(__dirname, 'failure-validationStatus-validatorsErrors.js');
        let tr: ttm.MockTestRunner = new ttm.MockTestRunner(tp);

        tr.run();
        console.log(tr.succeeded);
        assert.equal(tr.succeeded, false, 'should have failed');
        assert.equal(tr.warningIssues, 0, "should have no warnings");
        assert.equal(tr.errorIssues.length, 1, "should have 1 error issue");
        var jsonResponse = JSON.parse(tr.errorIssues[0]);
        assert.equal(jsonResponse.summary.errors > 0, true, 'At least one validator in error');
        done();
    });

    it('Test Export Failed - Bad Authentication', function(done: Mocha.Done) {
        this.timeout(3000);

        let tp = path.join(__dirname, 'failure-exporter-badAuthentication.js');
        let tr: ttm.MockTestRunner = new ttm.MockTestRunner(tp);

        tr.run();
        console.log(tr.succeeded);
        assert.equal(tr.succeeded, false, 'should have failed');
        assert.equal(tr.warningIssues, 0, "should have no warnings");
        assert.equal(tr.errorIssues.length, 1, "should have 1 error issue");
        assert.equal(tr.errorIssues[0], 'STATUS: 401 - ERROR: {"error":"invalid_token","error_description":"Invalid access token: BAD_TOKEN"}', 'error issue output');
        assert.equal(tr.stdout.indexOf('{"error":"invalid_token"') >= 0, true, 'Should display {"error":"invalid_token" ...');
        done();
    });

    it('Test Export Failed - Unknown CDS', function(done: Mocha.Done) {
        this.timeout(3000);

        let tp = path.join(__dirname, 'failure-exporter-unknownCDS.js');
        let tr: ttm.MockTestRunner = new ttm.MockTestRunner(tp);

        tr.run();
        console.log(tr.succeeded);
        assert.equal(tr.succeeded, false, 'should have failed');
        assert.equal(tr.warningIssues, 0, "should have no warnings");
        assert.equal(tr.errorIssues.length, 1, "should have 1 error issue");
        //assert.equal(tr.errorIssues[0], 'STATUS: 404 - ERROR: {"error":"NotFoundException","error_description":"'Include' with name = 'UNKOWN.CDS' not found."}', 'error issue output');
        assert.equal(tr.stdout.indexOf('{"error":"NotFoundException"') >= 0, true, 'Should display {"error":"NotFoundException"...');
        done();
    });

    // PROXY TESTS
    if (testProxy) {
      it('Test GetInfo With Proxy', function(done: Mocha.Done) {
          this.timeout(3000);

          let tp = path.join(__dirname, 'success-info-proxy.js');
          let tr: ttm.MockTestRunner = new ttm.MockTestRunner(tp);

          tr.run();
          console.log(tr.succeeded);
          assert.equal(tr.succeeded, true, 'should have succeeded');
          assert.equal(tr.warningIssues.length, 0, "should have no warnings");
          assert.equal(tr.errorIssues.length, 0, "should have no errors");
          console.log(tr.stdout);
          assert.equal(tr.stdout.indexOf('{"build":{"version":"') >= 0, true, 'should display {"build":{"version":"...');
          done();
      });

      it('Test Export Successfull With Proxy', function(done: Mocha.Done) {
          this.timeout(3000);

          let tp = path.join(__dirname, 'success-export-proxy.js');
          let tr: ttm.MockTestRunner = new ttm.MockTestRunner(tp);

          tr.run();
          console.log(tr.succeeded);
          assert.equal(tr.succeeded, true, 'should have succeeded');
          assert.equal(tr.warningIssues.length, 0, "should have no warnings");
          assert.equal(tr.errorIssues.length, 0, "should have no errors");
          console.log(tr.stdout);
          assert.equal(tr.stdout.indexOf('{"test39"') >= 0, true, 'should display {"test39"...');
          done();
      });

    }

/*
// THIS ERROR DOES NOT HAPPEN AS SOON AS A AUTHORIZATION BEARER IS IN HEADER

    it('Test API Failed - No Authentication', function(done: Mocha.Done) {
        this.timeout(3000);

        let tp = path.join(__dirname, 'failure-exporter-noAuthentication.js');
        let tr: ttm.MockTestRunner = new ttm.MockTestRunner(tp);

        tr.run();
        console.log(tr.succeeded);
        assert.equal(tr.succeeded, false, 'should have failed');
        assert.equal(tr.warningIssues, 0, "should have no warnings");
        assert.equal(tr.errorIssues.length, 1, "should have 1 error issue");
        assert.equal(tr.errorIssues[0], 'STATUS: 401 - ERROR: {"error":"unauthorized","error_description":"An Authentication object was not found in the SecurityContext"}', 'error issue output');
        assert.equal(tr.stdout.indexOf('{"error":"unauthorized"') >= 0, true, 'Should display {"error":"unauthorized" ...');

        done();
    });

// THIS ERROR DOES NOT HAPPEN AS SOON AS A API URL IN CODE IS CORRECT
    it('Test API Failed - Bad URL', function(done: Mocha.Done) {
        this.timeout(3000);

        let tp = path.join(__dirname, 'failure-exporter-unknownCDS.js');
        let tr: ttm.MockTestRunner = new ttm.MockTestRunner(tp);

        tr.run();
        console.log(tr.succeeded);
        assert.equal(tr.succeeded, false, 'should have failed');
        assert.equal(tr.warningIssues, 0, "should have no warnings");
        assert.equal(tr.errorIssues.length, 1, "should have 1 error issue");
        //assert.equal(tr.errorIssues[0], 'Bad CDS input was given', 'error issue output');
        assert.equal(tr.stdout.indexOf('"status":404,"error":"Not Found"') >= 0, true, 'Should display ..."status":404,"error":"Not Found"...');

        done();
    });
*/
});
