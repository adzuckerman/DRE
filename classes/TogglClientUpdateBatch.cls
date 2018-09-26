/*******************************************************************************************************
*    Name:  TogglClientUpdateBatch.cls
*    Author:  
*    Date:  9/5/2018
*
*    Test class: TogglClientBatchTest.cls
*    Update SF Account with Toggl Client id (by Name)
*    TogglClientUpdateBatch d = new TogglClientUpdateBatch(); 
*    database.executebatch(d, 1);
********************************************************************************************************/

global class TogglClientUpdateBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {

    public class Client {
        public String id;
        public String name;
    }
    public Map<String, String> ClientsMap; 

    global Database.QueryLocator start(Database.BatchableContext bc)
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
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://www.toggl.com/api/v8/clients');
        request.setMethod('GET');
        request.setHeader('Authorization', authToken);
        request.setHeader('Content-Type', 'application/json');
        
        Http http = new Http();
        HttpResponse response = http.send(request);

        Set<String> ClientNames = new Set<String>();
        // Parse the JSON response
        if (response.getStatusCode() != 200) {
            System.debug('The status code returned was not expected: ' +
            response.getStatusCode() + ' ' + response.getStatus());
        } else {
            String responseBody = response.getBody();
            ClientsMap = new Map<String, String>(); 
            List<Client> clients = (List<Client>)JSON.deserialize(responseBody, List<Client>.class);
            for(Client c: clients)
            {
                ClientsMap.put(c.name, c.id);
            }
            ClientNames = ClientsMap.keySet();
        }   
        String query = 'SELECT Id, Name, Toggl_Id__c FROM Account WHERE Toggl_Id__c = \'\' AND Name IN :ClientNames  ';
        
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Account> scope)
    {    
        Map<String, Account> AccountMapTogglName = new Map<String, Account>();
        for(Account acc: scope) {
            AccountMapTogglName.put(acc.Name, acc);
        }
        
        List<Account> AccountsToUpdate = new List<Account>();
        for(String c: ClientsMap.keySet())
        {
            if(AccountMapTogglName.containsKey(c))
            {
                Account newAcc = AccountMapTogglName.get(c);
                newAcc.Toggl_Id__c = ClientsMap.get(c);
                AccountsToUpdate.add(newAcc);
            }
        }

        if(AccountsToUpdate.size() > 0)
           update AccountsToUpdate;
    }

    global void finish(Database.BatchableContext bc)
    {
        
    }
}