/********************************************************************************************************
*    Handler class: ToggleClientCreation.cls
*    Author:  
*    Date:  9/4/2018
*    
*    Called from:  AccountAllHandler.trigger
*    Test class: ToggleClientCreationTest.cls
********************************************************************************************************/

public class ToggleClientCreation
{
    
    @Future(callout=true)
    public static void CreateToggleClient(Set<Id> AccountIds) 
    {
		System.debug('***ToggleClientCreation - CreateToggleClient() - AccountIds: ');
		System.debug(AccountIds);

        if(AccountIds.size() > 0)
        {
            
            List<Account> Accounts = [SELECT Id, Name, Description, Toggl_Id__c FROM Account WHERE Id IN: AccountIds];
            List<ToggleAccount__mdt> creds = [SELECT API_Token__c FROM ToggleAccount__mdt];
            if (creds.isEmpty()) {
                throw new RequiredFeatureMissingException('Please add Toggle credentials in custom metadata');
            }
            
            String tokenString = creds[0].API_Token__c + ':api_token';
            Blob blobToken = Blob.valueOf(tokenString);
            tokenString = EncodingUtil.base64Encode(blobToken);
            tokenString = 'Basic ' + tokenString;
            String  authToken = tokenString;
            
            List<Account> accToUpdate = new List<Account>();
            
            for(Account acc: Accounts )
            {
                
                HttpRequest request = new HttpRequest();
                request.setEndpoint('https://www.toggl.com/api/v8/clients');
                request.setMethod('POST');
                request.setBody('{"client":{"name":"' + acc.Name + '", "wid":590797, "notes":"' + acc.Description + '"}}');
                request.setHeader('Authorization', authToken);
                request.setHeader('Content-Type', 'application/json');
                
                Http http = new Http();
                HttpResponse response = http.send(request);
                
				System.debug('***ToggleClientCreation - CreateToggleClient() - response.getStatusCode(): ');
				System.debug(response.getStatusCode());
                
                // Parse the JSON response
                if (response.getStatusCode() != 200) {
                    System.debug('The status code returned was not expected: ' +
                        response.getStatusCode() + ' ' + response.getStatus());
                } else {
                    String responseBody = response.getBody();
                    System.debug(responseBody);
					System.debug('***ToggleClientCreation - CreateToggleClient() - responseBody: ');
					System.debug(responseBody);

                    JSONParser parser = JSON.createParser(responseBody);

                    while (parser.nextToken() != null) {            
                        JSONToken token = parser.getCurrentToken();
                        String value = parser.getText();
                        
                        if(value == 'id') {
                            parser.nextToken();     
                            parser.getCurrentToken(); 
                            acc.Toggl_Id__c = parser.getText();
                            accToUpdate.add(acc);               
                        }
                    }
                }
            }
            
            if(accToUpdate.size() > 0)
                update accToUpdate;
        }
    }
    

}