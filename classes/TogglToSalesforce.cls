/*   Name:          TogglToSalesforce
 *   Developer:     CLOUD MINE CONSULTING
 *   Date:          4/23/2018
 *   Description:   Toggl to Salesforce callout class.
 *                
 */

public with sharing class TogglToSalesforce {

    public String apiUrl = 'https://www.toggl.com/api/v8';
    public String apiReporstsUrl = 'https://www.toggl.com/reports/api/v2';
    public TogglAPIAuth authenticator;

    private final String WORKSPACE_ID;
    private final String NEW_USER_PROFILE_NAME;

    public TogglToSalesforce() {
        try {
            this.authenticator = new TogglAPIAuth();
            this.WORKSPACE_ID = this.authenticator.workspaceId;
            this.NEW_USER_PROFILE_NAME = this.authenticator.newUserProfileName;
        } catch (RequiredFeatureMissingException e) {
            System.debug(e.getMessage());
        }
    }

    public void getTimeEntriesLastNDays(Integer page, Integer days) {
        Date until = Date.today();
        Date since = until.addDays(-days);
        String untilString = Datetime.newInstance(until.year(), until.month(), until.day()).format('YYYY-MM-d');
        String sinceString = Datetime.newInstance(since.year(), since.month(), since.day()).format('YYYY-MM-d');

        String requestUrl = this.apiReporstsUrl + '/details?workspace_id=' + this.WORKSPACE_ID + '&user_agent=' + this.authenticator.username
            + '&since=' + sinceString + '&until=' + untilString + '&page=' + String.valueOf(page);
        HttpResponse resp = this.invokeCallout(requestUrl, '', 'GET', new Map<String, String>());

        if (resp.getStatusCode() == 400) {
            resp = this.invokeCallout(requestUrl, '', 'GET', new Map<String, String>());

            if (resp.getStatusCode() == 400) {
                List<Toggl_Custom_Log__c> sameLogs = [SELECT Id FROM Toggl_Custom_Log__c WHERE URL__c = :requestUrl];

                if (sameLogs.isEmpty()) {
                    Toggl_Custom_Log__c customLog = new Toggl_Custom_Log__c(
                        URL__c = requestUrl
                    );
                    insert customLog;
                }
                return;
            }
        }

        ReportDetailsWrapper reportDetails = (ReportDetailsWrapper) JSON.deserialize(resp.getBody(), ReportDetailsWrapper.class);

        this.handleTimeEntries(reportDetails, new List<Toggl_Custom_Log__c>());
    }

    public void getFailedTimeEntry(String url) {
        HttpResponse resp = this.invokeCallout(url, '', 'GET', new Map<String, String>());

        if (resp.getStatusCode() == 400) {
            resp = this.invokeCallout(url, '', 'GET', new Map<String, String>());

            if (resp.getStatusCode() == 400) {
                return;
            }
        }

        List<Toggl_Custom_Log__c> logsToDelete = [SELECT Id FROM Toggl_Custom_Log__c WHERE URL__c = :url];

        ReportDetailsWrapper reportDetails = (ReportDetailsWrapper) JSON.deserialize(resp.getBody(), ReportDetailsWrapper.class);
        this.handleTimeEntries(reportDetails, logsToDelete);
    }

    private void handleTimeEntries(ReportDetailsWrapper reportDetails, List<Toggl_Custom_Log__c> logsToDelete) {
        List<Profile> profiles = [SELECT Id, Name FROM Profile WHERE Name = :this.NEW_USER_PROFILE_NAME];
        if (profiles.isEmpty()) {
            throw new RequiredFeatureMissingException('There is no required profile on the org');
        }
        Id newUserProfileId = profiles[0].Id;
        HttpResponse resp = this.invokeCallout(this.apiUrl + '/workspaces/' + this.WORKSPACE_ID + '/workspace_users', '', 'GET', new Map<String, String>());
        List<UserWrapper> workspaceUsers = (List<UserWrapper>) JSON.deserialize(resp.getBody(), List<UserWrapper>.class);
        Map<Integer, UserWrapper> userWrappers = new Map<Integer, UserWrapper>();
        Map<String, Integer> userEmails = new Map<String, Integer>();
        for (UserWrapper userDetails : workspaceUsers) {
            userWrappers.put(userDetails.uid, userDetails);
            userEmails.put(userDetails.email, userDetails.uid);
        }

        List<Toggl_Time_Entry__c> timeEnriesToCreate = new List<Toggl_Time_Entry__c>();
        Map<String, User> usersToCreate = new Map<String, User>();
        Map<String, Account> accountsToCreate = new Map<String, Account>();
        Map<String, TASKRAY__Project__c> TASKRAYProjectsMap = new Map<String, TASKRAY__Project__c>();
        Map<String, Opportunity> TASKRAYProjectsOpps = new Map<String, Opportunity>();
        Map<String, Opportunity> OpportunityMap = new Map<String, Opportunity>();
        
        Map<Integer, Integer> timeEntryToCid = new Map<Integer, Integer>();
        for(TimeEntryWrapper timeEntry : reportDetails.data) {
            if (timeEntry.client != null && timeEntry.client != '') {
                accountsToCreate.put(timeEntry.client, null);
                // taskray project names map
                //TASKRAYProjectsMap.put(timeEntry.project, null); 
                //TASKRAYProjectsStageMap.put(timeEntry.project, '');
                
                String projectName = timeEntry.project;
                string oppId = null;
                if(projectName.contains('|'))
                {
                    String[] pName = projectName.split('\\|');
                    string firstPart = pName[0].trim();
                    projectName = firstPart;//pName[1].trim();
                    if (firstPart.length() >= 3) {
                        if (firstPart.startsWith('SF') && firstPart.substring(2).isNumeric()) {
                            oppId = firstPart;
                        }
                    }
                }
                if (oppId != null) {
                    OpportunityMap.put(oppId, null);
                }
                TASKRAYProjectsMap.put(projectName, null); 
                TASKRAYProjectsOpps.put(projectName, null);
            }
        }

        System.debug('TASKRAYProjectsMap 1 ====> ' + TASKRAYProjectsMap);
        // get existing TASKRAY Projects and related opportunities
        List<TASKRAY__Project__c> existingTASKRAYProjects = [SELECT Id, Name, Client_Delivered_Date__c, TASKRAY__trOpportunity__r.First_non_NA_Invoice_Date__c, TASKRAY__trOpportunity__c, 
        															TASKRAY__trOpportunity__r.StageName, TASKRAY__trOpportunity__r.CloseDate, POC__c
        														FROM TASKRAY__Project__c WHERE Name IN: TASKRAYProjectsMap.keySet()];
        for (TASKRAY__Project__c existingProject : existingTASKRAYProjects) {
            TASKRAYProjectsMap.put(existingProject.Name, existingProject);
            TASKRAYProjectsOpps.put(existingProject.Name, existingProject.TASKRAY__trOpportunity__r);
        }
        
        List<User> existingUsers = [SELECT Id, FirstName, LastName, Email FROM User WHERE Email IN :userEmails.keySet()];
        for (User existingUser : existingUsers) {
            usersToCreate.put(String.valueOf(userEmails.get(existingUser.Email)), existingUser);
        }
        
        for (Opportunity opp : [SELECT Opportunity_ID__c, StageName, CloseDate FROM Opportunity WHERE Opportunity_ID__c IN :OpportunityMap.keyset()]) {
            OpportunityMap.put(opp.Opportunity_ID__c, opp);
        }

        System.debug(timeEntryToCid);
        List<Account> existingAccounts = [SELECT Id, Name, Toggl_ID__c FROM Account WHERE Name IN :accountsToCreate.keySet()];
        for (Account existingAccount : existingAccounts) {
            accountsToCreate.put(existingAccount.Name, existingAccount);
        }

        for(TimeEntryWrapper timeEntry : reportDetails.data) {
            if (timeEntry.client != null && timeEntry.client != '') {
                if (accountsToCreate.get(timeEntry.client) == null) {
                    accountsToCreate.put(timeEntry.client, new Account(
                        Toggl_ID__c = String.valueOf(timeEntryToCid.get(timeEntry.id)),
                        Name = timeEntry.client
                    ));
                }
                if (!usersToCreate.containsKey(String.valueOf(timeEntry.uid))) {
                    String alias;
                    if (userWrappers.get(timeEntry.uid).name.length() > 8) {
                        alias = userWrappers.get(timeEntry.uid).name.substring(0, 7);
                    } else {
                        alias = userWrappers.get(timeEntry.uid).name;
                    }
                    System.debug('User Email---' + userWrappers.get(timeEntry.uid).email);
                    
                    usersToCreate.put(String.valueOf(timeEntry.uid),
                        new User(
                            LastName = userWrappers.get(timeEntry.uid).name,
                            Email = userWrappers.get(timeEntry.uid).email,
                            ProfileId = newUserProfileId,
                            IsActive = false,
                            Username = userWrappers.get(timeEntry.uid).email, //UserInfo.getUserName().substringAfterLast('.com') == null ? userWrappers.get(timeEntry.uid).email : userWrappers.get(timeEntry.uid).email + '.' + UserInfo.getUserName().substringAfterLast('.com'),
                            Alias = alias,
                            CommunityNickname = userWrappers.get(timeEntry.uid).email, //UserInfo.getUserName().substringAfterLast('.com') == null ? userWrappers.get(timeEntry.uid).email : userWrappers.get(timeEntry.uid).email + '.' + UserInfo.getUserName().substringAfterLast('.com'),
                            Department = 'Department',
                            Division = 'Division', 
                            Title = 'Title',
                            TimeZoneSidKey = 'GMT',
                            LocaleSidKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LanguageLocaleKey = 'en_US'
                        )
                    );
                }
            }
        }
        System.debug('Account to create---' + accountsToCreate.values());
        System.debug('Users to create---' + usersToCreate.values());
        System.debug(Database.upsert(accountsToCreate.values()));
        List<User> usersInsert = new List<User>();
        for (User u : usersToCreate.values()) {
            if (u.Id == null) {
                usersInsert.add(u);
            }
        }
        System.debug(Database.upsert(usersInsert));

        for (TimeEntryWrapper timeEntry : reportDetails.data) {
            if (timeEntry.client != null && timeEntry.client != '') {
                System.debug('timeEntry ====> ' + timeEntry);
                // set GAAP_Class__c field
                String projectName = timeEntry.project;
                String projectName2 = null;
                string oppId = null;
                if(projectName.contains('|'))
                {
                    String[] pName = projectName.split('\\|');
                    string firstPart = pName[0].trim();
                    projectName = firstPart;
                    projectName2 = pName[1].trim();
                    if (firstPart.length() >= 3) {
                        if (firstPart.startsWith('SF') && firstPart.substring(2).isNumeric()) {
                            oppId = firstPart;
                        }
                    }
                }
                String accountName = timeEntry.client;
                String opportunityStageName = '';
                Date opportunityCloseDate = null;
                    
                if (TASKRAYProjectsOpps.containsKey(projectName) && TASKRAYProjectsOpps.get(projectName) != null) {
                    opportunityStageName = TASKRAYProjectsOpps.get(projectName).StageName;
                    opportunityCloseDate = TASKRAYProjectsOpps.get(projectName).CloseDate;
                }
                
                if (oppId != null && OpportunityMap.containsKey(oppId) && OpportunityMap.get(oppId) != null) {
                    opportunityStageName = OpportunityMap.get(oppId).StageName;
                    opportunityCloseDate = OpportunityMap.get(oppId).CloseDate;
                }
                
                Boolean notPOC = false;
                if(TASKRAYProjectsMap.containsKey(projectName)) {
                    notPOC = true;
                	TASKRAY__Project__c trp = TASKRAYProjectsMap.get(projectName);
                    if (trp == null) {
                        notPOC = false;
                    } else {
                        if (trp.POC__c != 'Not POC')
                            notPOC = false;
                        if (trp.Client_Delivered_Date__c == null)
                            notPOC = false;
                        if (trp.TASKRAY__trOpportunity__r.First_non_NA_Invoice_Date__c == null)
                            notPOC = false;
                        else if (timeEntry.start > trp.TASKRAY__trOpportunity__r.First_non_NA_Invoice_Date__c)
                            notPOC = false;
                    }
                }
                
                String GAAPClass = GetGAAPClass(projectName, projectName2, accountName, opportunityStageName, opportunityCloseDate, timeEntry.start == null ? null : timeEntry.start.date(), notPOC);
                
                Id projectId = null;
                Id opportunityId = null;
                if(TASKRAYProjectsMap.containsKey(projectName))
                {
                    TASKRAY__Project__c trp = TASKRAYProjectsMap.get(projectName);
                    if(trp != null)
                    {
                        projectId = TASKRAYProjectsMap.get(projectName).Id;
                        opportunityId = TASKRAYProjectsMap.get(projectName).TASKRAY__trOpportunity__c;
                    }
                    
                }
                if (oppId != null && OpportunityMap.containsKey(oppId) && OpportunityMap.get(oppId) != null) {
                    opportunityId = OpportunityMap.get(oppId).Id;
                }
                
                timeEnriesToCreate.add(new Toggl_Time_Entry__c(
                    Billable__c = timeEntry.is_billable,
                    Description__c = timeEntry.description,
                    Start_Date__c = timeEntry.start,
                    End_Date__c = timeEntry.start.addSeconds(timeEntry.dur/1000),
                    Toggl_Id__c = String.valueOf(timeEntry.id),
                    Tags__c = String.join(timeEntry.tags, ','),
                    Account__c = accountsToCreate.get(timeEntry.client).Id,
                    Project_Name__c = timeEntry.project,
                    Project__c = projectId,
                    Opportunity__c = opportunityId,
                    GAAP_Class__c = GAAPClass,
                    User__c = usersToCreate.get(String.valueOf(timeEntry.uid)).Id,
                    Duration__c = timeEntry.dur
                ));
            }
        }

        for(Toggl_Time_Entry__c e : timeEnriesToCreate) {
            System.debug(e);
        }
        Schema.SObjectField f = Toggl_Time_Entry__c.Fields.Toggl_Id__c;
        System.debug(Database.upsert(timeEnriesToCreate, f));
        System.debug(Database.delete(logsToDelete));
    }
    
    public static string GetGAAPClass(string projectName, string projectName2, string accountName, string opportunityStageName, Date opportunityCloseDate, Date timeEntryStartDate, boolean notPOC) {
        
        if (notPOC) {
        	return 'Work in Progress';
        } else {
	        String taskrayType = '';
	        string GAAPClass = '';
	        
	        if(!String.isEmpty(projectName) && !String.isEmpty(accountName))
	        {
	            if(projectName.contains('-'))
	            {
	                String[] splitProject = projectName.split('-');
	                if(splitProject.size() == 3 && splitProject[2] != null && splitProject[2] != '')
	                {
	                    if(splitProject[2].length() == 3) taskrayType = 'PICO ID';
	                    if(splitProject[2].length() == 4) taskrayType = 'Contract ID';
	                }
	            }
	            
	            if (projectName.length() >= 3) {
	                if (projectName.startsWith('SF') && projectName.substring(2).isNumeric()) {
	                    taskrayType = 'SFID';
	                }
	            }
	            
	            if(accountName != 'Doctor Evidence' && accountName != 'DRE Tech')
	            {
	                if (taskrayType == 'SFID' && projectName2 == 'Pre-Sale') {
	                    GAAPClass = 'Sales & Marketing';
	                } 
	                else if (taskrayType == 'PICO ID' && projectName.startsWith('DRE') && opportunityStageName == 'Closed Won') {
	                	GAAPClass = 'Sales & Marketing';
	                }
	                else if(taskrayType == 'Contract ID' || taskrayType == 'PICO ID' || taskRayType == 'SFID' || projectName == 'Doc Label' || projectName == 'Data Hub')
	                {
	                    if (!String.isEmpty(opportunityStageName)) {
	                        if(opportunityStageName != 'Closed Won' && opportunityStageName != 'Closed Lost') 
	                            GAAPClass = 'Work In Progress';  
	                        if(opportunityStageName == 'Closed Won') {
	                            if (opportunityCloseDate != null && timeEntryStartDate != null) {
	                                if (timeEntryStartDate < opportunityCloseDate) {
	                                    GAAPClass = 'Work In Progress';
	                                } else {
	                                    GAAPClass = 'Cost of Revenue';
	                                }
	                            } else {
	                            	GAAPClass = 'Cost of Revenue';
	                            }
	                        }
	                        if(opportunityStageName == 'Closed Lost') 
	                            if (opportunityCloseDate != null && timeEntryStartDate != null) {
	                                if (timeEntryStartDate < opportunityCloseDate) {
	                                    GAAPClass = 'Work In Progress';
	                                } else {
	                                    GAAPClass = 'Sales & Marketing';
	                                }
	                            } else {
	                            	GAAPClass = 'Sales & Marketing';
	                            }
	                    }
	                }
	                else if (projectName == 'Pre-Sale') {
	                    GAAPClass = 'Sales & Marketing';
	                }
	            } else {
	                if(accountName == 'Doctor Evidence')
	                {
	                    if (projectName == 'CE Admin/Internal' || projectName == 'CS Admin/Internal') {
	                        GAAPClass = 'Sales & Marketing';
	                    } else if (projectName == 'Admin/Internal' && (projectName2 == 'Tech Issues' || projectName2 == 'Audit')) {
	                    	GAAPClass = 'Research & Development';
	                    } else if (projectName == 'Guidelines/GROWTH' && opportunityStageName == 'Closed Won') {
	                    	GAAPClass = 'Sales & Marketing';
	                    } else if (projectName == 'Patient Project' && opportunityStageName == 'Closed Won') {
	                    	GAAPClass = 'Sales & Marketing';
	                    } else { 
	                        GAAPClass = 'General & Administrative'; 
	                    }
	                } else {
	                    if(accountName == 'DRE Tech')
	                    {
	                        if(projectName == 'Admin/Internal' || projectName == 'Platform Maintenance') {
	                            GAAPClass = 'Research & Development';
	                        } else { 
	                            GAAPClass = '2.0 Cap'; 
	                        }
	                    }
	                }
	            }
	        }
	        
	        return GAAPClass;
        }
    }

    public Integer getTimeEntryCount(Integer days, Date untilDate, Date sinceDate) {
        Date until = Date.today();
        if(untilDate != null)
            until = untilDate;
        Date since = until.addDays(-days);
        if(sinceDate != null)
            since = sinceDate;
        String untilString = Datetime.newInstance(until.year(), until.month(), until.day()).format('YYYY-MM-d');
        String sinceString = Datetime.newInstance(since.year(), since.month(), since.day()).format('YYYY-MM-d');

        HttpResponse resp = this.invokeCallout(this.apiReporstsUrl + '/details?workspace_id=' + this.WORKSPACE_ID + '&user_agent=' + this.authenticator.username + '&since=' + sinceString + '&until=' + untilString, '', 'GET', new Map<String, String>());
        system.debug('Response---' + resp.getBody());
        ReportDetailsWrapper detailWrapper = (ReportDetailsWrapper) JSON.deserialize(resp.getBody(), ReportDetailsWrapper.class);
        return detailWrapper.total_count;
    }

    public HttpResponse invokeCallout(String endpoint, String body, String method, Map<String, String> headers) {
        HttpRequest request = new HttpRequest();
        System.debug('--- endpoint: ' + endpoint);
        request.setEndpoint(endpoint);
        request.setMethod(method);
        request.setTimeout(20000);
        if (String.isNotBlank(body)) {
            request.setBody(body);
        }
        request.setHeader('Authorization', this.authenticator.authToken);
        request.setHeader('Content-Type', 'application/json');
        System.debug('--- Authorization header: ' + this.authenticator.authToken);
        if (!headers.isEmpty()) {
            for(String headerName : headers.keySet()) {
                request.setHeader(headerName, headers.get(headerName));
            }
        }
        Http http = new Http();
        HttpResponse response = http.send(request);
        System.debug(response.getBody());
        return response;
    }

    private class TogglAPIAuth {

        public String authToken {get; set;}
        public String username {get; set;}
        public String workspaceId {get; set;}
        public String newUserProfileName {get; set;}

        private ToggleAccount__mdt toggleCreds;
        private String password;
        private String apiToken {get; set;}

        public TogglAPIAuth() {
            List<ToggleAccount__mdt> creds = [SELECT Username__c, Password__c, API_Token__c, Workspace_ID__c, New_User_Profile_Name__c FROM ToggleAccount__mdt];
            if (creds.isEmpty()) {
                throw new RequiredFeatureMissingException('Please add Toggle credentials in custom metadata');
            }
            this.toggleCreds = creds[0];
            this.username = this.toggleCreds.Username__c;
            this.password = this.toggleCreds.Password__c;
            this.authToken = this.toggleCreds.API_Token__c;
            this.workspaceId = this.toggleCreds.Workspace_ID__c;
            this.newUserProfileName = this.toggleCreds.New_User_Profile_Name__c;

            this.prepareAuthToken();
        }

        private void prepareAuthToken() {
            String tokenString = this.authToken + ':api_token';
            Blob blobToken = Blob.valueOf(tokenString);
            tokenString = EncodingUtil.base64Encode(blobToken);
            tokenString = 'Basic ' + tokenString;
            this.authToken = tokenString;
        }
    }

    public class ReportDetailsWrapper {
        public Integer total_count;
        public Integer per_page;
        public List<TimeEntryWrapper> data;
    }

    public class TimeEntryWrapper {
        public Integer id;
        public Integer pid;
        public Integer tid;
        public Integer uid;
        public String description;
        public Datetime start;
        public Datetime endTime;
        public String project;
        public Integer dur;
        public String user;
        public String client;
        public Boolean is_billable;
        public Decimal billable;
        public List<String> tags;
    }

    private class ProjectWrapper {
        public Integer id;
        public Integer cid;
        public String name;
        public Boolean billable;
        public Boolean active;
    }

    private class UserWrapper {
        public Integer id;
        public Integer uid;
        public Boolean active;
        public String email;
        public String name;
    }

}