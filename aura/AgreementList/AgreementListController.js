({
    doInit : function(component, event, helper) {
        helper.initAgreementData(component);
        helper.initSettings(component);
    },
    
    openAgreement : function(component, event, helper) {
        window.open("/echosign_dev1/EchoSign.app");
    },
    
    toggleNewAgreement : function(component, event, helper) {
        helper.toggleElemVisibility("newAgreementDropdown", component);
    },
    
    toggleAgreementAction : function(component, event, helper) {
        var agreementId = event.target.dataset.order;
        helper.toggleIterElemVisibility(component, "agreementActionDropdown", "esign-agreement-action-inline-dropdown", "agreementActionDropdown" + agreementId);
    },
    
    selectAgreementTemplate : function(component, event, helper) {
        var agreementTemplateId = event.target.dataset.order;
        helper.createNewAgreement(component, agreementTemplateId);
    },
    
    selectNewAgreement : function(component, event, helper) {
        helper.createNewAgreement(component);
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