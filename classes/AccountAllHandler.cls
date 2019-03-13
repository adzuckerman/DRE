/********************************************************************************************************
*    Handler class: AccountAllHandler.cls
*    Author:  
*    Date:  9/4/2018
*    
*    Trigger:  AccountAll.trigger
*    Test class: AccountAllHandlerTest.cls
********************************************************************************************************/

public class AccountAllHandler {
    //Handler for before insert methods
    //public void onBeforeInsert(list<Account> newList , map<id, Account> newMap) {}
    
    //Handler for after insert methods
    public void onAfterInsert(list<Account> newList , map<id, Account> newMap) {
        CreateToggleClient(newList, null, newMap, null);
    }
    
    //Handler for before Update methods
    //public void onBeforeUpdate(list<Account> newList, map<id, Account> newMap , map<id, Account> oldMap) {}
    //Handler for after Update methods
    //public void onAfterUpdate(list<Account> newList, map<id, Account> newMap,  map<id, Account> oldMap) {}
    
    //Handler for before Deletes methods
    //public void onBeforeDelete(list<Account> oldList, map<id, Account> oldMap) {}
    //Handler for after Deletes methods
    //public void onAfterDelete(list<Account> oldList , map<id, Account> oldMap) {}
    
    private void CreateToggleClient(list<Account>newList, list<Account>oldList, map<id, Account> newMap, map<id, Account> oldMap) {
        
        if(!System.isBatch() && newList.size() > 0)
        {
            
            // Limit: 10 callouts per transaction
            Map<Integer, Set<Id>> SetsMap = new Map<Integer, Set<Id>>();
            
            Integer i = 0;
            Integer j = 1;
            Set<Id> newSet = new Set<Id>();
            for(Account acc: newList)
            {
                if(String.isBlank(acc.Toggl_Id__c))
                {
					if(i == 0){
						newSet = new Set<Id>();
					}

					if(i <= 10) {
						if(!SetsMap.containsKey(j))
						{
							newSet.add(acc.Id);
							SetsMap.put(j, newSet);
						} else {
							Set<Id> existingSet = SetsMap.get(j);
							existingSet.add(acc.Id);
							SetsMap.put(j, existingSet);
						}
						i++;
					}else{ 
                        j++;
                        i = 0;
                    }
                }
            }//end for
           
		   System.debug('***AccountAllHandler - CreateToggleClient() - SetsMap: ');
		   System.debug(SetsMap);
            
            if(SetsMap.size() > 0)
            {
                for(Integer ii: SetsMap.KeySet())
                {
                    Set<Id> s = SetsMap.get(ii);
                    if(!Test.isRunningTest())
                        ToggleClientCreation.CreateToggleClient(s);

                }//end for
            }
        }
    }
    
    
}