trigger ContentDocumentTrigger on ContentDocument (before delete) {//, after delete
    if(!Test.isRunningTest() && System.Label.IsActive_ContentDocumentTrigger.equalsIgnoreCase('FALSE')) return;
	
	System.debug(':::ContentDocument :::'+Trigger.old);
    
    if(Trigger.isBefore){
        String profileName =[Select Id, Name from Profile where Id= :userinfo.getProfileId()].Name;
        
        Set<Id> cdIds = new  Set<Id>();       
        for(ContentVersion cv :[ SELECT Id, Is_a_Proposal__c, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId in :Trigger.oldMap.keySet() 
                                and Is_a_Proposal__c=true and isLatest=true]){//and isDeleted=False  
            cdIds.add(cv.ContentDocumentId);
        }
        if(cdIds.isEmpty()) return;
        
        Map<Id, List<Id>> mpCDL = new Map<Id, List<Id>>();
        for(ContentDocumentLink cdl :[select Id, ContentDocumentId, LinkedEntityId from ContentDocumentLink
                                      where ContentDocumentId in :cdIds ]){
            if(!String.valueOf(cdl.LinkedEntityId).startsWithIgnoreCase('006')) continue;
            if(!mpCDL.containsKey(cdl.LinkedEntityId)) mpCDL.put(cdl.LinkedEntityId, new List<Id>());
            mpCDL.get(cdl.LinkedEntityId).add(cdl.ContentDocumentId);                                  
        }
        
        Boolean flag = true;
        String PROPOSAL_SUBMITTED = 'Proposal Submitted';
        for(Opportunity opp :[select id, Probability, StageName from Opportunity where id in :mpCDL.keySet() and Is_Proposal_Submitted__c = true]){
            if(opp.Probability != null && opp.Probability>50)for(Id cdId : mpCDL.get(opp.Id)){
                if(!profileName.equalsIgnoreCase('System Administrator')){
                    Trigger.oldMap.get(cdId).addError('Please contact to your system administrator to delete this file.');
                    flag = false;
                }
            }   
        }
        
        if(flag){
            Set<Id> oppIds = new  Set<Id>(mpCDL.keySet());
            System.debug(':::oppIds'+ oppIds);
            if(!oppIds.isEmpty()){
                ContentDocumentTriggerHandler.lockOpportunity(oppIds);
            }
        }
    }   
    
    /*
    if(Trigger.isAfter){
        Set<Id> oppIds = new  Set<Id>();
        Set<Id> cdIds = new  Set<Id>(Trigger.oldMap.keySet());
        for(ContentDocumentLink cdl :[select Id, ContentDocumentId, LinkedEntityId from ContentDocumentLink
                                      where ContentDocumentId in :cdIds ]){
            if(!String.valueOf(cdl.LinkedEntityId).startsWithIgnoreCase('006')) continue;
            oppIds.add(cdl.LinkedEntityId);
        }
        System.debug(':::oppIds'+ oppIds);
        if(!oppIds.isEmpty())DrEvidenceUtil.lockOpportunity(oppIds);
    }
    */
}