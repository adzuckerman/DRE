public class projectToRequest_EXT {

    private static Project_Request__c request;
    
    public projectToRequest_EXT(ApexPages.StandardController sc){
    	Id requestId = sc.getId();
        string requestQuery = OmnivoUtilities.getCreatableFieldsSOQL('Project_Request__c', 'Id =:requestId LIMIT 1');
        request = database.query(requestQuery);
    }
    
    public static pageReference convertRequestToProject(){
        
        //error checking blocks
        //check if project records have already been created
        if(request.Project_Record_Created__c){
            Apexpages.addMessage(new ApexPages.message(apexpages.Severity.ERROR,'The TaskRay project record has already been generated for this project request. Click back on your browser to return to the record or request the Sytem Adminstrator reset the request.') );
            return null;
        }
        
        //Get TaskRay Project Record Types
        Schema.DescribeSObjectResult projectR = TASKRAY__Project__c.SObjectType.getDescribe();
        Map<String, Schema.RecordTypeInfo> projectRTMap = projectR.getRecordTypeInfosByName();
        
        Savepoint sp = Database.setSavepoint();

        try {
           	//Create TaskRay Project
            TASKRAY__Project__c project = new TASKRAY__Project__c();
            project.RecordTypeId = projectRTMap.get('Project').getRecordTypeId();
            project.Name = request.Project_Name__c;
            project.Secondary_Project_Name__c = request.Secondary_Project_Name__c;
            project.Working_Group__c = request.Working_Group__c;
            //project.Workstream__c = request.Workstream__c;
            project.TASKRAY__trOpportunity__c = request.Opportunity__c;
            project.Client_Services_Rep__c = request.Associate_Account_Director__c;
            project.Project_Type__c = request.Project_Type__c;
            project.Principal_Scientist__c = request.Principal_Consultant__c;
            project.Priority_Grade__c = request.Priority_Grade__c;
            project.Methodology_Question_Type__c = request.Methodology_Question_Type__c;
            project.Question__c = request.Question__c;
            project.Population__c = request.Population__c;
            project.Intervention__c = request.Intervention__c;
            project.Comparison__c = request.Comparison__c;
            project.Outcome__c = request.Outcome__c;
            project.Problem__c = request.Problem__c;
            project.Solution__c = request.Solution__c;
            project.Value__c = request.Value__c;
            project.Contact_Name__c = request.Requester_Contact__c;
            project.TASKRAY__trAccount__c = [SELECT Id, Name FROM Account WHERE Name = 'Sanofi' LIMIT 1].Id;
            project.Better_Inform_Clinical_Development__c = request.Better_Inform_Clinical_Development__c;
            project.Corporate_Image__c = request.Corporate_Image__c;
            project.Improved_Clinical_Trial_Success_Rates__c = request.Improved_Clinical_Trial_Success_Rates__c;
            project.Initiate_Because_of_DRE_Training__c = request.Initiate_Because_of_DRE_Training__c;
            project.Intended_Stakeholder__c = request.Intended_Stakeholder__c;
            project.Longer_Product_Lifetime__c = request.Longer_Product_Lifetime__c;
            project.Medical_Empowerment__c = request.Medical_Empowerment__c;
            project.Medical_Value_Description__c = request.Medical_Value_Description__c;
            project.More_Appropriate_Access__c = request.More_Appropriate_Access__c;
            project.More_Appropriate_Pricing__c = request.More_Appropriate_Pricing__c;
            project.Number_of_Trainings__c = request.Number_of_Trainings__c;
            project.Outputs_Description__c = request.Outputs_Description__c;
            project.Patient_Experience__c = request.Patient_Experience__c;
            project.Product_Claim__c = request.Product_Claim__c;
            project.Product_Monitoring__c = request.Product_Monitoring__c;
            project.Project_Objectives__c = request.Project_Objectives__c;
            project.Project_Stakes__c = request.Project_Stakes__c;
            project.Requested_Meeting_Time__c = request.Requested_Meeting_Time__c;
            project.Requester_Email__c = request.Requester_Email__c;
            project.Deliverable_Deadline_Date__c = request.Required_By_Date__c;
            project.Scientific_Communications__c = request.Scientific_Communications__c;
            project.Contact_Name__c = request.Requester_Contact__c;
            insert project;
        
            request.TaskRay_Project__c = project.Id;
            request.Project_Record_Created__c = true;
            update request;
        } catch(DmlException e) {
            Apexpages.addMessage(new ApexPages.message(apexpages.Severity.ERROR, e.getMessage() ) );
            Database.rollback(sp);
            return null;
        }
        
        return new PageReference('/' + request.Id);
    }
}