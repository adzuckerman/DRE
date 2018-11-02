/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class BaseController {
    global String AccessToken {
        get;
    }
    global String ApiBaseUri {
        get;
    }
    global Litmos__LitmosToken__c ApiToken {
        get;
    }
    global String host {
        get;
    }
    global Boolean IsAccountOwner {
        get;
    }
    global Boolean IsAccountOwner2 {
        get;
    }
    global Boolean IsLitmosAccountConnected {
        get;
    }
    global Boolean isLitmosActivatedForUser {
        get;
        set;
    }
    global Boolean isSandbox {
        get;
    }
    global Boolean IsSFDCConnected {
        get;
    }
    global String LitmosOAuthUrl {
        get;
    }
    global String LitmosTabUrl {
        get;
    }
    global String OAuthSetupUrl {
        get;
    }
    global String TellMeStuff {
        get;
    }
    global BaseController() {

    }
    global System.PageReference CheckAccessToken() {
        return null;
    }
    global System.PageReference SetupCheck() {
        return null;
    }
    global Litmos__Configuration__c fetchConfigurationRecord() {
        return null;
    }
    global User fetchLoggedInUserDetails() {
        return null;
    }
    global System.PageReference getAccessToken() {
        return null;
    }
    global String getEdition() {
        return null;
    }
    @AuraEnabled
    global static String getURL() {
        return null;
    }
    global Boolean isLitmosActivated() {
        return null;
    }
    global static List<Litmos.LitmosTeamResponse> parseCreateTeamResponse(String reponseJSONString) {
        return null;
    }
    global void turnOnLitmosActivatedForUser() {

    }
}
