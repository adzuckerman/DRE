/**********************************************************
 * Class 	 	: PowerBIController.cls
 * Test Class 	: PowerBIController_TEST.cls
 * Created Date	: January 4, 2018
 * Modified by 	: -
 * Modified Date: -
 * Objective 	: -
 *
 *
 **********************************************************/ 

public class PowerBIController extends OAuthController {
    @TestVisible private static String APPLICATION_NAME = 'PowerBI';
	public String reportId {get;set;}
    public String groupId {get;set;}

    public PowerBIController () {
		List<PowerBI_Report__mdt> powerBIReports = [Select Id, Application_Name__c, ReportId__c, GroupId__c from PowerBI_Report__mdt];

		if(powerBIReports != null && powerBIReports.size() > 0){
			this.application_name = powerBIReports.get(0).Application_Name__c;
			this.reportId = powerBIReports.get(0).ReportId__c;
            this.groupId = powerBIReports.get(0).GroupId__c;
		}

        
    }
    
    public String getValidateResult()
    {
        return validateResult;
    }

    /**
    * Validates the callback code and generates the access and refresh tokens
    *
    * @return null to refresh the page
    */
    public PageReference redirectOnCallback() {
        return super.redirectOnCallback(null);
    }
    
    public PageReference refreshAccessToken() {
        return super.refreshAccessToken(ApexPages.currentPage());
    }
}