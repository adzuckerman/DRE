public class ToggleAdminBatchProgress {
    
    public Boolean isRunningBatch {get; set;}
    public Boolean isRunningBatch2 {get; set;}
    public String noOfDays {get; set;}
    
    public Campaign c {get; set;}

    public ToggleAdminBatchProgress() {
        isRunningBatch = false;
        isRunningBatch2 = false;
        c = new Campaign();
    }
    
    public void StartBatch(){
        if(c.StartDate == null || c.EndDate == null)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please specify the date range.');
            ApexPages.addMessage(myMsg);
            return;
        }
        
        if(c.startDate > c.endDate)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Start Date can\'t be higher than End Date.');
            ApexPages.addMessage(myMsg);
            return;
        }
        isRunningBatch = false;
        Id apexClassId1 = [SELECT Id FROM ApexClass WHERE Name = 'TogglToSalesforceBatch'].Id;
        List<AsyncApexJob> aaj1 = [SELECT Id, Status, ApexClassID, ApexClass.Name FROM AsyncApexJob WHERE ApexClassID =: apexClassId1 ORDER BY CreatedDate desc LIMIT 1];
        if(aaj1.size() == 0 || aaj1.size() == 1 && aaj1[0].Status != 'Queued' && aaj1[0].Status != 'InProgress' && aaj1[0].Status != 'Holding'){
             Integer nDays = (c.startDate).daysBetween(c.endDate) + 1;
             TogglToSalesforceBatch tts = new TogglToSalesforceBatch(nDays, c.endDate, c.startDate);
             if(!Test.isRunningTest())
                 Id batchJobId = Database.executeBatch(tts, 1);
        } else {
             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Toggl To Salesforce Batch is already running.');
             ApexPages.addMessage(myMsg);
        } 
    }
    
    public void StartBatch2(){
        isRunningBatch2 = false;
        Id apexClassId2 = [SELECT Id FROM ApexClass WHERE Name = 'TogglTimeEntriesBatch'].Id;
        List<AsyncApexJob> aaj2 = [SELECT Id, Status, ApexClassID, ApexClass.Name FROM AsyncApexJob WHERE ApexClassID =: apexClassId2 ORDER BY CreatedDate desc LIMIT 1];
        if(aaj2.size() == 0 || aaj2.size() == 1 && aaj2[0].Status != 'Queued' && aaj2[0].Status != 'InProgress' && aaj2[0].Status != 'Holding'){
             if(!Test.isRunningTest())
                 Id batchJobId = Database.executeBatch(new TogglTimeEntriesBatch(), 1);
        } else {
             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Toggl Time Entries Batch is already running.');
             ApexPages.addMessage(myMsg);
        } 
    }

}