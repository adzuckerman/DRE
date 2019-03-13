/*   Name:          TogglToSalesforceTest
 *   Developer:     OMNIVO DIGITAL (www.omnivodigital.com)
 *   Date:          4/23/2018
 *   Description:   Test class for Toggle to Salesforce API integration.
 *                
 */

@isTest
public with sharing class TogglToSalesforceTest {

    @testSetup
    public static void init() { 
    }

    @isTest
    public static void testTimeEntryReceive() {
        Toggl_Custom_Log__c testCustomLog = new Toggl_Custom_Log__c(
            URL__c = 'http://test.ts/error'
        );

        insert testCustomLog;
        Test.setCreatedDate(testCustomLog.Id, Datetime.now().addDays(-100));

        Test.startTest();
        Test.setMock(HttpCalloutMock.class.class, new TogglToSalesforceMock(''));
        Database.executeBatch(new TogglToSalesforceBatch(365, Date.today(), Date.today().addDays(-365)), 1);
        Test.stopTest();

        List<Account> accounts = [SELECT Id, Name FROM Account];
        List<Toggl_Time_Entry__c> timeEnrtries = [SELECT Id FROM Toggl_Time_Entry__c];
        List<Toggl_Custom_Log__c> customLogs = [SELECT Id FROM Toggl_Custom_Log__c];

        System.assertEquals(2, accounts.size(), 'Accounts weren\'t created');
        System.assertEquals(4, timeEnrtries.size(), 'Time Entries weren\'t created');
        System.assertEquals(0, customLogs.size(), 'Logs are not empty'); 
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