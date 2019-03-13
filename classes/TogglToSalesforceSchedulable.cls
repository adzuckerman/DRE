/*   Name:          TogglToSalesforceSchedulable
 *   Developer:     OMNIVO DIGITAL (www.omnivodigital.com)
 *   Date:          4/23/2018
 *   Description:   Scheduled APEX to make batch callout to Toggl
 *                
 */

global class TogglToSalesforceSchedulable implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        List<ToggleAccount__mdt> dayMdt = [SELECT Days__c FROM ToggleAccount__mdt];
        Integer metaDays = Integer.valueOf(dayMdt[0].Days__c);
    	Date until = Date.today();
    	Date since = until.addDays(-metaDays);
        TogglToSalesforceBatch batch = new TogglToSalesforceBatch(metaDays, until, since);
        Database.executeBatch(batch, 1);
    } 

}