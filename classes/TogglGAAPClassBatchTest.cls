@isTest
public class TogglGAAPClassBatchTest{
    private static testmethod void testOpportunityAllHandler4(){

        Test.StartTest();
            Test.setMock(HttpCalloutMock.class.class, new TogglToSalesforceMock(''));
            TogglGAAPClassBatch d = new TogglGAAPClassBatch(); 
            database.executebatch(d, 1);
        Test.StopTest();

    }
}