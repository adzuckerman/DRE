/*   Name:          TogglToSalesforceMock
 *   Developer:     CLOUD MINE CONSULTING
 *   Date:          4/23/2018
 *   Description:   Http Callout Mock for Toggl 
 *                
 */

@isTest
public with sharing class TogglToSalesforceMock implements HttpCalloutMock{

    private String payload;

    public TogglToSalesforceMock(String payload) {
        this.payload = payload;
    }

    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse resp = new HttpResponse();
        resp.setStatusCode(200);

        if (req.getEndpoint().contains('workspace_users')) {
            resp.setBody('[{"id":1627282,"uid":1,"wid":590797,"admin":false,"active":true,"email":"testtest123@doctorevidence.com","timezone":"America/Los_Angeles","inactive":true,"at":"2018-03-29T21:51:54+00:00","name":"Pmamudu","group_ids":[42463,84890,84121,42441],"rate":null,"labour_cost":null,"invite_url":null,"invitation_code":null,"avatar_file_name":null},{"id":1677281,"uid":1,"wid":590797,"admin":false,"active":true,"email":"testtest12@doctorevidence.com","timezone":"America/Los_Angeles","inactive":true,"at":"2018-03-29T21:51:54+00:00","name":"Pmamudu","group_ids":[42463,84890,84121,42441],"rate":null,"labour_cost":null,"invite_url":null,"invitation_code":null,"avatar_file_name":null},{"id":2787131,"uid":2,"wid":590797,"admin":false,"active":true,"email":"kprajapati1@doctorevidence.com","timezone":"America/Los_Angeles","inactive":true,"at":"2018-03-29T21:51:46+00:00","name":"Kprajapati","group_ids":[42121,84121,42441],"rate":null,"labour_cost":null,"invite_url":null,"invitation_code":null,"avatar_file_name":null},{"id":3976301,"uid":3,"wid":590797,"admin":false,"active":true,"email":"ahinojosa1234@doctorevidence.com","timezone":"America/Los_Angeles","inactive":false,"at":"2018-03-19T19:43:41+00:00","name":"Adam","group_ids":null,"rate":null,"labour_cost":null,"invite_url":null,"invitation_code":null,"avatar_file_name":null}]');
        }
        else if (req.getEndpoint().contains('details')) {
            resp.setBody(
                '{"total_grand":36000000,"total_billable":36000000,"total_currencies":[{"currency":null,"amount":null}],"total_count":4,"per_page":50,"data":[{"id":835345550,"pid":4859110,"tid":null,"uid":1,"description":"Break","start":"2018-03-30T17:15:00-07:00","end":"2018-03-30T17:45:00-07:00","updated":"2018-03-28T15:47:14-07:00","dur":1800000,"user":"Jtsung","use_stop":true,"client":"Doctor Evidence","project":"Admin/Internal","project_color":"4","project_hex_color":"#b27636","task":null,"billable":null,"is_billable":true,"cur":null,"tags":[]},{"id":836779806,"pid":58550545,"tid":null,"uid":2,"description":"1809543","start":"2018-03-30T09:00:27-05:00","end":"2018-03-30T11:00:27-05:00","updated":"2018-03-30T10:17:53-05:00","dur":7200000,"user":"Jsangbana","use_stop":true,"client":"AAN","project":"AAN-Neur-001b | Epidural Steroids","project_color":"0","project_hex_color":"#a01aa5","task":null,"billable":null,"is_billable":true,"cur":null,"tags":["Primary Extraction"]},{"id":836278447,"pid":58550545,"tid":null,"uid":3,"description":"1809514","start":"2018-03-29T12:53:00-07:00","end":"2018-03-29T16:38:00-07:00","updated":"2018-03-29T15:39:14-07:00","dur":13500000,"user":"Darauz","use_stop":true,"client":"AAN","project":"AAN-Neur-001b | Epidural Steroids","project_color":"0","project_hex_color":"#a01aa5","task":null,"billable":null,"is_billable":true,"cur":null,"tags":["Primary Extraction"]},{"id":835253190,"pid":58550545,"tid":null,"uid":1,"description":"1864055","start":"2018-03-28T08:34:35-07:00","end":"2018-03-28T12:19:35-07:00","updated":"2018-03-28T14:59:52-07:00","dur":13500000,"user":"Ptran","use_stop":true,"client":"AAN","project":"AAN-Neur-001b | Epidural Steroids","project_color":"0","project_hex_color":"#a01aa5","task":null,"billable":null,"is_billable":true,"cur":null,"tags":["Primary Extraction"]}]}'
            );
        }
        else {
            resp.setBody(this.payload);
        }

        return resp;
    }
}