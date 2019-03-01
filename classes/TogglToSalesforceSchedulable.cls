/*   Name:          TogglToSalesforceSchedulable
 *   Developer:     OMNIVO DIGITAL (www.omnivodigital.com)
 *   Date:          4/23/2018
 *   Description:   Scheduled APEX to make batch callout to Toggl
 *                
 */

global class TogglToSalesforceSchedulable implements Schedulable {

    //Get number of days to get Toggl Time Entries from custom metadata.
    List<ToggleAccount__mdt> dayMdt = [SELECT Days__c FROM ToggleAccount__mdt];
    
    global Integer metaDays = Integer.valueOf(dayMdt[0].Days__c);
    global Date until = Date.today();
    global Date since = until.addDays(-metaDays);
    
    global void execute(SchedulableContext sc) {
        TogglToSalesforceBatch batch = new TogglToSalesforceBatch(metaDays, until, since);
        Database.executeBatch(batch, 1);
    }

}