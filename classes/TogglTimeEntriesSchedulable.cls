global class TogglTimeEntriesSchedulable implements Schedulable 
{
	global void execute(SchedulableContext sc) 
    {
		TogglTimeEntriesBatch b = new TogglTimeEntriesBatch();
		Database.executebatch(b, 50);
	}
}