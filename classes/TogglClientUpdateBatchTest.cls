/********************************************************************************************************
*    Handler class: TogglClientUpdateBatchTest.cls
*    Author:  
*    Date:  9/5/2018
*    
*    Test class: TogglClientUpdateBatch.cls
*    Mock Class: HTTPMockClientCallout.cls
********************************************************************************************************/

@isTest
public class TogglClientUpdateBatchTest {

    private static testmethod void testTogglClientUpdateBatch(){
        Account acc = new Account();
        acc.Name = 'Very Big Company';
        insert acc;
         // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new HTTPMockClientInsertCallout());
        // from the class that implements HttpCalloutMock. 
        TogglClientUpdateBatch d = new TogglClientUpdateBatch(); 
        database.executebatch(d, 1);
        
        
        
    }
}