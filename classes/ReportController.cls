/**********************************************************
 * Class 	 	: ReportController.cls
 * Test Class 	: ReportController_TEST.cls
 * Created Date	: January 13, 2018
 * Modified by 	: -
 * Modified Date: -
 * Objective 	: -
 *
 *
 **********************************************************/ 


public class ReportController extends OAuthController {

	private final Power_BI__c currentReport {get;set;}
	public String reportId {get;set;}
    public String groupId {get;set;}

    public ReportController (ApexPages.StandardController stdController) {
		this.currentReport = (Power_BI__c)stdController.getRecord();
		System.debug('***this.currentReport: ' + this.currentReport);
		 
		if(this.currentReport != null && this.currentReport.Id != null) {
			this.currentReportSFId = this.currentReport.Id;
            Cache.Session.put('local.partition1.reportId', this.currentReportSFId);
        } else {
            this.currentReportSFId = (String)Cache.Session.get('local.partition1.reportId');
        }

		Power_BI__c cReport = [Select Id, Name, Application_Name__c, ReportId__c, GroupId__c from Power_BI__c Where Id=: this.currentReportSFId];
		this.application_name = cReport.Application_Name__c;
		this.reportId = cReport.ReportId__c;
		this.groupId = cReport.GroupId__c;
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
    
    public PageReference GoBack() {
        return new PageReference('/' + this.currentReportSFId);
    }
}