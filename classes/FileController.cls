public class FileController {

    @AuraEnabled
    public static String saveTheFile(String parentId, Boolean isPropsalDocument, String fileName, String base64Data, String contentType) { 
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');//urlDecode
        ContentVersion cv = new ContentVersion();
        cv.Title = fileName;
        cv.VersionData = EncodingUtil.base64Decode(base64Data);//base64Decode
        cv.pathOnClient = '/' + fileName ;
        cv.Is_a_Proposal__c = isPropsalDocument;
        insert cv;
        
        ContentVersion cvObj = [select ContentDocumentId from ContentVersion where Id= :cv.Id];
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = parentId;
        cdl.ContentDocumentId = cvObj.ContentDocumentId;
        cdl.ShareType = 'I';
        //cdl.Visibility = 'InternalUsers';
        insert cdl;
        
        if(isPropsalDocument == true){
            Opportunity opp = new Opportunity(
                Is_Proposal_Submitted__c = true,
                Id = parentId
            );
            update opp;
        }
        
        return cv.Id;
    }
    
    @AuraEnabled
    public static String saveTheChunk(String parentId, Boolean isPropsalDocument, String fileName, String base64Data, String contentType, String fileId) { 
        if (fileId == '') {
            fileId = saveTheFile(parentId, isPropsalDocument, fileName, base64Data, contentType);
        } else {
            appendToFile(fileId, base64Data);
        }
        
        return Id.valueOf(fileId);
    }
    
    private static void appendToFile(String fileId, String base64Data) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        ContentVersion cv = [
            SELECT Id, VersionData
            FROM ContentVersion
            WHERE Id = :fileId
        ];
        
        String existingBody = EncodingUtil.base64Encode(cv.VersionData);
        cv.VersionData = EncodingUtil.base64Decode(existingBody + base64Data); 
        
        update cv;
    }
    
    @AuraEnabled
    public static List<FileWrapper> getFileList(String parentId){
        List<FileWrapper> lstFiles = new List<FileWrapper>();
        
        Map<Id, Id> mpCDL = new Map<Id, Id>();
        for(ContentDocumentLink cdl :[select Id, ContentDocumentId, LinkedEntityId from ContentDocumentLink
                                      where LinkedEntityId= :parentId]){
            mpCDL.put(cdl.ContentDocumentId, cdl.LinkedEntityId);                                  
        }
        
        for(ContentVersion cv :[ SELECT Id, Title, Is_a_Proposal__c, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId in :mpCDL.keySet() and isDeleted=False and isLatest=true]){
            FileWrapper fw = new FileWrapper();
            fw.contentDocumentId = cv.ContentDocumentId;
            fw.contentVersionId = cv.Id;
            fw.parentId = mpCDL.get(cv.ContentDocumentId);
            fw.title = cv.Title;
            fw.is_Proposal_Document = cv.Is_a_Proposal__c;
            
            lstFiles.add(fw);
        }
        
        return lstFiles;    
    }
}