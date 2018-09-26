/********************************************************************************************************
*    Name:  PreferredVendorAll.trigger
*    Author:  
*    Date:  6/13/2018
*    
*    Handler class: PreferredVendorAllHandler.cls
*    Test class: PreferredVendorAllHandlerTest.cls
********************************************************************************************************/

trigger PreferredVendorAll on Preferred_Vendor__c  (before insert, before update, after insert, after update, before delete, after delete) {
    
    PreferredVendorAllHandler handler = new PreferredVendorAllHandler();
    
    /*if (Trigger.isInsert) {
        if (Trigger.isBefore)
            handler.onBeforeInsert(Trigger.New, Trigger.NewMap ) ;
            
        if (Trigger.isAfter) 
            handler.onAfterInsert(Trigger.New, Trigger.NewMap);
    }*/
    
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