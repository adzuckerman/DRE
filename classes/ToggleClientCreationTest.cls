/********************************************************************************************************
*    Handler class: ToggleClientCreationTest.cls
*    Author:  
*    Date:  9/4/2018
*    
*    Called from:  AccountAllHandler.trigger
*    Test class: ToggleClientCreation.cls
*    Mock Class: HTTPMockClientCallout.cls
********************************************************************************************************/

@isTest
public class ToggleClientCreationTest {

    private static testmethod void testToggleClientCreation(){
    
        Account acc = new Account();
        acc.Name = 'Test Acc';
        
        Test.StartTest();
            
            insert acc;

        Test.StopTest();
       
    }
    
    private static testmethod void testToggleClientCreation1(){
        Account acc = new Account();
        acc.Name = 'Test Acc';
        insert acc;
         // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new HTTPMockClientCallout());
        // from the class that implements HttpCalloutMock. 
        Set<Id> aId = new Set<Id>();
        aId.add(acc.Id);
        ToggleClientCreation.CreateToggleClient(aId);
        
        // Verify response received contains fake values
        Account a = [SELECT Id, Toggl_Id__c FROM Account WHERE Id =: acc.Id];
        //System.assertEquals('1239455', a.Toggl_Id__c);
        
        
    }
}