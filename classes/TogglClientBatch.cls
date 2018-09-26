/*******************************************************************************************************
*    Name:  TogglClientBatch.cls
*    Author:  
*    Date:  9/5/2018
*    
*    Scheduler class: TogglClientScheduler.cls
*    Test class: TogglClientBatchTest.cls
*    Create SF Account if Toggl Client id is not in SF
*    TogglClientBatch d = new TogglClientBatch(); 
*    database.executebatch(d, 1);
********************************************************************************************************/

global class TogglClientBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {

    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        String Query='SELECT Id, Name, Toggl_Id__c FROM Account LIMIT 1';
        return Database.getQueryLocator(Query);
    }

    global void execute(Database.BatchableContext bc, List<Account> scope)
    {
        List<Account> allAccounts = [SELECT Id, Name, Toggl_Id__c FROM Account WHERE Toggl_Id__c != ''];
        Map<String, Account> AccountMapTogglId = new Map<String, Account>();
        
        for(Account acc: allAccounts) {
            if(!String.isEmpty(acc.Toggl_Id__c))
                AccountMapTogglId.put(acc.Toggl_Id__c, acc);
            
        }
        
        List<ToggleAccount__mdt> creds = [SELECT API_Token__c FROM ToggleAccount__mdt];
        if (creds.isEmpty()) {
            throw new RequiredFeatureMissingException('Please add Toggle credentials in custom metadata');
        }
        
        String tokenString = creds[0].API_Token__c + ':api_token';
        Blob blobToken = Blob.valueOf(tokenString);
        tokenString = EncodingUtil.base64Encode(blobToken);
        tokenString = 'Basic ' + tokenString;
        String  authToken = tokenString;
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://www.toggl.com/api/v8/clients');
        request.setMethod('GET');
        request.setHeader('Authorization', authToken);
        request.setHeader('Content-Type', 'application/json');
        
        Http http = new Http();
        HttpResponse response = http.send(request);
        
        // Parse the JSON response
        if (response.getStatusCode() != 200) {
            System.debug('The status code returned was not expected: ' +
            response.getStatusCode() + ' ' + response.getStatus());
        } else {
            String responseBody = response.getBody();
            System.debug('responseBody ====> ' + responseBody);
            JSONParser parser = JSON.createParser(responseBody);
            
            List<Account> accToInsert = new List<Account>();
            Account currentAccount;
            
            while (parser.nextToken() != null) {            
                JSONToken token = parser.getCurrentToken();
                String value = parser.getText();

                if(value == 'id') {
                    currentAccount = new Account();
                    parser.nextToken();     
                    parser.getCurrentToken(); 
                    currentAccount.Toggl_Id__c = parser.getText();             
                }
                if(value == 'name') {
                    parser.nextToken();     
                    parser.getCurrentToken(); 
                    currentAccount.Name = parser.getText(); 
                    if(!AccountMapTogglId.containsKey(currentAccount.Toggl_Id__c))
                        accToInsert.add(currentAccount); 
                             
                }
                if(value == 'notes') {
                    parser.nextToken();     
                    parser.getCurrentToken(); 
                    currentAccount.Description = parser.getText(); 
                                
                }
                
            }
            
            if(accToInsert.size() > 0)
                insert accToInsert;
            
        }
    }

    global void finish(Database.BatchableContext bc)
    {
        
    }
}