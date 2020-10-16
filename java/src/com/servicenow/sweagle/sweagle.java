package com.servicenow.sweagle;

import javax.net.ssl.HttpsURLConnection;
import java.io.*;
import java.net.*;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;

public class sweagle {

    /** the default API call method. Defaults to POST */
    private String apiMethod = "POST";
    /** Sweagle configdata-set */
    private String configdataset;
    /** Properties formatting style. Defaults to JSON */
    private String format = "JSON";
    /** Sweagle parser (exporter) */
    private String exporter = "all";
    /** Sweagle host. Defaults to testing.sweagle.com. */
    private static String tenant = "https://testing.sweagle.com";
    /** Authorization credentials */
    private static String token;
    /** Optional Proxy settings
        By default system properties will be used for connection with proxy settings
        This is just needed if no system properties are defined and proxy required
    */
    private static String proxyHost;
    private static int proxyPort;
    private static String proxyUser;
    private static String proxyPassword;


    // SET FUNCTIONS
    public void setConfigdataset(String configdataset) {
        this.configdataset = configdataset;
    }
    public void setTenant(String tenant) {
        this.tenant = tenant;
    }
    public void setToken(String token) { this.token = token; }
    public void setProxyHost(String value) { this.proxyHost = value; }
    public void setProxyPort(int value) { this.proxyPort = value; }
    public void setProxyUser(String value) { this.proxyUser = value; }
    public void setProxyPassword(String value) { this.proxyPassword = value; }


    // HELPER FUNCTIONS
    private String callSweagleAPI(String apiPath, String apiMethod) {
        Map<String, String> noParams = new HashMap<>();
        return callSweagleAPI (apiPath, noParams, apiMethod, "");
    }

    private String callSweagleAPI(String apiPath, Map<String, String> parameters) {
        return callSweagleAPI (apiPath, parameters, this.apiMethod, "");
    }

    /**
     * Performs REST call towards SWEAGLE
     *
     * @param apiPath the app name
     * @param parameters a hashmap of all API args
     * @param apiMethod optional, the HTTP method to use (POST by default)
     * @param filePath optional, if any file to upload in the request (none by default)
     *
     * @return a string holding the body of the response
     */
    //private String callSweagleAPI(String apiPath, String parameters,String apiMethod, String filePath) {
    private String callSweagleAPI(String apiPath, Map<String, String> parameters,String apiMethod, String filePath) {
        try {
            System.out.println("TENANT=" +tenant);
            System.out.println("API PATH=" +apiPath);
            System.out.println("PARAMETERS=" +parameters);
            System.out.println("API METHOD=" +apiMethod);
            System.out.println("FILE PATH=" +filePath);
            System.out.println("PROVY HOST=" +proxyHost);
            System.out.println("PROXY PORT=" +proxyPort);
            System.out.println("PROXY USER=" +proxyUser);

            URL url = new URL(tenant+apiPath);//your url i.e fetch data from .
            HttpsURLConnection conn;
            if (proxyHost != null && proxyHost != "") {
                String encoded = "";
                Proxy proxy = new Proxy(Proxy.Type.HTTP, new InetSocketAddress(proxyHost, proxyPort));
                if (proxyUser != null && proxyUser != "") {
                    System.out.println("ADD PROXY AUTHENTICATION USER=" +proxyUser);
                    Authenticator authenticator = new Authenticator() {
                        public PasswordAuthentication getPasswordAuthentication() {
                            return (new PasswordAuthentication(proxyUser, proxyPassword.toCharArray()));
                        }
                    };
                    Authenticator.setDefault(authenticator);
                    encoded = Base64.getEncoder().encodeToString((proxyUser + ":" + proxyPassword).getBytes());
                    System.setProperty("https.proxyUser", proxyUser);
                    System.setProperty("https.proxyPassword", proxyPassword);
                    // Line below is required for JDK 8 as stated here: https://stackoverflow.com/questions/1626549/authenticated-http-proxy-with-java
                    System.setProperty("jdk.http.auth.tunneling.disabledSchemes", "");
                }
                conn = (HttpsURLConnection) url.openConnection(proxy);
                conn.setRequestProperty("Proxy-Authorization", "Basic " + encoded);
            } else {
                conn = (HttpsURLConnection) url.openConnection();
            }
            conn.setRequestMethod(apiMethod);
            //conn.setRequestProperty("Accept", "application/json");
            conn.setRequestProperty("Authorization", "Bearer " + token);
            // Add parameters if any
            if (!parameters.isEmpty()) {
                //conn.setReadTimeout(15000);
                //conn.setConnectTimeout(15000);
                conn.setDoOutput(true);
                DataOutputStream out = new DataOutputStream(conn.getOutputStream());
                out.writeBytes(getParamsString(parameters));
                out.flush();
                out.close();
                }
            // Check if HTTP response code is in 200 range, ie successful
            if (conn.getResponseCode() / 100 != 2 ) {
                throw new RuntimeException("Failed : HTTP Error code : " + conn.getResponseCode());
            }
            InputStreamReader in = new InputStreamReader(conn.getInputStream());
            BufferedReader br = new BufferedReader(in);
            String output = "";
            String buffer;
            while ((buffer = br.readLine()) != null) {
                output = output + buffer;
            }
            conn.disconnect();
            return output;
        } catch (Exception e) {
            System.out.println("Exception in NetClient:- " + e);
            return e.toString();
        }
    }

    // Build HTTP Query Parameters list
    private String getParamsString(Map<String, String> params) throws UnsupportedEncodingException {
        StringBuilder result = new StringBuilder();

        for (Map.Entry<String, String> entry : params.entrySet()) {
            result.append(URLEncoder.encode(entry.getKey(), "UTF-8"));
            result.append("=");
            result.append(URLEncoder.encode(entry.getValue(), "UTF-8"));
            result.append("&");
        }

        String resultString = result.toString();
        return resultString.length() > 0
                ? resultString.substring(0, resultString.length() - 1)
                : resultString;
    }


    // API FUNCTIONS
    /**
     * Performs HTTP GET call towards SWEAGLE to check connection is working
     *
     * @return a json string holding the current version of the tenant
     */
    public String getInfo() {
        return callSweagleAPI("/info","GET");
    }

    /**
     * Performs REST call towards SWEAGLE to export a ConfigDataSet (CDS) snapshot
     * A hashmap with following params:
     * @param mds name of the main ConfigDataSet to export (CDS)
     * @param parser optional name of the exporter rule to use (all by default)
     * @param format optional format of the export data (JSON by default)
     * @param tag optional snapshot tag of the version to export (empty by default
     * @param arg optional args of the exporter used, comma separated list (empty by default)
     * @param cdsArgs optional additional CDS to use in export rule, comma separated list (empty by default)
     * @param cdsTags optional tags of  of the additional CDS, if any, comma separated list (empty by default)
     *
     * @return a string holding the snapshot of configuration requested
     */
    public String export(Map<String, String> parameters) {
        // Get export input parameters and put default values if not provided
        if (!parameters.containsKey("mds")) { parameters.put("mds", this.configdataset); }
        if (!parameters.containsKey("parser")) { parameters.put("parser", this.exporter); }
        if (!parameters.containsKey("format")) { parameters.put("format", this.format); }
        if (parameters.containsKey("tag")) {
            String tag = parameters.get("tag");
            tag = tag.replace(' ', '_');
            parameters.put("tag", tag);
        }

        // Launch the API
        String apiPath = "/api/v1/tenant/metadata-parser/parse";
        return callSweagleAPI(apiPath, parameters);
    }

    /**
     * Performs REST call towards SWEAGLE to export a ConfigDataSet (CDS) snapshot
     * using the "returnDataForNode" exporter
     * @param nodename name of the node you want to export
     * @return a string holding the snapshot of configuration requested
     */
    public String returnDataForNode(String nodename) {
        Map<String, String> parameters = new HashMap<>();
        parameters.put("parser", "returnDataForNode");
        parameters.put("arg", nodename);
        return export(parameters);
    }

    /**
     * Performs REST call towards SWEAGLE to export a ConfigDataSet (CDS) snapshot
     * using the "returnDataForPath" exporter
     * @param nodepath path of the node you want to export (nodenames separated by commas)
     * @return a string holding the snapshot of configuration requested
     */
    public String returnDataForPath(String nodepath) {
        Map<String, String> parameters = new HashMap<>();
        parameters.put("parser", "returnDataForPath");
        parameters.put("arg", nodepath);
        return export(parameters);
    }

    /**
     * Performs REST call towards SWEAGLE to export the value of a key in your (CDS) snapshot
     * using the "returnValueForKey" exporter
     * @param keyname name of the key (it must be unique inside the CDS)
     * @return a string holding the value of the key
     */
    public String returnValueForKey(String keyname) {
        Map<String, String> parameters = new HashMap<>();
        parameters.put("parser", "returnValueForKey");
        parameters.put("format", "RAW");
        parameters.put("arg", keyname);
        return export(parameters);
    }

    /**
     * Performs REST call towards SWEAGLE to export the value of a key in your (CDS) snapshot
     * using the "returnDataForPath" exporter
     * @param keypath path of the key int he CDS (nodenames separated by commas an with ",<keyname" at the end
     * @return a string holding the value of the key
     */
    public String returnValueForKeyPath(String keypath) {
        Map<String, String> parameters = new HashMap<>();
        parameters.put("parser", "returnDataForPath");
        parameters.put("format", "RAW");
        parameters.put("arg", keypath);
        return export(parameters);
    }

}
