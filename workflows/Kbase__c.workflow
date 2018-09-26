<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Default_Extraction_Quantity</fullName>
        <description>Make default extraction quantity 1.</description>
        <field>Extraction_Quantity__c</field>
        <formula>1</formula>
        <name>Default Extraction Quantity</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Default Extraction Quantity</fullName>
        <actions>
            <name>Default_Extraction_Quantity</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 OR 2) AND 3</booleanFilter>
        <criteriaItems>
            <field>Kbase__c.Extraction_Task_Description__c</field>
            <operation>equals</operation>
            <value>Term Index</value>
        </criteriaItems>
        <criteriaItems>
            <field>Kbase__c.Extraction_Task_Description__c</field>
            <operation>equals</operation>
            <value>Text</value>
        </criteriaItems>
        <criteriaItems>
            <field>Kbase__c.Extraction_Quantity__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Default extraction quantity to 1 if Extraction Task Description equals Index or Text.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
