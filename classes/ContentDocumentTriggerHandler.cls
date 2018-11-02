public class ContentDocumentTriggerHandler{
    @Future
    public static void lockOpportunity(Set<Id> oppIds){
        Map<Id, List<Id>> mpCDL = new Map<Id, List<Id>>();
        Set<Id> oppIdsN = new  Set<Id>(oppIds);
        for(ContentDocumentLink cdl :[select Id, ContentDocumentId, LinkedEntityId from ContentDocumentLink
                                      where LinkedEntityId in :oppIdsN]){
            if(!mpCDL.containsKey(cdl.ContentDocumentId)){ mpCDL.put(cdl.ContentDocumentId, new List<Id>());} mpCDL.get(cdl.ContentDocumentId).add(cdl.LinkedEntityId);                                  
        }
        
        Set<Id> cdIds = new  Set<Id>(mpCDL.keySet()); 
        Boolean flag = true;
        for(ContentVersion cv :[ SELECT Id, Is_a_Proposal__c, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId in :cdIds
                                and isDeleted=False and isLatest=true and Is_a_Proposal__c=true]){
            if(mpCDL.containsKey(cv.ContentDocumentId)) mpCDL.remove(cv.ContentDocumentId); flag = false;
        }
        
        Set<Id> oppIdsForUnlock = new  Set<Id>(); 
        for(Id cdId :mpCDL.keySet()){ oppIdsForUnlock.addAll(mpCDL.get(cdId)); }
        
        if(mpCDL.isEmpty() && flag == true) oppIdsForUnlock.addAll(oppIds);
        List<Opportunity> lstOpp = [select Is_Proposal_Submitted__c, Record_Locked__c from Opportunity where Id in :oppIdsForUnlock
                    and Is_Proposal_Submitted__c =true];  
                    
        for(Opportunity opp :lstOpp){ opp.Is_Proposal_Submitted__c = false; } 
        
        update lstOpp;
 
    }
 
}