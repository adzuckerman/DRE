<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>DI_II_Reference_Status_Set</fullName>
        <description>Set DI-II Reference Status to Assigned.</description>
        <field>DI_II_Reference_Status__c</field>
        <literalValue>Assigned</literalValue>
        <name>DI-II Reference Status Set</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_DI_I_Reference_Status</fullName>
        <description>Set DI-I Reference Status to Assigned.</description>
        <field>DI_I_Reference_Status__c</field>
        <literalValue>Assigned</literalValue>
        <name>Set DI-I Reference Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Extraction_Status</fullName>
        <description>Extraction Reference Status set to Assigned.</description>
        <field>Extraction_Reference_Status__c</field>
        <literalValue>Assigned</literalValue>
        <name>Update Extraction Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Junction_Kbase_Name</fullName>
        <field>Name</field>
        <formula>"CN " +  TaskRay_Project__r.Sub_Project_Number__c  + " - " + Kbases__r.Name</formula>
        <name>Update Junction Kbase Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>DI-I Assignee Name Filled Out</fullName>
        <actions>
            <name>Set_DI_I_Reference_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Junction_Kbase__c.DI_I_Assignee_Name__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>If “DI-I Assignee Name” is filled out, the “DI-I Reference Status” should be automatically set to “Assigned”.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DI-II Fixes Assignee Name Filled Out</fullName>
        <actions>
            <name>DI_II_Reference_Status_Set</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Junction_Kbase__c.DI_II_Assignee_Name__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>If “DI-II Assignee Name” is filled out, the “DI-II Reference Status” should be automatically set to “Assigned”.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Extraction Assignee Name Filled Out</fullName>
        <actions>
            <name>Update_Extraction_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Junction_Kbase__c.Extraction_Assignee_Name__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>If “Extraction Assignee Name” is filled out, the “Extraction Reference Status” should be automatically set to “Assigned”.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Junction Kbase Name %2F Reference ID</fullName>
        <actions>
            <name>Update_Junction_Kbase_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Junction_Kbase__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
