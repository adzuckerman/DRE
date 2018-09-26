@isTest(SeeAllData=true)
public class RHX_TEST_TASKRAY_Project {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM TASKRAY__Project__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new TASKRAY__Project__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}