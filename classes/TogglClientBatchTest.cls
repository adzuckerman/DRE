/********************************************************************************************************
*    Handler class: TogglClientBatchTest.cls
*    Author:  
*    Date:  9/5/2018
*    
*    Test class: TogglClientBatch.cls
*    Mock Class: HTTPMockClientCallout.cls
********************************************************************************************************/

@isTest
public class TogglClientBatchTest {

    private static testmethod void testTogglClientBatch(){
        Account acc = new Account();
        acc.Name = 'Test Acc';
        insert acc;
         // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new HTTPMockClientInsertCallout());
        // from the class that implements HttpCalloutMock. 
        TogglClientBatch d = new TogglClientBatch(); 
        database.executebatch(d, 1);
        
        
        
    }
}