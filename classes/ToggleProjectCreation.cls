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
            
            List<TASKRAY__Project__c> TaskProjects = [SELECT Id, Name, Secondary_Project_Name__c, TASKRAY__trAccount__c,  TASKRAY__trAccount__r.Toggl_Id__c   FROM TASKRAY__Project__c WHERE Id IN: TaskProjIds];
            List<ToggleAccount__mdt> creds = [SELECT API_Token__c FROM ToggleAccount__mdt];
            if (creds.isEmpty()) {
                throw new RequiredFeatureMissingException('Please add Toggle credentials in custom metadata');
            }
            
            String tokenString = creds[0].API_Token__c + ':api_token';
            Blob blobToken = Blob.valueOf(tokenString);
            tokenString = EncodingUtil.base64Encode(blobToken);
            tokenString = 'Basic ' + tokenString;
            String  authToken = tokenString;
            
            for(TASKRAY__Project__c tp: TaskProjects)
            {
                
                HttpRequest request = new HttpRequest();
                request.setEndpoint('https://www.toggl.com/api/v8/projects');
                request.setMethod('POST');
                request.setBody('{"project":{"name": "' + tp.Name + ' | ' + tp.Secondary_Project_Name__c  + '", "wid":590797, "cid":' + tp.TASKRAY__trAccount__r.Toggl_Id__c + ', "active":true, "is_private":false, "billable":true}}');
                request.setHeader('Authorization', authToken);
                request.setHeader('Content-Type', 'application/json');
                
                Http http = new Http();
                HttpResponse response = http.send(request);
                System.debug(response.getBody());
                
                // Parse the JSON response
                if (response.getStatusCode() != 201) {
                    System.debug('The status code returned was not expected: ' +
                        response.getStatusCode() + ' ' + response.getStatus());
                } else {
                    System.debug(response.getBody());
                }
            }
        }
       
    }
    
    
    
}