/********************************************************************************************************
*
*    Mock Class: HTTPMockCalloutClient.cls
*    Author:  
*    Date:  9/4/2018
*    
*    Used in:  ToggleClientCreationTest.cls
*    Trigger: AccountAll.trigger
*    Handler class: AccountAllHandler.cls
*    Future class: ToggleClientCreation.cls
*
********************************************************************************************************/

@isTest
global class HTTPMockClientCallout implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        string jsonResBody = '{"data": {"id":1239455, "wid":777, "name":"Very Big Company", "at":"2013-02-26T08:45:28+00:00"}}';
        res.setBody(jsonResBody);
        res.setStatusCode(200);
        return res;
    
    }
}