({
    doInit : function(component, event, helper) {
        helper.initAgreementData(component);
        helper.initSettings(component);
    },
    
    openAgreement : function(component, event, helper) {
        window.open("/apex/" + helper.getNamespacePrefix(component) + "AgreementEditor");
    },
    
    toggleNewAgreement : function(component, event, helper) {
        helper.toggleElemVisibility(component, "newAgreementDropdown");
    },
    
    toggleAgreementAction : function(component, event, helper) {
        var agreementId = event.target.dataset.order;
        helper.toggleIterElemVisibility(component, "agreementActionDropdown", "esign-agreement-action-top-dropdown", "agreementActionDropdown" + agreementId);
    },
    
    selectAgreementTemplate : function(component, event, helper) {
        var agreementTemplateId = event.target.dataset.order;
        helper.createNewAgreement(component, agreementTemplateId);
    },
    
    selectNewAgreement : function(component, event, helper) {
        helper.createNewAgreement(component);
    },
    
    onAgreementsRelatedList : function(component, event, helper) {
        var url = "/apex/" + helper.getNamespacePrefix(component) + "AgreementRelatedList?recordId=" + component.get("v.recordId") 
            + "&recordFieldName=" + component.get("v.recordFieldName");
        //helper.navToUrl(url);
        window.open(url);
    },
    
    onAgreementEdit : function(component, event, helper) {
        var agreementId = event.target.dataset.order;
        helper.invokeAgreementAction(component, agreementId, "edit");
    },
     
    onAgreementHost : function(component, event, helper) {
        var agreementId = event.target.dataset.order;
        helper.invokeAgreementAction(component, agreementId, "host");
    },
    
    onAgreementView : function(component, event, helper) {
        var agreementId = event.target.dataset.order;
        helper.invokeAgreementAction(component, agreementId, "view");
    },
    
    onAgreementRemind : function(component, event, helper) {
        var agreementId = event.target.dataset.order;
        helper.invokeAgreementAction(component, agreementId, "remind");
    },
    
    onAgreementUpdate : function(component, event, helper) {
        var agreementId = event.target.dataset.order;
        helper.invokeAgreementAction(component, agreementId, "update");
    },
    
    onAgreementDelete : function(component, event, helper) {
        var agreementId = event.target.dataset.order;
        helper.invokeAgreementAction(component, agreementId, "delete");
    },
    
    onAgreementCancel : function(component, event, helper) {
        var agreementId = event.target.dataset.order;
        helper.invokeAgreementAction(component, agreementId, "cancel");
    }
})