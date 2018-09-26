/**********************************************************
 * Class 	 	: ReportController_TEST.cls
 * Created Date	: January 13, 2018
 * Modified by 	: -
 * Modified Date: -
 * Objective 	: This class provide test methods for ReportController.cls
 *
 *
 **********************************************************/ 

@isTest 
private class ReportController_TEST {

	public static PageReference pageRef = Page.Report;

	@isTest
	private static void testName() {
		OAuthApp_pbi__c app = new OAuthApp_pbi__c();
		app.Name = 'PowerBI2';
		app.Token_Expires_On__c = '0';
		app.Client_Id__c = 'clientId';
		app.Client_Secret__c = 'clientSecret';
		app.Authorization_URL__c = 'https://login.windows.net/common/oauth2/authorize';
		app.Access_Token_URL__c = 'https://login.microsoftonline.com/common/oauth2/token';
		app.Resource_URI__c = 'https://analysis.windows.net/powerbi/api';
		insert app;

		Power_BI__c powerBI = new Power_BI__c();
		powerBI.Application_Name__c = 'PowerBI';
		powerBI.GroupId__c = 'effbcea2-08fd-4157-bfc9';
		powerBI.ReportId__c = '3b10f269-9505';
		insert powerBI;

		ApexPages.StandardController sc = new ApexPages.StandardController(powerBI);
        ReportController controller = new ReportController(sc);
		controller.validateResult = 'testResult';
		String validate = controller.getValidateResult();
		System.assertEquals('testResult', controller.getValidateResult());

		Test.startTest();
			Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		
			controller.application_name = 'PowerBI2';
			Test.setCurrentPage(pageRef);		

			PageReference page = controller.refreshAccessToken();
				
			String accessCookie = controller.PBIAccess_token;
			String refreshCookie =  controller.PBIRefresh_token;
		
			System.assertEquals('accessCookieToken',accessCookie);
			System.assertEquals('refreshCookieToken',refreshCookie);	
		Test.stopTest();
	}
}