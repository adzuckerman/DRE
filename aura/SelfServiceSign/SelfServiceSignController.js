({
    doInit : function(component, event, helper) {
        helper.initAgreementData(component);
	},
    
    afterScriptsLoaded : function(component, event, helper) {
        $jquery = jQuery.noConflict();
	},
    
   	dismissAlert : function(component, event, helper) {
        component.set("v.errorMessage", null);
    },
    
    onSendAgreement : function(component, event, helper) {
        helper.sendAgreement(component);
    },
    
    onCloseSignDialog : function(component, event, helper) {
        helper.closeSignDialog(component);
    },

    onAgreementSignedView : function(component, event, helper) {
        var index = event.target.dataset.order;

        helper.viewAgreementSignedPdf(component, index, component.get("v.result").signedAgreementWrappers);
    },

    onAgreementWaitingOthersView : function(component, event, helper) {
        var index = event.target.dataset.order;

        helper.viewAgreementSignedPdf(component, index, component.get("v.result").waitingOthersAgreementWrappers);
    },

    onSignedViewAll : function(component, event, helper) {
        helper.viewAll(component, "v.isSignedViewAll");
    },

    onWaitingOthersViewAll : function(component, event, helper) {
        helper.viewAll(component, "v.isWaitingOthersViewAll");
    },

    onWaitingYouViewAll : function(component, event, helper) {
        helper.viewAll(component, "v.isWaitingYouViewAll");
    },

    onAgreementSign : function(component, event, helper) {
        var index = event.target.dataset.order;

        helper.signAgreement(component, index);
    },

    onAgreementTemplateSign : function(component, event, helper) {
        var index = event.target.dataset.order;

        helper.sendSignAgreement(component, index);
    }
})