/********************************************************************************************************
*
*    Mock Class: HTTPMockCallout.cls
*    Author:  
*    Date:  8/22/2018
*    
*    Used in:  ToggleProjectUpdateTest.cls
*    Trigger: TASKRAYProjectAll.trigger
*    Handler class: TASKRAYProjectAllHandler.cls
*    Future class: ToggleProjectUpdate.cls
*
********************************************************************************************************/

@isTest
global class HTTPMockCallout implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        string jsonResBody = '{"data": {"id":912345678, "wid":777, "cid":123456, "name":"sa4-test-WXYZ", "billable":false, "active":false, "at":"2013-03-06T12:15:37+00:00", "template":true, "color":"6"}}';
        res.setBody(jsonResBody);
        res.setStatusCode(200);
        return res;
    
    }
}