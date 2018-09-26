/*   Name:          TogglToSalesforceSchedulable
 *   Developer:     CLOUD MINE CONSULTING
 *   Date:          4/23/2018
 *   Description:   Scheduled APEX to make batch callout to Toggl
 *                
 */

global class TogglToSalesforceSchedulable implements Schedulable {

    global void execute(SchedulableContext sc) {
        TogglToSalesforceBatch batch = new TogglToSalesforceBatch();
        Database.executeBatch(batch, 1);
    }

}