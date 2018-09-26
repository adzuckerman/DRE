({
    loadAgreement : function(component) {
        var agreementId = component.get("v.agreementId");
        var tab = component.get("v.tab");
        var action = component.get("c.loadAgreement");
        action.setParams({
            "agreementId": agreementId
        });
        var self = this;
        action.setCallback(this, function(a) {
            self.pullAgreementData(component, a.getReturnValue());
            component.set("v.tab", component.get("v.tab"));
        });
        $A.enqueueAction(action);
    },
    
    pullAgreementData: function(component, agreementWrapper) {
        var self = this;
        component.set("v.agreementWrapper", agreementWrapper);
        component.set("v.agreementName", agreementWrapper.agreement.Name);
        component.set("v.agreementId", agreementWrapper.agreement.Id);
        component.set("v.agreementStatus", self.getFieldValue(component, agreementWrapper.agreement, "Status__c"));
    },
    
    getFieldValue : function(component, record, fieldName) {
        var self = this;
        return record[self.getNamespacePrefix(component) + fieldName];
    },
    
    getNamespacePrefix : function(component) {
        var self = this;
        return self.getNamespace(component) + "__";
    },
    
    getNamespace : function(component) {
        //return component.getDef().getDescriptor().getNamespace();
        return "echosign_dev1";
    },
    
    navigateBack : function(component) {
        sforce.one.back(true);;
    }
})