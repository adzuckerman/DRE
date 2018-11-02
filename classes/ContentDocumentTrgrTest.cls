@isTest
private class ContentDocumentTrgrTest {
    
    public static testmethod void unitTest(){
        
        //Account - start
        Account acct = new Account(
            Name = 'Account Test'
        );
        insert acct;
        //Account - end
        
        //Opportuntiy - start
        Opportunity opp = new Opportunity(
            Name = 'My Opp Test', 
            AccountId =acct.Id,
            CloseDate = date.today(),  
            StageName = 'Qualification/Prospecting'
        );
        insert opp; 
        //Opportunity - end
        
        //my string
        string tempString = 'Testinng for Docuemnt File';
        
        // converting from String to Blob
        Blob tempBlob = Blob.valueOf(tempString);
        
        // convert base64 encode from the blob
        string blobValue = EncodingUtil.base64Encode(tempBlob);
        
        //calling method of Filecontroller
        String fileId = FileController.saveTheChunk(opp.Id, true, 'testfileName.csv', blobValue, 'csv', '');
        
        //calling method of Filecontroller
        FileController.saveTheChunk(opp.Id, true, 'testfileName.csv', blobValue, 'csv', fileId);
        
        // list calling method of Filecontroller
        FileController.getFileList(opp.Id);
        
        //get the ContentVersion
        ContentVersion cv = [select Id, ContentDocumentId from ContentVersion where Id= :fileId ];
        
        //delete the CV
        delete [select id from ContentDocument where id = :cv.ContentDocumentId];
    }
    
}