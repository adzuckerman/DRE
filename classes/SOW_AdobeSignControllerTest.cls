@isTest
private class SOW_AdobeSignControllerTest 
{	
	@isTest static void test_method_one() 
    {
        // Data Setup
        TASKRAY__Project__c taskRayProject = new TASKRAY__Project__c();
        insert taskRayProject;

        Preferred_Vendor__c prefVendor = new Preferred_Vendor__c();
        prefVendor.Name = 'testName';
        insert prefVendor;

        Preferred_Vendor_Request__c prefVendorRequest = new Preferred_Vendor_Request__c();
        prefVendorRequest.PICO_ID__c = taskRayProject.Id;
        prefVendorRequest.Preferred_Vendor__c = prefVendor.Id;
        insert prefVendorRequest;

        ApexPages.StandardController sc = new ApexPages.StandardController(prefVendorRequest);

		// Run Code
        SOW_AdobeSignController ctrl = new SOW_AdobeSignController(sc);

        ctrl.redirectToUrl = true;
        ctrl.showError = false;
        ctrl.RedirectToUrl();
	}
}