/********************************************************************************************************
*    Batch class: ProcessInstanceStepBatch.cls
*    Author:  
*    Date:  6/8/2017
*    
*    Test class:  ProcessInstanceStepBatchTest.cls
*    Scheduled class: ProcessInstanceStepScheduler.cls
********************************************************************************************************/

global class ProcessInstanceStepBatch implements Database.Batchable <SObject> {

    global Database.QueryLocator start(Database.BatchableContext bc){
        Set<String> stepStatusValues = new Set<String>{'Pending'};
        
        //String Query = 'SELECT SELECT Id, NodeStatus, ProcessInstanceId, ProcessInstance.TargetObjectId FROM processinstancenode WHERE nodeStatus IN: stepStatusValues';
        String Query='SELECT ActorId, StepStatus, Actor.Name, Actor.Email, ProcessInstanceId, ProcessInstance.TargetObjectId, ProcessInstance.Status from ProcessInstanceStep WHERE ProcessInstance.Status IN: stepStatusValues';
        return Database.getQueryLocator(Query);
    }

    global void execute(Database.BatchableContext bc, List<ProcessInstanceStep> scope){
        
        //EmailTemplate emailTemplate = [SELECT Id, Body FROM EmailTemplate WHERE DeveloperName = 'Pending_Process'];
        
        Set<Id> ProcessInstanceIds = new Set<Id>();
        for(ProcessInstanceStep  p: scope)
        {
            ProcessInstanceIds.add(p.ProcessInstanceId);
        }
        
        Map<Id, ProcessInstance> ProcessInstanceMap = new Map<Id, ProcessInstance>([SELECT Id, TargetObjectId FROM ProcessInstance WHERE Id IN: ProcessInstanceIds]);
        Map<Id, Id> ProcessInstanceToTargetObj = new Map<Id, Id>();
        for(Id myId: ProcessInstanceMap.keySet()){
            processInstanceToTargetObj.put(myId, processInstanceMap.get(myId).TargetObjectId);
        }
        Map<Id, Preferred_Vendor_Request__c> TargetObjIdToPVR = new Map<Id, Preferred_Vendor_Request__c>(
            [SELECT Id, PICO_ID__c, PICO_ID__r.Name, PICO_ID__r.TASKRAY__trAccount__r.Id, PICO_ID__r.TASKRAY__trAccount__r.Name, 
             PICO_ID__r.TASKRAY__trOpportunity__c, PICO_ID__r.Opportunity_ID__c, PICO_ID__r.TASKRAY__trOpportunity__r.Id , 
             PICO_ID__r.TASKRAY__trOpportunity__r.Name, Preferred_Vendor__c, Preferred_Vendor__r.Name, Total_Estimated_Fees__c, 
             AdobeSign_Total_Estimated_Fees__c, Reason_s_for_Outsourcing__c, Project_Due_Date__c 
             FROM Preferred_Vendor_Request__c 
             WHERE Id IN: processInstanceToTargetObj.values()]);
        system.debug('processInstanceToObject---' + TargetObjIdToPVR);
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        string BaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        String oPrefix = Preferred_Vendor_Request__c.sobjecttype.getDescribe().getKeyPrefix();
        
        for(ProcessInstanceStep  p: scope)
        {
            ProcessInstance pi = ProcessInstanceMap.get(p.ProcessInstanceId);
            String sPrefix = String.valueOf(pi.TargetObjectId);            
            if(oPrefix == sPrefix.substring(0, 3) && !String.isEmpty(p.Actor.Email)) 
            {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[] {p.Actor.Email});
                email.setSaveAsActivity(false);
                email.setTargetObjectId(p.ActorId);
                //email.setTemplateId(emailTemplate.Id);
                email.Subject = 'Preferred Vendor Request - Pending Approval';
                email.setHtmlBody('<p>This <a href="' + BaseURL + '/' + pi.TargetObjectId + '" >record</a> needs your review.</p>' + 
                                  'PICO ID: <a href="' + BaseURL + '/' + TargetObjIdToPVR.get(processInstanceToTargetObj.get(pi.Id)).PICO_ID__c + '">' + TargetObjIdToPVR.get(processInstanceToTargetObj.get(pi.Id)).PICO_ID__r.Name + '</a><br/>' + 
                                  'Client Name: <a href="' + BaseURL + '/' + TargetObjIdToPVR.get(processInstanceToTargetObj.get(pi.Id)).PICO_ID__r.TASKRAY__trAccount__r.Id + '">' + TargetObjIdToPVR.get(processInstanceToTargetObj.get(pi.Id)).PICO_ID__r.TASKRAY__trAccount__r.Name + '</a><br/>' +
                                  'SFID: <a href="' + BaseURL + '/' + TargetObjIdToPVR.get(processInstanceToTargetObj.get(pi.Id)).PICO_ID__r.TASKRAY__trOpportunity__c + '">' + TargetObjIdToPVR.get(processInstanceToTargetObj.get(pi.Id)).PICO_ID__r.Opportunity_ID__c + '</a><br/>' + 	
                                  'Opportunity Name: <a href="' + BaseURL + '/' + TargetObjIdToPVR.get(processInstanceToTargetObj.get(pi.Id)).PICO_ID__r.TASKRAY__trOpportunity__r.Id + '">' + TargetObjIdToPVR.get(processInstanceToTargetObj.get(pi.Id)).PICO_ID__r.TASKRAY__trOpportunity__r.Name + '</a><br/>' + 
                                  'Preferred Vendor: <a href="' + BaseURL + '/' + TargetObjIdToPVR.get(processInstanceToTargetObj.get(pi.Id)).Preferred_Vendor__c + '">' + TargetObjIdToPVR.get(processInstanceToTargetObj.get(pi.Id)).Preferred_Vendor__r.Name + '</a><br/>' + 
                                  'Total Estimated Fees: ' + TargetObjIdToPVR.get(processInstanceToTargetObj.get(pi.Id)).AdobeSign_Total_Estimated_Fees__c + '<br/>' +
                                  'Reason(s) for Outsourcing: ' + TargetObjIdToPVR.get(processInstanceToTargetObj.get(pi.Id)).Reason_s_for_Outsourcing__c + '<br/>' +
                    			  'Project Due Date: ' + TargetObjIdToPVR.get(processInstanceToTargetObj.get(pi.Id)).Project_Due_Date__c);
                mails.add(email);
                //Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            }
        }
        if(!Test.isRunningTest())
            Messaging.sendEmail(mails);
        
    }

    global void finish(Database.BatchableContext bc){
        
    }
}