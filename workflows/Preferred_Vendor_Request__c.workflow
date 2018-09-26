<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Approval_Email_Notification</fullName>
        <ccEmails>projectmanagement@doctorevidence.com</ccEmails>
        <ccEmails>accountspayable@doctorevidence.com</ccEmails>
        <ccEmails>adam@cloudmineconsulting.com</ccEmails>
        <description>Approval Email Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>bob@doctorevidence.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>hkim@doctorevidence.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>mdelaguila@doctorevidence.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>mnewton@doctorevidence.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>DRE_Point_of_Contact__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Approval_Email_Notification</template>
    </alerts>
    <alerts>
        <fullName>Finance_Email_Notification_for_internal_approval</fullName>
        <description>Finance Email Notification – for internal approval</description>
        <protected>false</protected>
        <recipients>
            <field>DRE_Point_of_Contact__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Ops_Science_Finance_Email_Notification_Notice_Only</template>
    </alerts>
    <alerts>
        <fullName>Ops_1_Email_Notification</fullName>
        <ccEmails>projectmanagement@doctorevidence.com</ccEmails>
        <ccEmails>adam@cloudmineconsulting.com</ccEmails>
        <description>Ops 1 Email Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>jpark@doctorevidence.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>DRE_Point_of_Contact__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Ops_Science_Finance_Email_Notification</template>
    </alerts>
    <alerts>
        <fullName>Ops_1_Email_Notification_for_internal_approval</fullName>
        <description>Ops 1 Email Notification – for internal approval</description>
        <protected>false</protected>
        <recipients>
            <field>DRE_Point_of_Contact__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Ops_Science_Finance_Email_Notification_Notice_Only</template>
    </alerts>
    <alerts>
        <fullName>Ops_1_Email_Notification_internal_approval</fullName>
        <ccEmails>projectmanagement@doctorevidence.com</ccEmails>
        <ccEmails>adam@cloudmineconsulting.com</ccEmails>
        <description>Ops 1 Email Notification Internal Approval</description>
        <protected>false</protected>
        <recipients>
            <recipient>jpark@doctorevidence.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>DRE_Point_of_Contact__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Ops_Science_Finance_Email_Notification</template>
    </alerts>
    <alerts>
        <fullName>Ops_2_Email_Notification_for_internal_approval</fullName>
        <description>Ops 2 Email Notification – for internal approval</description>
        <protected>false</protected>
        <recipients>
            <field>DRE_Point_of_Contact__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Ops_Science_Finance_Email_Notification_Notice_Only</template>
    </alerts>
    <alerts>
        <fullName>PO_No_Request_Notication</fullName>
        <ccEmails>finance@doctorevidence.com</ccEmails>
        <description>PO No. Request Notication</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/PO_Requested_Email_Notification</template>
    </alerts>
    <alerts>
        <fullName>Rejection_Email_Notification</fullName>
        <ccEmails>projectmanagement@doctorevidence.com</ccEmails>
        <ccEmails>adam@cloudmineconsulting.com</ccEmails>
        <description>Rejection Email Notification</description>
        <protected>false</protected>
        <recipients>
            <field>DRE_Point_of_Contact__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Rejection_Email_Notification</template>
    </alerts>
    <alerts>
        <fullName>Science_Email_Notification_for_internal_approval</fullName>
        <description>Science Email Notification – for internal approval</description>
        <protected>false</protected>
        <recipients>
            <field>DRE_Point_of_Contact__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Ops_Science_Finance_Email_Notification_Notice_Only</template>
    </alerts>
    <fieldUpdates>
        <fullName>Approved_Status</fullName>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Approved Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>In_Approval_Process</fullName>
        <field>Status__c</field>
        <literalValue>In Approval Process</literalValue>
        <name>In Approval Process</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PO_No_Requested_Status</fullName>
        <field>Status__c</field>
        <literalValue>PO No. Requested</literalValue>
        <name>PO No. Requested Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Rejection_Status</fullName>
        <field>Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Rejection Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Stamp_Hourly_Rate</fullName>
        <field>Hourly_Rate__c</field>
        <formula>Preferred_Vendor__r.Hourly_Rate__c</formula>
        <name>Stamp Hourly Rate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Submitted_for_Final_Approval</fullName>
        <field>Status__c</field>
        <literalValue>Submitted for Final Approval</literalValue>
        <name>Submitted for Final Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Set Hourly Rate from Override</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Preferred_Vendor_Request__c.Rate_Type_Override__c</field>
            <operation>equals</operation>
            <value>Hourly Rate Override</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Stamp Hourly Rate</fullName>
        <actions>
            <name>Stamp_Hourly_Rate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>ISPICKVAL(Preferred_Vendor__r.Rate_Type__c,"Hourly Rate")</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
