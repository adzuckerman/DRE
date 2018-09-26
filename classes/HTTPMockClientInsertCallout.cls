/********************************************************************************************************
*
*    Mock Class: HTTPMockCalloutInsertClient.cls
*    Author:  
*    Date:  9/4/2018
*    
*    Used in:  TogglClientBatchTest.cls
*    Batch class: TogglClientBatch.cls
*
********************************************************************************************************/

@isTest
global class HTTPMockClientInsertCallout implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        string jsonResBody = '[{"id":1239455, "wid":777, "name":"Very Big Company", "notes":"something about the client", "at":"2013-02-26T08:55:28+00:00"}, {"id":1239456, "wid":777, "name":"Small Startup", "notes":"Really cool people", "at":"2013-03-26T08:55:28+00:00"}]';
        res.setBody(jsonResBody);
        res.setStatusCode(200);
        return res;
    
    }
}