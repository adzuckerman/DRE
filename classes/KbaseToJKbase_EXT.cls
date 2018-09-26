public class KbaseToJKbase_EXT {

    public Kbase__c kbase {get; set;}    
    public Id caseId;
    public boolean foundExisting {get;set;}
    public string kBaseRefId {get;set;}
    public boolean searched {get;set;}
    
    private Id existingKbaseId;
    
   	public KbaseToJKbase_EXT(ApexPages.StandardController stdController) {			
    	this.kbase = (Kbase__c)stdController.getRecord();
        this.caseId = ApexPages.currentPage().getParameters().get('caseId');
        this.foundExisting = false;
        this.searched = false;
	}
    
    
    public pageReference KbaseToJKbase() {
        try {
        	Junction_Kbase__c jKbase = new Junction_Kbase__c(Name = 'LEAVE', Case__c=caseId);
            if(!this.foundExisting){ 
            	insert this.kbase;      
				jKbase.Kbases__c = this.kbase.Id;                 
            }
        	else{
            	jKbase.Kbases__c = existingKbaseId;                 
        	}
			
            system.debug(jKbase);
            insert jKbase;
            PageReference pg = new PageReference('/' + jKbase.Id);
			return pg;
        }
        catch(System.DmlException e) {
            system.debug('KbaseToJKbase Exception---' + e.getMessage());
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
    }
    
    public void searchKbase(){       
        this.kBaseRefId = this.kBaseRefId.trim();
        List<Kbase__c> kBaseList = [SELECT Id,Name,Extraction_Quantity__c,Extraction_Task_Description__c FROM Kbase__c WHERE Name like :this.kBaseRefId];
        if(!kBaseList.isEmpty()){
            this.existingKbaseId = kBaseList[0].Id;
            this.kbase = kBaseList[0];
            this.foundExisting = true;
	        this.searched = true;            
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, 'Found existing Kbase with entered Ref Id.  New Junction Kbase will be associated with the existing Kbase.'));
        }
        else{
			this.kBase = new Kbase__c();
            this.kBase.Name = kBaseRefId;
            this.foundExisting = false;
	        this.searched = true;            
			ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, 'No existing Kbase found.  A new KBase will be created and the new Junction Kbase associated with it.'));            
        }
    }
}