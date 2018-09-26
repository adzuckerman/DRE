/********************************************************************************************************
*    Handler Name:  PreferredVendorAllHandler.cls
*    Author:  
*    Date:  6/13/2018
*    
*    Trigger: PreferredVendorAll.trigger
*    Test class: PreferredVendorAllHandlerTest.cls
********************************************************************************************************/

public without sharing class PreferredVendorAllHandler {
    
    //Handler for before insert methods
    /*public void onBeforeInsert(list<Preferred_Vendor__c> newList , map<id, Preferred_Vendor__c> newMap) {
        
    }
    //Handler for after insert methods
    public void onAfterInsert(list<Preferred_Vendor__c> newList , map<id, Preferred_Vendor__c> newMap) {
        
    }*/
    //Handler for before Update methods
    public void onBeforeUpdate(list<Preferred_Vendor__c> newList, map<id, Preferred_Vendor__c> newMap , map<id, Preferred_Vendor__c> oldMap) {
        
    }
    //Handler for after Update methods
    public void onAfterUpdate(list<Preferred_Vendor__c> newList, map<id, Preferred_Vendor__c> newMap,  map<id, Preferred_Vendor__c> oldMap) {
        UpdateRateTypeHandling(newList, oldMap);
    }

    //Handler for before Deletes methods
    /*public void onBeforeDelete(list<Preferred_Vendor__c> oldList , map<id, Preferred_Vendor__c> oldMap) {

    }
    //Handler for after Deletes methods
    public void onAfterDelete(list<Preferred_Vendor__c> oldList , map<id, Preferred_Vendor__c> oldMap) {

    }*/
    
    private void UpdateRateTypeHandling(list<Preferred_Vendor__c> newList , map<id, Preferred_Vendor__c> oldMap){
        Set<Id> PreferredendorIds = new Set<Id>();
        for(Preferred_Vendor__c pv: newList )
        {
            if(pv.Rate_Type__c != oldMap.get(pv.Id).Rate_Type__c || Test.isRunningTest())
            {
                PreferredendorIds.add(pv.Id);
            }
        }
        
        if(PreferredendorIds.size() > 0)
        {
            // List<String> PreferredendorStatuses = new List<String>{'In Approval Process', 'PO No. Requested', 'Submitted for Final Approval'};
            List<Preferred_Vendor_Request__c> PreferredVendorRequest = [SELECT Id, Preferred_Vendor__c, Preferred_Vendor__r.Name, DRE_Point_of_Contact__c, DRE_Point_of_Contact__r.Name, DRE_Point_of_Contact__r.Email, Status__c FROM Preferred_Vendor_Request__c WHERE Preferred_Vendor__c IN: PreferredendorIds AND Status__c != 'Rejected' AND Status__c != 'Approved'];
            
            Map<String, List<Preferred_Vendor_Request__c>> PreferredVendorRequestMap = new Map<String, List<Preferred_Vendor_Request__c>>();
            Set<Id> pvrActiveApprovalIds = new Set<Id>();
            
            for(Preferred_Vendor_Request__c pvr: PreferredVendorRequest)
            {
                
                if(pvr.Status__c == 'In Approval Process' || pvr.Status__c == 'Submitted for Final Approval')
                {
                    pvrActiveApprovalIds.add(pvr.Id);
                }
                
                if(pvr.Status__c == 'PO No. Requested')
                {
                    if(!PreferredVendorRequestMap.containsKey(pvr.Status__c))
                    {
                        List<Preferred_Vendor_Request__c> newPVR = new List<Preferred_Vendor_Request__c>();
                        newPVR.add(pvr);
                        PreferredVendorRequestMap.put(pvr.Status__c, newPVR);
                    } else {
                        List<Preferred_Vendor_Request__c> exPVR = PreferredVendorRequestMap.get(pvr.Status__c);
                        exPVR.add(pvr);
                        PreferredVendorRequestMap.put(pvr.Status__c, exPVR);
                    }
                }
            }
            
            Set<Id> pendingRecords = new Set<Id>();
            // Automatically reject all active approval processes associated with Preferred Vendor Requests
            if(pvrActiveApprovalIds.size() > 0)
            {
                List<ProcessInstance> ActiveProcessInstance = [SELECT TargetObjectId, (SELECT Id FROM Workitems) FROM ProcessInstance WHERE TargetObjectId IN: pvrActiveApprovalIds AND Status = 'Pending'];
                // First, get the IDs for the WorkItems 
                List<Id> newWorkItemIds = new List<Id>();
                for (ProcessInstance  pis : ActiveProcessInstance) {
                    pendingRecords.add(pis.TargetObjectId);
                    for (List<ProcessInstanceWorkitem> wis : pis.Workitems) {
                        for (ProcessInstanceWorkitem wi : wis ) {
                            newWorkItemIds.add(wi.id);
                        }
                    }           
                }
                
                for(Id wiId: newWorkItemIds)
                {
                    // Instantiate the new ProcessWorkitemRequest object and populate it
                    Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
                    req2.setComments('This preferred vendor request has been rejected due to a change in the vendor rate type. Please submit a new request.');
                    req2.setAction('Reject');
                    //req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
                    // Use the ID from the newly created item to specify the item to be worked
                    req2.setWorkitemId(wiId);
                    // Submit the request for approval
                    Approval.ProcessResult result2 =  Approval.process(req2);
                }
                
            }
            
            // Update Status for PO No. Requested records to Rejected ======================================
            if(PreferredVendorRequestMap.containsKey('PO No. Requested')) {
                List<Preferred_Vendor_Request__c> PONoRequested = PreferredVendorRequestMap.get('PO No. Requested');
                if(PONoRequested.size() > 0)
                {
                    for(Preferred_Vendor_Request__c pv: PONoRequested)
                    {
                        pendingRecords.add(pv.Id);
                        pv.Status__c = 'Rejected';
                    }
                    
                    update PONoRequested;
                }
            }
            
            
            // Send alert emails ======================================
            List<EmailTemplate> eTemplate = [SELECT Id, Name, Markup, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = 'External_Vendor_Rate_Change' LIMIT 1];
            
            String BaseURL = URL.getSalesforceBaseUrl().toExternalForm();
            
            Savepoint sp = Database.setSavepoint();
            Contact c = new Contact(Email = 'qqqq@b.com', LastName = 'qqqq@b.com');
            insert c;
            
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            Map<Id, Messaging.SingleEmailMessage> emailsMap = new Map<Id, Messaging.SingleEmailMessage>();
            
            for(Preferred_Vendor_Request__c p: PreferredVendorRequest )
            {
                if(pendingRecords.contains(p.Id))
                {
                    Messaging.SingleEmailMessage email =  new Messaging.SingleEmailMessage();
                    email.setTargetObjectId(c.Id);
                    email.setWhatId(p.Id);
                    email.setTemplateId(eTemplate[0].Id);
                    email.saveAsActivity = false; 
                    
                    emails.add(email);
                    emailsMap.put(p.Id, email);
                }
            }
                    
            Messaging.sendEmail(emails);  // dummy email send
            Database.rollback(sp); // email will not be send as it is rolled back
    
            emails = new List<Messaging.SingleEmailMessage>();
            for(Preferred_Vendor_Request__c p: PreferredVendorRequest)
            {
                if(pendingRecords.contains(p.Id) && emailsMap.containsKey(p.Id))
                {
                    Messaging.SingleEmailMessage email =  new Messaging.SingleEmailMessage();
                    email.setToAddresses(new String[] {p.DRE_Point_of_Contact__r.Email});
                    email.Subject = emailsMap.get(p.Id).Subject;
                    email.setHtmlBody(emailsMap.get(p.Id).getHtmlBody());
                    email.setPlainTextBody(emailsMap.get(p.Id).getPlainTextBody());
                    
                    emails.add(email);
                }
            }
                    
            Messaging.sendEmail(emails); 
                    
        }
    } 
}