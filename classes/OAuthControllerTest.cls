/**********************************************************
 * Class 	 	: OAuthControllerTest.cls
 * Created Date	: January 4, 2018
 * Modified by 	: -
 * Modified Date: -
 * Objective 	: This class provide test methods for OAuthController.cls
 *
 *
 **********************************************************/ 

@isTest
public class OAuthControllerTest {
	
	public static PageReference pageRef = Page.Report;
	public static OAuthApp_pbi__c app;
	public static OAuthController controller = new OAuthController();
	public static Power_BI__c powerBI = new Power_BI__c();
	
	@testSetup public static void setUp()
	{	
		app = new OAuthApp_pbi__c();
		app.Name = 'PowerBI2';
		app.Token_Expires_On__c = '0';
		app.Client_Id__c = 'clientId';
		app.Client_Secret__c = 'clientSecret';
		app.Authorization_URL__c = 'https://login.windows.net/common/oauth2/authorize';
		app.Access_Token_URL__c = 'https://login.microsoftonline.com/common/oauth2/token';
		app.Resource_URI__c = 'https://analysis.windows.net/powerbi/api';
		insert app;

		powerBI.Application_Name__c = 'PowerBI';
		powerBI.GroupId__c = 'effbcea2-08fd-4157-bfc9';
		powerBI.ReportId__c = '3b10f269-9505';
		insert powerBI;

		controller.application_name = 'PowerBI2';
	}
	
	public static testMethod void test1()
	{		
		System.assertNotEquals(controller, null);		
		System.assertNotEquals(controller.PBIAccess_token, null);
		System.assertNotEquals(controller.PBIRefresh_token, null);
		System.assertNotEquals(controller.PBIExpires_on, null);	
		System.assertEquals(controller.getHasToken(), false);
		
		controller.PBIAccess_token =  'testToken';
		System.assertEquals(controller.getHasToken(), false);	

		Test.setCurrentPage(pageRef);
		String authUrl = controller.getAuthUrl();
		
		System.assertEquals(authUrl.contains('https://login.windows.net/common/oauth2/authorize?'), true);
	}   
	
	public static testMethod void redirectOnCallbackCreatesCookies()
	{	
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		
		Test.setCurrentPage(pageRef);
		String authUrl = controller.getAuthUrl();
		
		System.assertEquals(authUrl.contains('https://login.windows.net/common/oauth2/authorize?'), true);

		pageRef = new PageReference('https://c.eu11.visual.force.com/apex/Report?code=testCode');
		Test.setCurrentPage(pageRef);
		controller.isCallback = true;
		controller.currentReportSFId = 'a1i1k000000DJq0';

		PageReference ref = controller.redirectOnCallback(pageRef);
		
		String accessCookie = controller.PBIAccess_token;
		String refreshCookie =  controller.PBIRefresh_token;
		
		System.assertEquals('accessCookieToken',accessCookie);
		System.assertEquals('refreshCookieToken',refreshCookie);
		Test.stopTest();
	}

    public static testMethod void refreshToken()
	{	
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		
		Test.setCurrentPage(pageRef);
		String authUrl = controller.getAuthUrl();
		
		System.assertEquals(authUrl.contains('https://login.windows.net/common/oauth2/authorize?'), true);

		pageRef = new PageReference('https://c.eu11.visual.force.com/apex/Report?code=testCode');
		Test.setCurrentPage(pageRef);
		controller.isCallback = true;

		controller.refreshAccessToken(pageRef);
		
		String accessCookie = controller.PBIAccess_token;
		String refreshCookie =  controller.PBIRefresh_token;
		
		System.assertEquals('accessCookieToken',accessCookie);
		System.assertEquals('refreshCookieToken',refreshCookie);
		Test.stopTest();
	}
}