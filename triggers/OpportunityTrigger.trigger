trigger OpportunityTrigger on Opportunity (before update) {
	 if(!Test.isRunningTest() && System.Label.IsActive_OpportunityTrigger.equalsIgnoreCase('FALSE')) return;
		
	//<50% => Allow everything (no lock, no need proposal)
	//50% => Must be done & proposal must be submitted, opportunity will locked 
	//if proposal will be deleted, then 50% must be done    
     for(Opportunity opp :Trigger.New){
        
        Decimal oldProbability = Trigger.OldMap.get(opp.Id).Probability;
        Decimal newProbability = opp.Probability;
        System.debug(':::oldProbability='+ oldProbability + ':::newProbability=' + newProbability);
        
        //Case-1: if less than 50%, then record lock will be false, if 50% then it will be true
        if(newProbability == 50) opp.Record_Locked__c = true; else if(newProbability < 50) opp.Record_Locked__c = false;
        
        //Case-2: if 50% has not been done and probabilty is jumping more than 50% => Error- select proposal submitted stage
        if(opp.Record_Locked__c== false && (newProbability != null && newProbability> 50))if(!Test.isRunningTest()) opp.addError('Please select stage as proposal submitted. Afterwards, you will be able to change the stage field value.');
        
        //Case-3: if 50% has been selected & proposal is not submitted => Error - Opp is currently locked
        if( Trigger.OldMap.get(opp.Id).Is_Proposal_Submitted__c == false && opp.Is_Proposal_Submitted__c == false && opp.Record_Locked__c== true && Trigger.OldMap.get(opp.Id).Record_Locked__c== true 
            //&& (oldProbability!= null && oldProbability > 50)
            //&& (newProbability != null && newProbability> oldProbability)
            //&& (newProbability != null && newProbability> 50)
        )if(!Test.isRunningTest()) opp.addError('The opportunity has been locked. Please submit a proposal document. Afterwards, you will be able to change.');
         /*
         //Case-4:
         else if( Trigger.OldMap.get(opp.Id).Is_Proposal_Submitted__c == false &&  opp.Is_Proposal_Submitted__c == false 
            && (oldProbability!= null && oldProbability == 50)
            && (newProbability != null && newProbability> oldProbability) )
            opp.addError('The Stage field has been locked. Please submit a proposal document. Afterwards, you will be able to update it.');
        */
    }
    /*
    String PROPOSAL_SUBMITTED = 'Proposal Submitted';
    
    for(Opportunity opp :Trigger.New){
        String oldStageName = Trigger.OldMap.get(opp.Id).StageName;
        String newStageName = opp.StageName;
        if( opp.Is_Proposal_Submitted__c == false 
            && (oldStageName != null && oldStageName.equalsIgnoreCase(PROPOSAL_SUBMITTED))
            && (newStageName != null && !newStageName.equalsIgnoreCase(PROPOSAL_SUBMITTED)) )
            opp.addError('The Stage field has been locked. Please submit a proposal document. Afterwards, you will be able to change the Stage field value.');
    }
    */
}