public class PreferredVendorRequestHandler {

    public static void SubmitAdobeSign(List<Preferred_Vendor_Request__c> newList, Map<Id, Preferred_Vendor_Request__c> oldMap) {
        
        AdobeSign_template__mdt setting = [SELECT Template_Id__c FROM AdobeSign_template__mdt LIMIT 1];
            
        for (Preferred_Vendor_Request__c newRecord : newList) {
            if (newRecord.Status__c == 'Approved' && (oldMap == null || oldMap.get(newRecord.Id).Status__c != 'Approved') && !newRecord.Do_Not_Auto_Send_SOW__c) {
        		Id agreementId = echosign_dev1.AgreementTemplateService.load(setting.Template_Id__c, newRecord.Id);
                echosign_dev1.EchoSignApiService.sendDocument(agreementId);
            }
        }
    }
    
}