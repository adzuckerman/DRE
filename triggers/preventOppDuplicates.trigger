trigger preventOppDuplicates on Opportunity (before insert) {
    
String triggerName = 'preventOppDuplicates'; //helper string for custom setting
    
Map<String, TriggerToggles__c> triggerToggleSettings = TriggerToggles__c.getAll();
    
if(triggerToggleSettings.keySet().contains(triggerName) && triggerToggleSettings.get(triggerName).Active__c == TRUE){
    
    //Initialize unique set of opportunity names
    Set<String> oppNameSet = new Set<String>();
    
    //Create a set of opportunity names checking dupes and if dupe throw error 
    for (Opportunity opp : Trigger.new) {
        if ( !oppNameSet.contains(opp.Name) ) {
            oppNameSet.add(Opp.Name);
        }
        else {
            opp.adderror('Opportunity already exists in your Organization with name '+opp.Name);
        }
    }
    
    //Get list of duplicate opportunity names comparing database and set
    List<Opportunity> oppDatabaseDupeList = new List<Opportunity>( [SELECT Id, Name 
                                                                    FROM Opportunity 
                                                                    WHERE Name IN: oppNameSet] );
    
    //If there are duplicates comparing database and set opportunity names loop oppDatabaseDupeList
    //and throw error
    //
    //Trigger.New
    Map<String, Opportunity> mapOppsNew = new Map<String, Opportunity>();
    for (Opportunity opp: Trigger.New) {
        mapOppsNew.put(opp.Name, opp);
    }
    system.debug(mapOppsNew);
    if ( oppDatabaseDupeList.size() > 0 ) {
        for (Opportunity opp: oppDatabaseDupeList) {
            //system.debug(Trigger.newMap);
            //system.debug(opp.Id);
            //system.debug(Trigger.newMap.get(opp.Id));
            mapOppsNew.get(opp.Name).adderror('Opportunity already exists in your Organization with name ' +opp.Name);
            //opp.adderror('Opportunity already exists in your Organization with name '+opp.Name);
        }
    }
}
}