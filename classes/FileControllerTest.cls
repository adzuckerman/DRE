@isTest
private class FileControllerTest {

    public static testmethod void unitTest(){
        
        //insert Account - start
        Account acct = new Account(
            Name = 'Test account'
        );
        insert acct;
        //insert account - end
        
        //insert opportunity - start
        Opportunity opp = new Opportunity(
            Name = 'testopp', 
            CloseDate = date.today(), 
            AccountId =acct.Id,
            StageName = 'Prospecting'
        );
        insert opp; 
        //insert opportunity - end
        
        //String as an example
        string tempString = 'TheBlogReaders.com';
        // converting from string to blob
        Blob tempBlob = Blob.valueOf(tempString);
        
        // convert base64 encode from the blob
        string paramvalue = EncodingUtil.base64Encode(tempBlob);
        
        //calling saveTheChunk method
        String fileId = FileController.saveTheChunk(opp.Id, true, 'fileName.csv', paramvalue, 'csv', '');
        //calling the saveTheChunk method by using File Id
        FileController.saveTheChunk(opp.Id, true, 'fileName.csv', paramvalue, 'csv', fileId);
    }
}