/*   Name:          TogglToSalesforceTest
 *   Developer:     CLOUD MINE CONSULTING
 *   Date:          4/23/2018
 *   Description:   Test class for Toggle to Salesforce API integration.
 *                
 */

@isTest
public with sharing class TogglToSalesforceTest {

    

    @isTest
    public static void testTimeEntryReceive() {
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class.class, new TogglToSalesforceMock(''));
        
        Database.executeBatch(new TogglToSalesforceBatch(), 1);
        Test.stopTest();

        List<Account> accounts = [SELECT Id, Name FROM Account];
        List<Toggl_Time_Entry__c> timeEnrtries = [SELECT Id FROM Toggl_Time_Entry__c];

        System.assertEquals(2, accounts.size(), 'Accounts weren\'t created');
        System.assertEquals(4, timeEnrtries.size(), 'Time Entries weren\'t created');
    }
    @isTest
    public static void testSchedule() {
        
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class.class, new TogglToSalesforceMock(''));
        TogglToSalesforceSchedulable schedule = new TogglToSalesforceSchedulable();
        String sch = '0 0 2 * * ?';
        System.schedule('Test Territory Check', sch, schedule);
        Test.stopTest();
    }

}