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
    
    global boolean positive = true;
    global HTTPMockCallout() {
    }
    global HTTPMockCallout(boolean positiveReturn) {
        positive = positiveReturn;
    }
    
    global HTTPResponse respond(HTTPRequest req) {
        
        if (req.getMethod() == 'GET' && req.getEndpoint().startsWith('https://www.toggl.com/api/v8/workspaces/')) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            string jsonResBody = '[ {"id":912345679, "wid":777, "cid":123456, "name":"sa4-test-WXYA | X", "billable":false, "active":false, "at":"2013-03-06T12:15:37+00:00", "template":true, "color":"6"} ]';
            res.setBody(jsonResBody);
            res.setStatusCode(200);
            return res;
        } else {
            if (positive) {
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                string jsonResBody = '{"data": {"id":912345678, "wid":777, "cid":123456, "name":"sa4-test-WXYZ", "billable":false, "active":false, "at":"2013-03-06T12:15:37+00:00", "template":true, "color":"6"}}';
                res.setBody(jsonResBody);
                res.setStatusCode(200);
                return res;
            } else {
                HttpResponse res = new HttpResponse();
                res.setBody('Bad request');
                res.setStatusCode(400);
                return res;
            }
        }
    
    }
}