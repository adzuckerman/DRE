/********************************************************************************************************
*    Handler class: ToggleProjectCreation.cls
*    Author: @OmnivoDigital  
*    Date:  9/4/2018
*    
*    Called from:  TASKRAYProjectAllHandler.trigger
*    Test class: ToggleProjectCreationTest.cls
********************************************************************************************************/

public class ToggleProjectCreation
{
    
    @Future(callout=true)
    public static void CreateToggleProject(Set<Id> TaskProjIds) 
    {
        if(TaskProjIds.size() > 0)
        {
            
            List<TASKRAY__Project__c> TaskProjects = [SELECT Id, Name, Secondary_Project_Name__c, TASKRAY__trAccount__c, TASKRAY__trAccount__r.Toggl_Id__c, TASKRAY__trOpportunity__r.Id  FROM TASKRAY__Project__c WHERE Id IN: TaskProjIds];
            List<ToggleAccount__mdt> creds = [SELECT API_Token__c, Workspace_ID__c FROM ToggleAccount__mdt];
            if (creds.isEmpty()) {
                throw new RequiredFeatureMissingException('Please add Toggle credentials in custom metadata');
            }
            
            String tokenString = creds[0].API_Token__c + ':api_token';
            Blob blobToken = Blob.valueOf(tokenString);
            tokenString = EncodingUtil.base64Encode(blobToken);
            tokenString = 'Basic ' + tokenString;
            String  authToken = tokenString;
            
            // Get existing projects
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://www.toggl.com/api/v8/workspaces/' + creds[0].Workspace_ID__c + '/projects');
            request.setMethod('GET');
            request.setHeader('Authorization', authToken);
            request.setHeader('Content-Type', 'application/json');
            Http http = new Http();
            HttpResponse response = http.send(request);
            List<ExistingProject> existingProjects = (List<ExistingProject>)JSON.deserialize(response.getBody(), List<ExistingProject>.class);
            Map<String, String> existingProjectsMap = new Map<String, String>();
            for (ExistingProject existingProject : existingProjects) {
                existingProjectsMap.put(existingProject.name, existingProject.id);
            }
            
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            //List<Opportunity> toUpdate = new List<Opportunity>();
            for(TASKRAY__Project__c tp: TaskProjects)
            {
                if (existingProjectsMap.containsKey(tp.Name + ' | ' + tp.Secondary_Project_Name__c)) {
                    tp.Toggl_Id__c = existingProjectsMap.get(tp.Name + ' | ' + tp.Secondary_Project_Name__c);
                    if (tp.TASKRAY__trOpportunity__c != null) {
                        tp.TASKRAY__trOpportunity__r.Toggl_Id__c = tp.Toggl_Id__c;
                        //toUpdate.add(tp.TASKRAY__trOpportunity__r);
                    }
                } else {
                    request = new HttpRequest();
                    request.setEndpoint('https://www.toggl.com/api/v8/projects');
                    request.setMethod('POST');
                    request.setBody('{"project":{"name": "' + tp.Name + ' | ' + tp.Secondary_Project_Name__c  + '", "wid": ' + creds[0].Workspace_ID__c + ', "cid":' + tp.TASKRAY__trAccount__r.Toggl_Id__c + ', "active":true, "is_private":false, "billable":true}}');
                    request.setHeader('Authorization', authToken);
                    request.setHeader('Content-Type', 'application/json');
                    
                    http = new Http();
                    response = http.send(request);
                    System.debug(response.getBody());
                    
                    // Parse the JSON response
                    if (response.getStatusCode() != 200 && response.getStatusCode() != 201) {
                        System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus() + ' : ' + response.getBody());
                        
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses(new String[] { UserInfo.getUserEmail() });
                        mail.setSenderDisplayName('Salesforce');
                        mail.setSubject('Project could not be created');
                        mail.setUseSignature(false);
                        mail.setHtmlBody('Project ' + tp.Name + ' could not be created in Toggl. We received the following error: <br /> <br />' + response.getStatusCode() + ' ' + response.getStatus() + '<br />' + response.getBody());
                        emails.add(mail);
                    } else {
                        TogglResponse responseObj = (TogglResponse)JSON.deserialize(response.getBody(), TogglResponse.class);
                        tp.Toggl_Id__c = responseObj.data.id;
                    }
                }
            }
            
            if (emails.size() > 0) {
                Messaging.sendEmail(emails);
            }
            
            update TaskProjects;
            /*if (toUpdate.size() > 0)
                update toUpdate;*/
        }
       
    }
    
    public class TogglResponse {
        public TogglResponseData data { get; set; }
    }
    
    public class TogglResponseData {
        public string id { get; set; }
    }
    
    public class ExistingProject {
        public string id { get; set; }
        public string name { get; set; }
    }
    
}