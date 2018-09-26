trigger ProjectRequestTrigger on Project_Request__c (after insert) {

    if (Trigger.isInsert && Trigger.isAfter) {
        ProjectRequestHandler.matchContact(Trigger.New);
    }
    
}