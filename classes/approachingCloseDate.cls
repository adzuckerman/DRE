/*   Name:          Batch Approaching Close Date Emails
 *   Developer:     Adam Zuckerman - CLOUD MINE CONSULTING
 *   Date:          February 2017
 *   Description:   Batch APEX to send emails for Opportunities within one week of close date.
 * 
 * 	 Updates:               
 */

global class approachingCloseDate implements Database.Batchable<sObject> {

	global Database.querylocator start(Database.BatchableContext BC){
    	string query = 'SELECT Id, Name, CloseDate, Owner.Email, isClosed FROM Opportunity WHERE isClosed = FALSE AND StageName != \'Sales Plan\' AND CloseDate <= ' + string.valueOf(date.today().addDays(7));    
		return Database.getQueryLocator(query);
    }

	global Map<String, Contact> dummyContactMap = new Map<String, Contact>();
    global void execute(Database.BatchableContext BC, List<Opportunity> scope){	
		
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
		List<EmailTemplate> queryTemplate = new List<EmailTemplate>( [SELECT Id, Name, isActive 
                                                                      FROM EmailTemplate 
                                                                      WHERE Name = 'Close Date Within One Week'] );

        for (Opportunity opp: scope) {
        	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            //List<String> toAddresses = new List<String>();
            //toAddresses.add(opp.Owner.Email);
            //mail.setToAddresses( toAddresses );
			mail.setReplyTo('ahinojosa@doctorevidence.com');
			mail.setSenderDisplayName('Salesforce Auto Notification');
            mail.saveAsActivity = false;
            if (queryTemplate[0].Id != NULL && queryTemplate[0].isActive) {
                if(!dummyContactMap.containsKey(opp.Owner.Email)){
                	Contact dummyContact = new Contact(LastName='Last', Email=opp.Owner.Email);
                	insert dummyContact;
                    dummyContactMap.put(opp.Owner.Email, dummyContact);
                	mail.setTargetObjectId(dummyContact.Id);                    
                }
                else{
                	mail.setTargetObjectId(dummyContactMap.get(opp.Owner.Email).Id);                    
                }
                mail.setTemplateId(queryTemplate[0].Id);                
                mail.setWhatId(opp.Id);                
            }
            else {
            	opp.adderror('Email template Close Date Within One Week has been deleted, renamed, or is inactive.');    
            }
            emailList.add(mail);
		}        
		Messaging.sendEmail(emailList);  
    	delete dummyContactMap.values();        
	}
	
    global void finish(Database.BatchableContext BC){        
	}
}