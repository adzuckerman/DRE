<aura:application access="GLOBAL" extends="ltng:outApp" useAppcache="false">
    <aura:dependency resource="echosign_dev1:DocumentCloudSetupWizard"/>
    
    <aura:attribute name="wizardStep" type="String" />
    <aura:attribute name="oauthCode" type="String" />
    <aura:attribute name="oauthError" type="String" />
    <aura:attribute name="oauthErrorDescription" type="String" />
    <aura:attribute name="oauthState" type="String" />
    <aura:attribute name="apiAccessPoint" type="String" />
    <aura:attribute name="returnUrl" type="String" />
    <aura:attribute name="partnerUrl" type="String" />
</aura:application>