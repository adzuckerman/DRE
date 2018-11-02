public class FileWrapper {
    @AuraEnabled public String contentDocumentId{get;set;}
    @AuraEnabled public String contentVersionId{get;set;}
    @AuraEnabled public String parentId{get;set;}
    @AuraEnabled public String title{get;set;}
    @AuraEnabled public Boolean is_Proposal_Document{get;set;}
}