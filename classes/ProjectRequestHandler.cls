public class ProjectRequestHandler {

    public static void matchContact(List<Project_Request__c> requestList) {
                
        List<Project_Request__c> updateRequestList = new List<Project_Request__c>();
        updateRequestList = [SELECT Id, Requester_Contact__c, Requester_Name__c, Requester_Email__c FROM Project_Request__c WHERE Id IN:requestList];
        
        List<Contact> contactList = new List<Contact>();
        
        Map<String, Project_Request__c> emailToRequest = New Map<String, Project_Request__c>();
        Map<Id, Contact> requestToContact = New Map<Id, Contact>();
        
        for(Project_Request__c pr: requestList){
            if(pr.Requester_Email__c != null){
            	emailToRequest.put(pr.Requester_Email__c.toLowerCase(), pr);    
            }   
        }
        
        for(Contact c: [SELECT Id, Email, FirstName, LastName FROM Contact WHERE Email IN:emailToRequest.keySet()]){
            	requestToContact.put(emailToRequest.get(c.email).id, c);		        		
        }
        
        Map<Id, Contact> requestToContactInsertMap = new Map<Id, Contact>();
        
        for(Project_Request__c pr: updateRequestList){
            if(requestToContact.get((pr.id))!= NULL){
            	pr.Requester_Contact__c = requestToContact.get(pr.id).id;		       
            }
            else {
                if (pr.Requester_Name__c != null) {
                    Contact c = new Contact(
                        FirstName = pr.Requester_Name__c.split (' ')[0], 
                        LastName = pr.Requester_Name__c.split(' ')[pr.Requester_Name__c.split(' ').size() - 1],
                        Email = pr.Requester_Email__c,
                        AccountId = [SELECT Id, Name FROM Account WHERE Name = 'Sanofi' LIMIT 1].Id,
                        Contact_Type__c = 'Project'
                    );
                    requestToContactInsertMap.put(pr.id,c);
                }
            }		   
        }
        insert requestToContactInsertMap.values();
        
        for(Project_Request__c pr: updateRequestList){
            if(requestToContactInsertMap.get(pr.Id)!= NULL){
                pr.Requester_Contact__c = requestToContactInsertMap.get(pr.Id).id;
            }
        }
        
        update updateRequestList;
    }
}