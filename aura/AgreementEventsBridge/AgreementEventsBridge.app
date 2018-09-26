<aura:application access="GLOBAL" extends="ltng:outApp" useAppcache="false">
     <ltng:require scripts="{!join(',', 
        '/support/console/36.0/integration.js',
        '/soap/ajax/36.0/connection.js',
        '/soap/ajax/36.0/apex.js')}" />   

	<aura:attribute name="agreementId" type="String" />
    <aura:attribute name="tab" type="String" />

</aura:application>