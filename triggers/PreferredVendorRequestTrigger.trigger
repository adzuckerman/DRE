trigger PreferredVendorRequestTrigger on Preferred_Vendor_Request__c (after insert, after update) {

    if (Trigger.isInsert && Trigger.isAfter) {
        PreferredVendorRequestHandler.SubmitAdobeSign(Trigger.new, null);
    }
    if (Trigger.isUpdate && Trigger.isAfter) {
        PreferredVendorRequestHandler.SubmitAdobeSign(Trigger.new, Trigger.oldMap);
    }
    
}