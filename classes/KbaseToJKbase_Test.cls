@isTest
public class KbaseToJKbase_Test {

     public static testMethod void testKbaseToJKbase(){
 
        //insert case
        Case c = new Case(Case_Name__c='Case12345');
        insert c;
        
        //set page reference
        //PageReference pageRef = new PageReference('/apex/KbasetoJKbase_EXT/?caseId='+c.Id);
        PageReference pageRef = Page.KbaseToJKbase_EXT;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('caseId', c.Id);
         
        //insert a Kbase
        Kbase__c kb = new Kbase__c(Name='Kbase12345', Extraction_Quantity__c=1, Extraction_Task_Description__c='Text');
        insert kb;
        
        //initialize Kbase for controller extension operations 
        Kbase__c kb2 = new Kbase__c();
                
        //instantiate and run method
        ApexPages.StandardController stdController = new ApexPages.StandardController(kb2);
        KbaseToJKbase_EXT ext = new KbaseToJKbase_EXT(stdController);   
        
        //test search methods
        //found case
        ext.kBaseRefId = 'kbase12345';
        ext.searchKbase();
        system.assertEquals(true, ext.foundExisting);
        //not found case
        ext.kBaseRefId = 'cant find it';
        ext.searchKbase();
        system.assertEquals(false, ext.foundExisting);
         
        //create the Kbase and Junction kbase
        ext.KbaseToJKbase();
        
        //assert that jKbase was created        
        system.debug(ext.caseId);
        List<Junction_Kbase__c> jKbaseList = [SELECT Id FROM Junction_Kbase__c WHERE Case__c =:ext.caseId LIMIT 1];        
        system.assertNotEquals(0, jKbaseList.size());
        
    } 
     
}