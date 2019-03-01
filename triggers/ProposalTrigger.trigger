trigger ProposalTrigger on Quote (before insert, before update, after insert, after update, before delete, after delete) {
	
    ProposalHandler handler = new ProposalHandler();
    
    if (Trigger.isUpdate) {
        if (Trigger.isAfter){ 
        	handler.onAfterInsert(Trigger.New, Trigger.NewMap);
    	}
    }
}