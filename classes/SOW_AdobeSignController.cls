public with sharing class SOW_AdobeSignController 
{
    public Boolean showError {get; set;}
    public Boolean redirectToUrl {get; set;}
    public String recordId {get; set;}

	public SOW_AdobeSignController(ApexPages.StandardController stdController) 
    {
        showError = false;
        redirectToUrl = false;

		recordId = ((Preferred_Vendor_Request__c)stdController.getRecord()).Id;

        List<Preferred_Vendor_Request__c> prefVendorRequestList =
            [
                SELECT Id, Status__c, PO_Number__c 
                FROM Preferred_Vendor_Request__c 
                WHERE Id = :recordId
            ];

        if(prefVendorRequestList.size() > 0)
        {
            if(prefVendorRequestList[0].Status__c == 'Approved' && prefVendorRequestList[0].PO_Number__c != null)
            {
                redirectToUrl = true;
            }
            else 
            {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, Label.SOW_ErrorMessage);
                ApexPages.addMessage(msg);
                showError = true;
            }
        }
        else
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, Label.NoRecordsFound);
            ApexPages.addMessage(msg);
            showError = true;
        }
	}

    public PageReference RedirectToUrl()
    {
        if(redirectToUrl == true && showError == false)
        {
            String url = '/apex/echosign_dev1__AgreementTemplateProcess?masterId=' + recordId + '&templateId=a2A0f000017slz5';
            PageReference retURL = new PageReference(url);
            retURL.setRedirect(true);
            return retURL;
        }
        
        return null;
    }

    public PageReference GoBack()
    {
        return new PageReference('/' + recordId);  
    }
}