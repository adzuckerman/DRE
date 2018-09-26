/********************************************************************************************************
*    Handler class: ToggleProjectUpdate.cls
*    Author:  
*    Date:  8/22/2018
*    
*    Called from:  TASKRAYProjectAllHandler.trigger
*    Test class: ToggleProjectUpdateTest.cls
********************************************************************************************************/

public class ToggleProjectUpdate
{
    
    @Future(callout=true)
    public static void DeactivateToggleProject(Set<String> setId) 
    {
        if(setId.size() > 0)
        {
            List<ToggleAccount__mdt> creds = [SELECT API_Token__c FROM ToggleAccount__mdt];
            if (creds.isEmpty()) {
                throw new RequiredFeatureMissingException('Please add Toggle credentials in custom metadata');
            }
            
            String tokenString = creds[0].API_Token__c + ':api_token';
            Blob blobToken = Blob.valueOf(tokenString);
            tokenString = EncodingUtil.base64Encode(blobToken);
            tokenString = 'Basic ' + tokenString;
            String  authToken = tokenString;
            
            for(String s: setId)
            {
                
                HttpRequest request = new HttpRequest();
                request.setEndpoint('https://www.toggl.com/api/v8/projects/' + s);
                request.setMethod('PUT');
                request.setBody('{"project":{"active":false}}');
                request.setHeader('Authorization', authToken);
                request.setHeader('Content-Type', 'application/json');
                System.debug('--- Authorization header: ' + authToken);
                
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