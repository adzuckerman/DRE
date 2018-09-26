({
    doInit : function(component, event, helper) {
        var action = component.get("c.loadAdmin");
       
        action.setCallback(this, function(a) {
            var isSuccess = helper.checkResult(component, a);
            if( !isSuccess ) {
                component.set("v.loadResult", a.getReturnValue().result);
                return;
            }
            
            var result = a.getReturnValue().result;           
            if( !result.isSetupCompleted ) {
                var retUrl = encodeURIComponent( window.location.href );
                 var openUrl = result.sitePrefix + '/apex/' + result.namespace + '__EchoSignSetupWizard?retUrl=' + retUrl;
                
                if( result.uiThemeDisplayed == 'Theme4d' || result.uiThemeDisplayed == 'Theme4t' ) {
                    var popUp = window.open(openUrl);
                    if (popUp != null && typeof(popUp) != 'undefined') {
                        window.parent.location.href = '/';
                    }
                    //window.parent.location.href = '/';
                } else {
                    window.location.href = openUrl;
                }
                
                return;
            }

            component.set("v.loadResult", result);
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },
    
    toggleNetworkRangesDialog : function(component, event, helper) {
        helper.toggleElemVisibility(component, "networkRangesDialog");
    },
    
    toggleSignatureComponentsDialog : function(component, event, helper) {
        helper.toggleElemVisibility(component, "signatureComponentsDialog");
    },
    
    addNetworkRangeOne : function(component, event, helper) {
        window.open(component.get("v.loadResult").sitePrefix + "/05G/e?IpEndAddress=166.78.79.127&IpStartAddress=166.78.79.112");
    }, 
    
    addNetworkRangeTwo : function(component, event, helper) {
        window.open(component.get("v.loadResult").sitePrefix + "/05G/e?IpEndAddress=52.71.63.255&IpStartAddress=52.71.63.224");
    },  
    
    addNetworkRangeThree : function(component, event, helper) {
        window.open(component.get("v.loadResult").sitePrefix + "/05G/e?IpEndAddress=52.35.253.95&IpStartAddress=52.35.253.64");
    },  
    
    addNetworkRangeFour : function(component, event, helper) {
        window.open(component.get("v.loadResult").sitePrefix + "/05G/e?IpEndAddress=52.48.127.191&IpStartAddress=52.48.127.160");
    },  
    
    addNetworkRangeFive : function(component, event, helper) {
        window.open(component.get("v.loadResult").sitePrefix + "/05G/e?IpEndAddress=52.58.63.223&IpStartAddress=52.58.63.192");
    },  
    
    addNetworkRangeSix : function(component, event, helper) {
        window.open(component.get("v.loadResult").sitePrefix + "/05G/e?IpEndAddress=207.97.227.127&IpStartAddress=207.97.227.112");
    },
    
    addNetworkRangeSeven : function(component, event, helper) {
        window.open(component.get("v.loadResult").sitePrefix + "/05G/e?IpEndAddress=52.65.255.223&IpStartAddress=52.65.255.192");
    },  
    
    addNetworkRangeEight : function(component, event, helper) {
        window.open(component.get("v.loadResult").sitePrefix + "/05G/e?IpEndAddress=52.196.191.254&IpStartAddress=52.196.191.224");
    }, 
    
    addNetworkRangeNine : function(component, event, helper) {
        window.open(component.get("v.loadResult").sitePrefix + "/05G/e?IpEndAddress=13.126.23.31&IpStartAddress=13.126.23.0");
    },
    
    addAccountLayout : function(component, event, helper) {
        helper.goToSignatureLayout(component, "Account");
    },
    
    addOpportunityLayout : function(component, event, helper) {
        helper.goToSignatureLayout(component, "Opportunity");
    },
    
    addLeadLayout : function(component, event, helper) {
        helper.goToSignatureLayout(component, "Lead");
    },
    
    addContractLayout : function(component, event, helper) {
        helper.goToSignatureLayout(component, "Contract");
    },
    
    addContactLayout : function(component, event, helper) {
        helper.goToSignatureLayout(component, "Contact");
    },
    
    doUnlinkAccount : function(component, event, helper) {
        if(!confirm($A.get("$Label.echosign_dev1.Confirm_Account_Unlink_Prompt"))){return false;}
        component.set("v.isLoading", true);
        
        var result = component.get("v.loadResult");        
        var action = component.get("c.unlinkAccount");
        
        action.setCallback(this, function(a) {
            var isSuccess = helper.checkResult(component, a);
            if( !isSuccess ) {
                return;
            }
            
            result.authEmail = null;
            
            component.set("v.loadResult", result);
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },

    navToAuth : function(component, event, helper) {
        var result = component.get("v.loadResult");
        
        var returnUrl = encodeURIComponent("/apex/EchoSignAdmin");
        var openUrl = component.get("v.loadResult").sitePrefix + '/apex/' + result.namespace + '__EchoSignSetupWizard?stepName=admin&retUrl=' + returnUrl;
        
        if( result.uiThemeDisplayed == 'Theme4d' || result.uiThemeDisplayed == 'Theme4t' ) {
            window.open(openUrl); 
        } else {
            window.location.href = openUrl;
        }
    },
    
    navToWizard : function(component, event, helper) {
       
        var result = component.get("v.loadResult");
        
        var returnUrl = encodeURIComponent("/apex/EchoSignAdmin");
        var openUrl = component.get("v.loadResult").sitePrefix + '/apex/' + result.namespace + '__EchoSignSetupWizard?retUrl=' + returnUrl;
        

        
        if( result.uiThemeDisplayed == 'Theme4d' || result.uiThemeDisplayed == 'Theme4t' ) {
            window.open(openUrl); 
        } else {
            window.location.href = openUrl;
        }
    },
    
    navToLayout : function(component, event, helper) {
        var action = component.get("c.setLayoutCompleted");
        
        action.setCallback(this, function(a) {
            var isSuccess = helper.checkResult(component, a);
            if( !isSuccess ) {
                return;
            }
        
             window.location.href = component.get("v.loadResult").sitePrefix + '/ui/setup/layout/PageLayouts?type=Account&setupid=AccountLayouts';
        });
        $A.enqueueAction(action);
    },
    
    navToMerge : function(component, event, helper) {
        var result = component.get("v.loadResult");
        
        if( result.uiThemeDisplayed == 'Theme4d' || result.uiThemeDisplayed == 'Theme4t' ) {
            window.open('/' + result.mergeMappingPrefix + '/e');  
        } else {
            	window.location.href = component.get("v.loadResult").sitePrefix + '/' + result.mergeMappingPrefix + '/e';
               
        }
    },
    
    navToData : function(component, event, helper) {
        var result = component.get("v.loadResult");
        
        if( result.uiThemeDisplayed == 'Theme4d' || result.uiThemeDisplayed == 'Theme4t' ) {
            window.open('/' + result.dataMappingPrefix + '/e');  
        } else {
            window.location.href = component.get("v.loadResult").sitePrefix + '/' + result.dataMappingPrefix + '/e';    
        }
    },

    navToTemplates : function(component, event, helper) {
        var result = component.get("v.loadResult");
        
        if( result.uiThemeDisplayed == 'Theme4d' || result.uiThemeDisplayed == 'Theme4t' ) {
            window.open('/one/one.app#/sObject/' + result.agreementTemplatePrefix + '/home');
        } else {
             window.location.href = component.get("v.loadResult").sitePrefix + '/' + result.agreementTemplatePrefix + '/e';     
        }
    },
    
    navToGroup : function(component, event, helper) {
         window.location.href = component.get("v.loadResult").sitePrefix + '/apex/' + component.get("v.loadResult").namespace + '__GroupMapping';
    },
    
    navToCustomSettings : function(component, event, helper) {
        var result = component.get("v.loadResult");
        
        if( result.uiThemeDisplayed == 'Theme4d' || result.uiThemeDisplayed == 'Theme4t' ) {
            window.open('/one/one.app#/setup/CustomSettings/home');
        } else {
             window.open(component.get("v.loadResult").sitePrefix + '/setup/ui/listCustomSettings.apexp');
        }   
    },

    navToUpdate : function(component, event, helper) {
        var result = component.get("v.loadResult");
        var partnerUrl = result.partnerUrl;
        var url = result.baseServerUrl + '/salesforce-oauth/statusUpdates?server=' + encodeURIComponent(partnerUrl) + '&isSandbox=' + encodeURIComponent(result.isSandbox) + '&oauthEmail=' + encodeURIComponent(result.authEmail) + '&organization=' + result.orgId + '&namespace=' + result.namespace + '&Version=' + result.version + "&locale=" + result.language;
        
        window.open(url);
    }, 
    
    navToAdmin : function(component, event, helper) {
        component.set("v.isLoading", true);
        
        var action = component.get("c.getAccountMgmtUrl");
        
        action.setCallback(this, function(a) {
            var isSuccess = helper.checkResult(component, a);
            if( !isSuccess ) {
                component.set("v.loadResult", a.getReturnValue().result);
                return;
            }
            
            window.open( a.getReturnValue().result );

            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    }, 

    navToUserGuide : function(component, event, helper) {
        window.open( helper.getUserGuideUrl() );
    },   

    navToForum : function(component, event, helper) {
        window.open("https://forums.adobe.com/community/document-cloud-esign-services/salesforce_integration?view=overview");
    },     

    navToTextTag : function(component, event, helper) {
        window.open( helper.getTextTagUrl() );
    },    

    navToSmartForm : function(component, event, helper) {
        window.open( helper.getSmartFormUrl() );
    },       

    navToPortal : function(component, event, helper) {
        window.open("https://echosign.zendesk.com/hc/en-us/requests/new?ticket_form_id=34323");
    },
    
    fetchDocumentKeys : function(component, event, helper) {
        helper.updateDocumentKeys(component, "false");
    },
    
    updateDocumentKeys : function(component, event, helper) {
        helper.updateDocumentKeys(component, "true");
    },
	
    dismissAlert : function(component, event, helper) {
        component.set("v.errorMessage", null);
    },

    createStandardTemplate : function(component, event, helper) {
        helper.createTemplate(component, 0);
    },

    createSelfSignTemplate : function(component, event, helper) {
        helper.createTemplate(component, 1);
    }
})