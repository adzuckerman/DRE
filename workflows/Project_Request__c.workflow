<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_PC_Team_to_Review_Modify_Project_Request_Upon_Submission</fullName>
        <ccEmails>kphan@doctorevidence.com</ccEmails>
        <ccEmails>rkoretoff@doctorevidence.com</ccEmails>
        <description>Email PC Team to Review / Modify Project Request Upon Submission</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Email_PC_Team_to_Review_Project_Request</template>
    </alerts>
    <rules>
        <fullName>Email PC Team to Review %2F Modify Project Request Upon Submission</fullName>
        <actions>
            <name>Email_PC_Team_to_Review_Modify_Project_Request_Upon_Submission</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Project_Request__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Email PC Team to Review / Modify Project Request Upon Submission</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
