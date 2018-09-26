/********************************************************************************************************
*    Name:  AccountAll.trigger
*    Author:  
*    Date: 9/4/2018
*    
*    Handler class: AccountAllHandler.cls
*    Test class: AccountAllHandlerTest.cls
********************************************************************************************************/

trigger AccountAll on Account(before insert, before update, after insert, after update, before delete, after delete) {
    
    AccountAllHandler handler = new AccountAllHandler();
    
    if (Trigger.isInsert) {
        //if (Trigger.isBefore)
            //handler.onBeforeInsert(Trigger.New, Trigger.NewMap );
            
        if (Trigger.isAfter) 
            handler.onAfterInsert(Trigger.New, Trigger.NewMap);
    }
    
    /*if (Trigger.isUpdate) {
        if (Trigger.isBefore)
            handler.onBeforeUpdate(Trigger.New, Trigger.NewMap, Trigger.oldMap);
        
        if (Trigger.isAfter)
            handler.onAfterUpdate(Trigger.New, Trigger.NewMap , Trigger.oldMap);
    }

    if (Trigger.isDelete) {
        if (Trigger.isBefore)
            handler.onBeforeDelete(Trigger.Old, Trigger.oldMap);
        
        if (Trigger.isAfter)
            handler.onAfterDelete(Trigger.Old, Trigger.oldMap );
    }*/

}