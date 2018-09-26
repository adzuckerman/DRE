public class ClientFeedbackRequestedBtn {

    private final TASKRAY__Project__c TASKRAYproj;
    private List<TASKRAY__Project__c> currentTASKRAYProject;

    public ClientFeedbackRequestedBtn(ApexPages.StandardController stdController) {
        this.TASKRAYproj = (TASKRAY__Project__c)stdController.getRecord();
        currentTASKRAYProject = [SELECT Id, Contact_Name__c, Contact_Name__r.Id, Client_Feedback_Requested__c FROM TASKRAY__Project__c WHERE Id =: TASKRAYproj.Id LIMIT 1];   
    }

    public void SendEmail() {
        
        //List<TASKRAY__Project__c> currentTASKRAYProject = [SELECT Id, Client_Feedback_Requested__c FROM TASKRAY__Project__c WHERE Id =: currentProjectRequest[0].TaskRay_Project__c LIMIT 1];
        List<RME_Value_Framework_Email_Settings__mdt> RMEValueFramework = [SELECT Template_Unique_Name__c FROM RME_Value_Framework_Email_Settings__mdt WHERE Label = 'Client Feedback Requested' LIMIT 1];
        if( RMEValueFramework.size() == 1 )
        {
            String templateUniqueName = RMEValueFramework[0].Template_Unique_Name__c;
            List<EmailTemplate> emailtemplateList = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: templateUniqueName ];
    
            if(currentTASKRAYProject.size() > 0 /*&& currentTASKRAYProject[0].Client_Feedback_Requested__c == false*/ && currentTASKRAYProject.size() > 0 && currentTASKRAYProject[0].Contact_Name__c != null && emailtemplateList.size() > 0)
            { 
                try {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
                    mail.setSenderDisplayName('Test Response to Client Request');         
                    mail.setTargetObjectId(currentTASKRAYProject[0].Contact_Name__c);
                    mail.setWhatId(currentTASKRAYProject[0].Id);
                    mail.setTemplateId(emailtemplateList[0].Id);
                    if(!Test.isRunningTest())
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
                } catch(exception ex) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
                    ApexPages.addMessage(myMsg);  
                    
                }
                
                try {
                    currentTASKRAYProject[0].Client_Feedback_Requested__c = true;
                    currentTASKRAYProject[0].Client_Feedback_Requested_Date__c = Date.Today();
                    update currentTASKRAYProject;
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Email was successfully sent!');
                    ApexPages.addMessage(myMsg);
                } catch(dmlexception e) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
                    ApexPages.addMessage(myMsg);
                }
            }
        }
    }
    
    public PageReference BackToTRProject() {
        PageReference pageRef = new PageReference('/' + TASKRAYproj.Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
}