/********************************************************************************************************
*    Name:  TASKRAYProjectAll.trigger
*    Author:  
*    Date:  8/20/2018
*    
*    Handler class: TASKRAYProjectAllHandler.cls
*    Test class: TASKRAYProjectAllHandlerTest.cls
********************************************************************************************************/

trigger TASKRAYProjectAll on TASKRAY__Project__c (before insert, before update, after insert, after update, before delete, after delete) {
    
    TASKRAYProjectAllHandler handler = new TASKRAYProjectAllHandler();
    
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