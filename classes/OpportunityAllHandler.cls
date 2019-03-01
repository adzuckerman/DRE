/********************************************************************************************************
*    Handler Name:  OpportunityAllHandler.cls
*    Author: OMNIVO DIGITAL (www.omnivodigital.com)
*    Date:  9/24/2018
*    
*    Trigger: OpportunityAll.trigger
*    Test class: OpportunityAllHandlerTest.cls
********************************************************************************************************/

public class OpportunityAllHandler {
    //Handler for before insert methods
    public void onBeforeInsert(list<Opportunity> newList , map<id, Opportunity> newMap) {
        setPricebookId(newList);       
    }
    //Handler for after insert methods
    public void onAfterInsert(list<Opportunity> newList , map<id, Opportunity> newMap) {
        Set<Id> createTogglProjectOppIdSet = new Set<Id>();

        for(Opportunity opp : newList)
        {
            if(opp.StageName == 'Capabilities Presentation')
            {
                createTogglProjectOppIdSet.add(opp.Id);
            }
        }

        if(createTogglProjectOppIdSet.size() > 0)
        {
            CreateTogglProject(createTogglProjectOppIdSet);
        }
        
        MapToProductOnInsert(newList);
    }
    //Handler for before Update methods
    public void onBeforeUpdate(list<Opportunity> newList, map<id, Opportunity> newMap , map<id, Opportunity> oldMap) {
    	checkForecast(newList, newMap, oldMap);   
    }
    //Handler for after Update methods
    public void onAfterUpdate(list<Opportunity> newList, map<id, Opportunity> newMap,  map<id, Opportunity> oldMap) {
        MapToProductOnUpdate(newList, oldMap);
        UpdateTogglTimeEntryGAAPClass(newList, newMap, oldMap);
        UpdateInvoicesOnClosedWon(newList, oldMap);
	
		Set<Id> createTogglProjectOppIdSet = new Set<Id>();
        Set<String> archiveTogglProjectIdSet = new Set<String>();

        for(Opportunity opp : newList)
        {
            if(opp.StageName == 'Capabilities Presentation')
            {
                createTogglProjectOppIdSet.add(opp.Id);
            }

            if(opp.IsClosed == true && !String.isBlank(opp.Toggl_Id__c))
            {
                archiveTogglProjectIdSet.add(opp.Toggl_Id__c);
            }
        }

        if(createTogglProjectOppIdSet.size() > 0)
        {
            CreateTogglProject(createTogglProjectOppIdSet);
        }

        if(archiveTogglProjectIdSet.size() > 0)
        {
            DeactivateToggleProject(archiveTogglProjectIdSet);
        }   
    }

    //Handler for before Deletes methods
    /*public void onBeforeDelete(list<Opportunity> oldList , map<id, Opportunity> oldMap) {

    }
    //Handler for after Deletes methods
    public void onAfterDelete(list<Opportunity> oldList , map<id, Opportunity> oldMap) {

    }*/
    
    public void setPricebookId(List<Opportunity> newOppList)
    {
        Pricebook__mdt pricebookMdt = [select Pricebook_Id__c from Pricebook__mdt Limit 1];
        
        for(Opportunity oppTmp : newOppList)
        {
            if(Test.isRunningTest() && oppTmp.Use_New_Forecasting_Algorithm__c)
            {
                oppTmp.Pricebook2Id = Test.getStandardPricebookId();
            }
            /*else if(Test.isRunningTest() && !oppTmp.Use_New_Forecasting_Algorithm__c){
            	oppTmp.Pricebook2Id = [SELECT Id FROM Pricebook2 WHERE Name = :RevenueCalculationUtil.PRICEBOOK_NAME LIMIT 1].Id;    
            }*/
            else
            {
                if(oppTmp.Use_New_Forecasting_Algorithm__c)
                {
                	oppTmp.Pricebook2Id = pricebookMdt.Pricebook_Id__c;    
                }
            }
        }
    }

    private static Map<String, String> offeringsToProductsP;
    public static Map<String, String> offeringsToProducts {
        get {
            if (offeringsToProductsP == null) {
                offeringsToProductsP = new Map<String, String>();
                for (Product_Category_To_Product_Name__mdt mdt : [SELECT Product_Category__c, Product_Name__c FROM Product_Category_To_Product_Name__mdt]) {
                    offeringsToProductsP.put(mdt.Product_Category__c, mdt.Product_Name__c);
                }
            }
            return offeringsToProductsP;
        }
    }
    
    private static Pricebook__mdt pricebookMdtP;
    public static Pricebook__mdt pricebookMdt {
        get {
            if (pricebookMdtP == null) {
                pricebookMdtP = [select Pricebook_Id__c from Pricebook__mdt Limit 1];
            }
            return pricebookMdtP;
        }
    }
    
    public void MapToProductOnInsert(List<Opportunity> newOppList)
    {
        string pricebookId;
        
        if(Test.isRunningTest())
        {
            pricebookId = Test.getStandardPricebookId();
        }
        else
        {
            pricebookId = pricebookMdt.Pricebook_Id__c;
        }
        
        Set<String> productNameList = new Set<String>();
		Set<String> productNameOldList = new Set<String>();        
        
        for(Opportunity oppTmp : newOppList) 
        {
            productNameList.add(offeringsToProducts.containsKey(oppTmp.Product_Category__c) ? offeringsToProducts.get(oppTmp.Product_Category__c) : oppTmp.Product_Category__c);
        }

        system.debug('productNameList---' + productNameList);
        system.debug('pricebookId---' + pricebookId);
        List<PricebookEntry> pbeList = [select Id, UnitPrice, Product2.Name from PricebookEntry where Pricebook2Id =:pricebookId and Product2.Name in :productNameList];
            
        system.debug('pbeList---' + pbeList);
        
        if(!pbeList.isEmpty())        
        {
            Map<String, PricebookEntry> productNameToPbeMap = new Map<String, PricebookEntry>();
            
            for(PricebookEntry pbeTmp : pbeList)
            {
                productNameToPbeMap.put(pbeTmp.Product2.Name, pbeTmp);
            }
            
            List<OpportunityLineItem> olisToInsert = new List<OpportunityLineItem>();
            for(Opportunity oppTmp : newOppList)
            {
                String ProductName = oppTmp.Product_Category__c;
                if (offeringsToProducts.containsKey(oppTmp.Product_Category__c)) {
                    ProductName = offeringsToProducts.get(oppTmp.Product_Category__c);
                }
                if(productNameToPbeMap.keySet().contains(ProductName))
                {
                    OpportunityLineItem oliTmp = new OpportunityLineItem(OpportunityId = oppTmp.Id,                                                                                 
                                                                         PricebookEntryId = productNameToPbeMap.get(ProductName).Id,
                                                                         UnitPrice = productNameToPbeMap.get(ProductName).UnitPrice,
                                                                         Quantity = 1);                       
                    olisToInsert.add(oliTmp);
                }
            }
            if (!olisToInsert.isEmpty())
            {
                insert olisToInsert;
            }
            
        }
    }
    
    public void checkForecast(list<Opportunity> newList, map<id, Opportunity> newMap , map<id, Opportunity> oldMap){
        for (Opportunity newOpp : newList) {
            Opportunity oldOpp = oldMap.get(newOpp.Id);
        	if (!oldOpp.In_Forecast__c && newOpp.StageName == 'Closed Won' && oldOpp.StageName != newOpp.StageName) {
            	newOpp.addError('Opportunity must be in forecast prior to Closed Won');
            }
        }
    }
    
    public void MapToProductOnUpdate(List<Opportunity> newOppList, Map<Id, Opportunity> oldMap)
    {
        string pricebookId;
        
        if(Test.isRunningTest())
        {
            pricebookId = Test.getStandardPricebookId();
        }
        else
        {
            pricebookId = pricebookMdt.Pricebook_Id__c;
        }
        
        Set<String> toRemove = new Set<String>();
        Set<String> toInsert = new Set<String>();
        Set<Id> oppIds = new Set<Id>();
        Set<String> productNames = new Set<String>();
        for (Opportunity newOpp : newOppList) {
            Opportunity oldOpp = oldMap.get(newOpp.Id);
            if (newOpp.Product_Category__c != oldOpp.Product_Category__c) {
                oppIds.add(newOpp.Id);
                if (newOpp.Product_Category__c != null) {
                	toInsert.add(newOpp.Id + '~' + (offeringsToProducts.containsKey(newOpp.Product_Category__c) ? offeringsToProducts.get(newOpp.Product_Category__c) : newOpp.Product_Category__c));
            		productNames.add(offeringsToProducts.containsKey(newOpp.Product_Category__c) ? offeringsToProducts.get(newOpp.Product_Category__c) : newOpp.Product_Category__c);
                }
                if (oldOpp.Product_Category__c != null) {
                	toRemove.add(oldOpp.Id + '~' + (offeringsToProducts.containsKey(oldOpp.Product_Category__c) ? offeringsToProducts.get(oldOpp.Product_Category__c) : oldOpp.Product_Category__c));
            		productNames.add(offeringsToProducts.containsKey(oldOpp.Product_Category__c) ? offeringsToProducts.get(oldOpp.Product_Category__c) : oldOpp.Product_Category__c);
                }
            }
        }
        
        if (toRemove.size() > 0) {
            List<OpportunityLineItem> oliToDelete = new List<OpportunityLineItem>();
            for (String key : toRemove) {
                for (OpportunityLineItem oli : [SELECT Id, OpportunityId, PricebookEntry.Product2.Name FROM OpportunityLineItem WHERE OpportunityId IN :oppIds AND PricebookEntry.Product2.Name IN :productNames]) {
                    if (toRemove.contains(oli.OpportunityId + '~' + oli.PricebookEntry.Product2.Name)) {
                        oliToDelete.add(oli);
                    }
                }
            }
            if (oliToDelete.size() > 0) {
                //RevenueCalculationUtil.isTriggerEnabled = false;
                //RevenueCalculationUtil2.isTriggerEnabled = false;
                delete oliToDelete;
                //RevenueCalculationUtil.isTriggerEnabled = true;
                //RevenueCalculationUtil2.isTriggerEnabled = true;
            }
        }
        
        if (toInsert.size() > 0) {
            List<PricebookEntry> pbeList = [select Id, UnitPrice, Product2.Name from PricebookEntry where Pricebook2Id =:pricebookId and Product2.Name in :productNames];
            
            Map<String, PricebookEntry> productNameToPbeMap = new Map<String, PricebookEntry>();
            
            for(PricebookEntry pbeTmp : pbeList)
            {
                productNameToPbeMap.put(pbeTmp.Product2.Name, pbeTmp);
            }
            
            List<OpportunityLineItem> oliToInsert = new List<OpportunityLineItem>();
            for (String key : toInsert) {
                String oppId = key.split('~')[0];
                String productName = key.split('~')[1];
                
                OpportunityLineItem oliTmp = new OpportunityLineItem(OpportunityId = oppId,                                                                                 
                                                                         PricebookEntryId = productNameToPbeMap.get(productName).Id,
                                                                         UnitPrice = productNameToPbeMap.get(productName).UnitPrice,
                                                                         Quantity = 1);                       
                oliToInsert.add(oliTmp);
            }
            if (oliToInsert.size() > 0) {
                //RevenueCalculationUtil.isTriggerEnabled = false;
                //RevenueCalculationUtil2.isTriggerEnabled = false;
                insert oliToInsert;
                //RevenueCalculationUtil.isTriggerEnabled = true;
                //RevenueCalculationUtil2.isTriggerEnabled = true;
            }
        }
    }
    
    private void UpdateInvoicesOnClosedWon(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        Set<Id> oppIds = new Set<Id>();
        for (Opportunity newOpp : newList) {
            Opportunity oldOpp = oldMap.get(newOpp.Id);
            if (newOpp.StageName == 'Closed Won' && oldOpp.StageName != 'Closed Won') {
                oppIds.add(newOpp.Id);
            }
        }
        
        List<Invoice__c> invoices = [SELECT Id FROM Invoice__c WHERE Opportunity__c IN :oppIds AND Invoice_Num__c != 'TBD' AND Invoice_Amount__c != null AND Invoice_Amount__c != 0];
        for (Invoice__c invoice : invoices) {
            invoice.Invoice_Num__c = 'TBD';
        }
        update invoices;
    }
    
    
    
    @Future(callout=true)
    public static void DeactivateToggleProject(Set<String> setId) 
    {
        if(setId.size() > 0)
        {
            List<ToggleAccount__mdt> creds = 
                [
                    SELECT API_Token__c 
                    FROM ToggleAccount__mdt
                ];

            if(creds.isEmpty()) 
            {
                throw new RequiredFeatureMissingException('Please add Toggle credentials in custom metadata');
            }
            
            String tokenString = creds[0].API_Token__c + ':api_token';
            Blob blobToken = Blob.valueOf(tokenString);
            tokenString = EncodingUtil.base64Encode(blobToken);
            tokenString = 'Basic ' + tokenString;
            String  authToken = tokenString;
            
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

            for(String s : setId)
            {                
                HttpRequest request = new HttpRequest();
                request.setEndpoint('https://www.toggl.com/api/v8/projects/' + s);
                request.setMethod('PUT');
                request.setBody('{"project":{"active":false}}');
                request.setHeader('Authorization', authToken);
                request.setHeader('Content-Type', 'application/json');
                
                Http http = new Http();

                if(!Test.isRunningTest())
                {
                    HttpResponse response = http.send(request);

                    // Parse the JSON response
                    if (response.getStatusCode() != 200 && response.getStatusCode() != 201) 
                    {
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses(new String[] { UserInfo.getUserEmail() });
                        mail.setSenderDisplayName('Salesforce');
                        mail.setSubject('Project could not be archived');
                        mail.setUseSignature(false);
                        mail.setHtmlBody('Project with Toggl Id ' + s + ' could not be archived in Toggl. We received the following error: <br /> <br />' + response.getStatusCode() + ' ' + response.getStatus() + '<br />' + response.getBody());
                        emails.add(mail);                        
                    }
                }
            }
            
            if (emails.size() > 0) 
            {
                Messaging.sendEmail(emails);
            }
        }       
    }

    @Future(callout=true)
    public static void CreateTogglProject(Set<Id> createTogglProjectOppIdSet)
    {        
        List<ToggleAccount__mdt> creds = 
            [
                SELECT API_Token__c, Workspace_ID__c 
                FROM ToggleAccount__mdt
            ];

        if(creds.isEmpty()) 
        {
            throw new RequiredFeatureMissingException('Please add Toggle credentials in custom metadata');
        }
        
        List<Opportunity> oppList = 
            [
                SELECT Id, Opportunity_ID__c, Account.Toggl_Id__c
                FROM Opportunity
                WHERE Id IN :createTogglProjectOppIdSet
            ];

        if(oppList.size() > 0)
        {
            String tokenString = creds[0].API_Token__c + ':api_token';
            Blob blobToken = Blob.valueOf(tokenString);
            tokenString = EncodingUtil.base64Encode(blobToken);
            tokenString = 'Basic ' + tokenString;
            String authToken = tokenString;
			
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

            for(Opportunity opp : oppList)
            {
            	if (existingProjectsMap.containsKey(opp.Opportunity_ID__c + ' | Pre-Sale')) {
                    opp.Toggl_Id__c = existingProjectsMap.get(opp.Opportunity_ID__c + ' | Pre-Sale');
                }
                else {
                    request = new HttpRequest();
                    request.setEndpoint('https://www.toggl.com/api/v8/projects');
                    request.setMethod('POST');
                    request.setBody('{"project":{"name": "' + opp.Opportunity_ID__c + ' | Pre-Sale", "wid": 590797, "cid":' + opp.Account.Toggl_Id__c + ', "active":true, "is_private":false, "billable":true}}');
                    request.setHeader('Authorization', authToken);
                    request.setHeader('Content-Type', 'application/json');
                    
                    http = new Http();
                    response = http.send(request);
                    
                    // Parse the JSON response
                    if (response.getStatusCode() != 200 && response.getStatusCode() != 201) 
                    {
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses(new String[] { UserInfo.getUserEmail()});
                        mail.setSenderDisplayName('Salesforce');
                        mail.setSubject('Project could not be created');
                        mail.setUseSignature(false);
                        mail.setHtmlBody('Project ' + opp.Opportunity_ID__c + ' | Pre-Sale could not be created in Toggl. We received the following error: <br /> <br />' + response.getStatusCode() + ' ' + response.getStatus() + '<br />' + response.getBody());
                        emails.add(mail);
                    } 
                    else 
                    {
                        TogglResponse responseObj = (TogglResponse)JSON.deserialize(response.getBody(), TogglResponse.class);
                        opp.Toggl_Id__c = responseObj.data.id;
                        system.debug('opp.Toggl_Id__c---' + opp.Toggl_Id__c);
                    }
                }
            }

            if(emails.size() > 0) 
            {
                Messaging.sendEmail(emails);
            }
            
            system.debug('oppList---' + oppList);
            update oppList;
        }       
    }
    
    public class TogglResponse 
    {
        public TogglResponseData data { get; set; }
    }
    
    public class TogglResponseData 
    {
        public String id { get; set; }
    }
    
    public class ExistingProject {
    	public string id { get; set; }
        public string name { get; set; }
    }

    private void UpdateTogglTimeEntryGAAPClass(list<Opportunity> newList , map<id, Opportunity> newMap, map<id, Opportunity> oldMap)
    {
        Set<Id> OpportunityIds = new Set<Id>();
        for( Opportunity opp: newList ) 
        {
            Opportunity oldOpp = oldMap.get(opp.Id);
            if(opp.StageName != oldOpp.StageName)
                OpportunityIds.add(opp.Id);
        }
        
        if(OpportunityIds.size() > 0)
        {
            List<Toggl_Time_Entry__c> TogglTimeEntries = [SELECT Id, GAAP_Class__c, Account__c, Account__r.Name, Project__c, Project__r.Name, Project__r.TASKRAY__trOpportunity__c, Project__r.TASKRAY__trOpportunity__r.StageName, Opportunity__c, Opportunity__r.StageName FROM Toggl_Time_Entry__c WHERE Opportunity__c IN: OpportunityIds];
            UpdateTimeEntryGAAPClass(TogglTimeEntries);
        }
            
    }
    
    
    // called also from TogglGAAPClassBatch.cls
    public void UpdateTimeEntryGAAPClass(List<Toggl_Time_Entry__c> allTimeEntries) {
        if(allTimeEntries.size() > 0)
        {
            for ( Toggl_Time_Entry__c timeEntry : allTimeEntries ) {
                
                String StageName = '';
                if(timeEntry.Opportunity__c == null)
                {
                    timeEntry.Opportunity__c = timeEntry.Project__r.TASKRAY__trOpportunity__c; 
                    StageName = timeEntry.Project__r.TASKRAY__trOpportunity__r.StageName; 
                } else {
                    StageName = timeEntry.Opportunity__r.StageName; 
                }   

                if(!String.isEmpty(timeEntry.Project__r.Name) && !String.isEmpty(StageName) && !String.isEmpty(timeEntry.Account__r.Name))
                {
                    String taskrayType = '';
                    if((timeEntry.Project__r.Name).contains('-'))
                    {
                        String[] splitProject = (timeEntry.Project__r.Name).split('-');
                        if(splitProject[2] != null && splitProject[2] != '')
                        {
                            if(splitProject[2].length() == 3)
                                taskrayType = 'PICO ID';
                            if(splitProject[2].length() == 4)
                                taskrayType = 'Contract ID';
                        }
                    }
                    
                    if(timeEntry.Account__r.Name != 'Doctor Evidence' && timeEntry.Account__r.Name != 'DRE Tech')
                    {
                        if(taskrayType == 'Contract ID' || taskrayType == 'PICO ID' || timeEntry.Project__r.Name == 'DOC Label' || timeEntry.Project__r.Name == 'Data Hub')
                        {
                            if(StageName != 'Closed Won' && StageName != 'Closed Lost')
                            {
                                timeEntry.GAAP_Class__c  = 'Work In Progress';  
                            } 
                            if(StageName == 'Closed Won')
                                timeEntry.GAAP_Class__c = 'Cost of Revenue';
                            if(StageName == 'Closed Lost')   
                                timeEntry.GAAP_Class__c = 'Sales & Marketing';
                        }
                        else if (timeEntry.Project__r.Name == 'Pre-Sale'){
                            timeEntry.GAAP_Class__c = 'Sales & Marketing';
                        }
                    } else {
                        if(timeEntry.Account__r.Name == 'Doctor Evidence')
                        {
                            if(timeEntry.Project__r.Name == 'CE Admin/Internal' || timeEntry.Project__r.Name == 'CS Admin/Internal')
                            {
                                timeEntry.GAAP_Class__c = 'Sales & Marketing';
                            } else {
                                timeEntry.GAAP_Class__c = 'General & Administrative';
                            }
                           
                        } else {
                            if(timeEntry.Account__r.Name == 'DRE Tech')
                            {
                                if(timeEntry.Project__r.Name == 'DRE Tech_Admin/Internal' || timeEntry.Project__r.Name == 'DRE Tech_Platform Maintenance')
                                {
                                    timeEntry.GAAP_Class__c = 'Research & Development';
                                } else {
                                    timeEntry.GAAP_Class__c = '2.0 Cap';
                                }
                            }
                        }
                    }
                    
                }
            }
            update allTimeEntries;
        }
    }
}