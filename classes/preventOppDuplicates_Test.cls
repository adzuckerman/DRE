@isTest
public class preventOppDuplicates_Test {

    public static testMethod void testDupesInBatch(){
        TriggerToggles__c toggle = new TriggerToggles__c(Name='preventOppDuplicates', Active__c = TRUE);
        insert toggle;
        
        Account acct = new Account(Name = 'Test account');
        insert acct;
        Opportunity opp1 = new Opportunity(Name = 'testopp', CloseDate = date.today(), AccountId =acct.Id, StageName = 'Qualification/Prospecting');
        Opportunity opp2 = new Opportunity(Name = 'testopp', CloseDate = date.today(), AccountId =acct.Id, StageName = 'Qualification/Prospecting');
		List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(opp1);
        oppList.add(opp2);
        try{
        	insert oppList;    
        }
        catch(Exception e){
            String errorMsg = e.getMessage();
            system.assert(errorMsg.contains('Opportunity already exists in your Organization'));
        }
        
    }
    
    public static testMethod void testDupesAlreadyExisting(){
        TriggerToggles__c toggle = new TriggerToggles__c(Name='preventOppDuplicates', Active__c = TRUE);
        insert toggle;
        
        Account acct = new Account(Name = 'Test account');
        insert acct;
        Opportunity opp1 = new Opportunity(Name = 'testopp', CloseDate = date.today(), AccountId =acct.Id, StageName = 'Qualification/Prospecting');
        insert opp1;
        Opportunity opp2 = new Opportunity(Name = 'testopp', CloseDate = date.today(), AccountId =acct.Id, StageName = 'Qualification/Prospecting');
        try{
        	insert opp2;    
        }
        catch(Exception e){
            String errorMsg = e.getMessage();
            system.assert(errorMsg.contains('Opportunity already exists in your Organization'));
        }
        
    }   
    
}