package com.servicenow.sweagle;

import org.junit.jupiter.api.Test;
import java.util.HashMap;
import java.util.Map;

class sweagleTest {

    sweagle sweagleConf = new sweagle();
    Boolean testProxy = true;

    @org.junit.jupiter.api.BeforeEach
    void setUp() {
        sweagleConf.setToken("XXX");
        sweagleConf.setTenant("https://testing.sweagle.com");
        sweagleConf.setConfigdataset("demo");
        sweagleConf.setProxyHost("");
        sweagleConf.setProxyUser("");

    }

    @org.junit.jupiter.api.AfterEach
    void tearDown() {
    }

    @Test
    void failedTestGetInfo() {
        System.out.println("-----   This is failed test of getInfo API");
        sweagleConf.setTenant("https://toto.sweagle.com");
        String response = sweagleConf.getInfo();
        System.out.println("RESPONSE: " + response);
    }

    @Test
    void failedTestExport() {
        Map<String, String> parameters = new HashMap<>();
        parameters.put("mds", "toto");
        System.out.println("-----   This is failed test of export 'all' API");
        String response = sweagleConf.export(parameters);
        System.out.println("RESPONSE: " + response);
    }

    @Test
    void testGetInfo() {
        System.out.println("-----   This is test of getInfo API");
        String response = sweagleConf.getInfo();
        System.out.println("RESPONSE: " + response);
    }

    @Test
    void testGetInfo_withProxy() {
        System.out.println("-----   This is test of getInfo API with Provy");
        if (testProxy) {
            sweagleConf.setProxyHost("40.89.157.194");
            sweagleConf.setProxyPort(3128);
            sweagleConf.setProxyUser("proxy_user");
            sweagleConf.setProxyPassword("proxy_password");
        }
        String response = sweagleConf.getInfo();
        System.out.println("RESPONSE: " + response);
    }

    @Test
    void testExport_all() {
        Map<String, String> parameters = new HashMap<>();
        parameters.put("mds", "integration");
        System.out.println("-----   This is test of export 'all' API");
        String response = sweagleConf.export(parameters);
        System.out.println("RESPONSE: " + response);
    }

    @Test
    void testExport_all_withProxy() {
        Map<String, String> parameters = new HashMap<>();
        parameters.put("mds", "integration");
        System.out.println("-----   This is test of export 'all' API with Proxy");
        if (testProxy) {
            sweagleConf.setProxyHost("40.89.157.194");
            sweagleConf.setProxyPort(3128);
            sweagleConf.setProxyUser("proxy_user");
            sweagleConf.setProxyPassword("proxy_password");
        }
        String response = sweagleConf.export(parameters);
        System.out.println("RESPONSE: " + response);
    }



    @Test
    void testExport_returnDataForNode() {
        System.out.println("-----   This is test of export 'returnDataForNode' API");
        String response = sweagleConf.returnDataForNode("config");
        System.out.println("RESPONSE: " + response);
    }

    @Test
    void testExport_returnDataForPath() {
        System.out.println("-----   This is test of export 'returnDataForPath' API");
        String response = sweagleConf.returnDataForPath("config,dependencies");
        System.out.println("RESPONSE: " + response);
    }

    @Test
    void testExport_returnValueForKey() {
        System.out.println("-----   This is test of export 'returnValueForKey' API");
        String response = sweagleConf.returnValueForKey("sys_class_name");
        System.out.println("RESPONSE: " + response);
    }

    @Test
    void testExport_returnValueForKeyPath() {
        System.out.println("-----   This is test of export 'returnValueForKeyPath' API");
        String response = sweagleConf.returnValueForKeyPath("demo,fw01.s042.s-mart.com,sys_class_name");
        System.out.println("RESPONSE: " + response);
    }

}