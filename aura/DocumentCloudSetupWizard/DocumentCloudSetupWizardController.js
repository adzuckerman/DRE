({
    doInit : function(component, event, helper) {
        helper.initSetupWizard(component);
    },
    
    onUpdatesFrameLoad : function (component, event, helper) {
        var updatesFrameLoadCount = component.get("v.updatesFrameLoadCount");
        
        if( updatesFrameLoadCount == 0 ) {
            component.set("v.updatesFrameLoadCount", 1)
        } if( updatesFrameLoadCount == 1 ) {
            component.set("v.isUpdateConfirmed", true);
        }
    },
    
    navToBackFromUpdate : function(component, event, helper) {
        component.set("v.isLoading", true);
        component.set("v.oauthStep", true);
        component.set("v.updateStep", false);
        component.set("v.completeStep", false);
        component.set("v.oauthState", null);
        component.set("v.oauthCode", "");
        component.set("v.oauthError", null);
        component.set("v.oauthErrorDescription", null);
        component.set("v.apiAccessPoint", null);
        component.set("v.isUpdateConfirmed", false);
        component.set("v.isLoading", false);
    },
    
    navToNextFromUpdate : function(component, event, helper) {
        helper.proceedToFinal(component);
    },
    
    navToLayout : function(component, event, helper) {
        var action = component.get("c.setLayoutCompleted");
        
        action.setCallback(this, function(a) {
            var isSuccess = helper.checkResult(component, a);
            if( !isSuccess ) {
                return;
            }
        
            window.location.href = '/ui/setup/layout/PageLayouts?type=Account&setupid=AccountLayouts';
        });
        $A.enqueueAction(action);
    },
    
    navToTemplates : function(component, event, helper) {
        var result = component.get("v.setupWizardResult");
        
        window.location.href = '/' + result.agreementTemplatePrefix + '/e';
    },
    
    navToUpdates : function(component, event, helper) {
        component.set("v.isLoading", true);
        
        helper.proceedToUpdateStep(component);
    },
    
    navToComplete : function(component, event, helper) {
        helper.proceedToComplete(component);
    },
    
    exitWizard : function(component, event, helper) {
        helper.proceedToExit(component);
    },
    
    navToSignin : function(component, event, helper) {
        helper.proceedToLogin(component);
    },
    
    navToSignup : function(component, event, helper) {
        var result = component.get("v.setupWizardResult");
        var url = result.registrationPageUrl;
        window.open(url);
    },    
})