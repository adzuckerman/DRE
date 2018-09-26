({
    toggleElemVisibility : function(component, elemId) {
        var cmpTarget = component.find(elemId);

        if( !cmpTarget ) {
            return;
        }
        
        $A.util.toggleClass(cmpTarget, "slds-show");
        $A.util.toggleClass(cmpTarget, "slds-hide");
    },
    
    goToSignatureLayout : function(component, type) {
        var self = this;
        
        var result = component.get("v.loadResult");
        var action = component.get("c.setLayoutCompleted");
        
        action.setCallback(this, function(a) {
            var isSuccess = self.checkResult(component, a);
            if( !isSuccess ) {
                return;
            } 
            
            if( result.uiThemeDisplayed == 'Theme4d' || result.uiThemeDisplayed == 'Theme4t' ) {
                window.open(component.get("v.loadResult").sitePrefix + '/one/one.app?source=aloha#/setup/object/' + type);
            } else {
                window.open(component.get("v.loadResult").sitePrefix + '/ui/setup/layout/PageLayouts?type=' + type + '&setupid=' + type + 'Layouts');
            }
            
            self.toggleElemVisibility(component, "signatureComponentsDialog");
        });
        $A.enqueueAction(action);
    },

    checkResult : function(component, response) {
        var self = this;
        
        var state = response.getState();
        if (state !== "ERROR") {
            if( response.getReturnValue() != null && response.getReturnValue().error != null ) {
                self.handleError(component, response.getReturnValue().error);
                return false;
            }
            return true;
        }
        
                var errorMessage = "";
                var errors = response.getError();
                if (errors) {
                    for(var i = 0; errors && i < errors.length; i++) {
                        var error = errors[i];

                        if( error.message ) {
                            errorMessage += ( " " + error.message );  
                        }
                        
                        for(var j = 0; error && error.fieldErrors && j < error.fieldErrors.length; j++) {
                            var fieldError = error.fieldErrors[j]; 
                            if( fieldError && fieldError.message ) {
                                errorMessage += ( " " + fieldError.message );
                            }
                        }
                        
                        for(var j = 0; error && error.pageErrors && j < error.pageErrors.length; j++) {
                            var pageError = error.pageErrors[j]; 
                            if( pageError && pageError.message ) {
                                errorMessage += ( " " + pageError.message );
                            }
                        }
                    }
                } else {
                    errorMessage += " Unknown error";
                }

                self.handleError(component, errorMessage);
                
                return false;
    },
        
    handleError : function(component, errorMessage) {
        component.set("v.isLoading", false);
        component.set("v.isError", true);
        component.set("v.errorMessage", errorMessage);
    },
        
    createTemplate : function(component, templateType) {
        var self = this;

        component.set("v.isLoading", true);

        var action = component.get("c.importAgreementTemplate");
        action.setParams({
            "templateType": JSON.stringify(templateType)
        });

        action.setCallback(this, function(a) {
            var isSuccess = self.checkResult(component, a);
            if( !isSuccess ) {
                return;
            } 

            window.open(component.get("v.loadResult").sitePrefix + "/" + a.getReturnValue().result);
            
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },
    
    updateDocumentKeys : function(component, isUpdate) {
        component.set("v.fetchDocumentKeyJobError", null);
        var action = component.get(isUpdate == "true" ? "c.updateLegacyOrMissingDocumentKeys" : "c.retrieveDocumentKeys");
        action.setCallback(this, function(a) {
            var isSuccess = this.checkResult(component, a);
            if( !isSuccess ) {
                var error = component.get("v.errorMessage");
                component.set("v.errorMessage", null);
                component.set("v.fetchDocumentKeyJobError", error);
            	return;
            }
            var jobId = a.getReturnValue();
            if (jobId == null || jobId == undefined){
                jobId = '';
            }
            component.set("v.fetchDocumentKeyJobId", jobId);
        });
    	$A.enqueueAction(action);
    },
        
    getUserGuideUrl : function() {
        var self = this;

        var language = $A.get("$Locale.language");
        
        if( language === "ja" ) {
            return "https://helpx.adobe.com/jp/sign/help/reference_guides.html#SFDC";
        } else {
            return "https://helpx.adobe.com/sign/help/reference_guides.html#SFDC";
        }
    },
        
    getTextTagUrl : function() {
        var self = this;

        var language = $A.get("$Locale.language");
        
        if( language === "ja" ) {
            return "https://helpx.adobe.com/jp/sign/help/adobesign_text_tag_guide.html";
        } else {
            return "https://www.adobe.com/go/echosign_createforms_texttags";
        }
    },
        
    getSmartFormUrl : function() {
        var self = this;

        var language = $A.get("$Locale.language");
        
        if( language === "ja" ) {
            return "https://helpx.adobe.com/jp/acrobat/using/creating-distributing-pdf-forms.html";
        } else {
            return "https://helpx.adobe.com/acrobat/using/creating-distributing-pdf-forms.html";
        }
    }
})