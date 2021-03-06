/********************************************************************************************************
*    Name:  OpportunityAll.trigger
*    Author: OMNIVO DIGITAL (www.omnivodigital.com)
*    Date:  9/24/2018
*    
*    Handler class: OpportunityAllHandler.cls
*    Test class: OpportunityAllHandlerTest.cls
********************************************************************************************************/

trigger OpportunityAll on Opportunity (before insert, before update, after insert, after update, before delete, after delete) {
    
    if(system.isFuture()){
    	return;    
    } 

    OpportunityAllHandler handler = new OpportunityAllHandler();
    
    if (Trigger.isInsert) {
        if (Trigger.isBefore)
            handler.onBeforeInsert(Trigger.New, Trigger.NewMap ) ;
            
        if (Trigger.isAfter) 
            handler.onAfterInsert(Trigger.New, Trigger.NewMap);
    }
    
    if (Trigger.isUpdate) {
        if (Trigger.isBefore)
            handler.onBeforeUpdate(Trigger.New, Trigger.NewMap, Trigger.oldMap);
        
        if (Trigger.isAfter)
            handler.onAfterUpdate(Trigger.New, Trigger.NewMap , Trigger.oldMap);
    }

    /*if (Trigger.isDelete) {
        if (Trigger.isBefore)
            handler.onBeforeDelete(Trigger.Old, Trigger.oldMap);
        
        if (Trigger.isAfter)
            handler.onAfterDelete(Trigger.Old, Trigger.oldMap );
    }*/

}