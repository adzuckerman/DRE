({
    initAgreementData : function(component) {
        var self = this;
        
        component.set("v.isLoading", true);

        var templateId = component.get("v.templateId");

        var signingDeadline = component.get("v.signingDeadline");

        var agreementScope = component.get("v.agreementScope");
        var renewalDays = component.get("v.renewalDays");

        if( renewalDays <= 0 ) {
            self.handleError(component, $A.get("$Label.echosign_dev1.Self_Sign_Invalid_Renewal_Days_Error"));
            return;
        }

        var action = component.get("c.findCurrentUserRelatedAgreements");
        action.setParams({
            "templateId": templateId,
            "signingDeadline": signingDeadline,
            "agreementScope": agreementScope,
            "renewalDays": renewalDays
        });
        
        action.setCallback(this, function(response) {
            var isSuccess = self.checkResult(component, response);
            if( !isSuccess ) {
                return;
            }
                      
            var result = response.getReturnValue().result;
            
            component.set("v.result", result);
            component.set("v.isVisible", true);
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },
    
    closeSignDialog : function(component) {
        var self = this;
        
        self.hideElemVisibility("signDialog");

        component.set("v.signUrl", null);

        var agreementWrapper = component.get("v.signAgreementWrapper");

        var action = component.get("c.hasCurrentUserCompleted");
        action.setParams({
            "agreementId": agreementWrapper.agreement.Id
        });
        
        action.setCallback(this, function(a) {
            var isCompleted = !a.getReturnValue().error;

            if( isCompleted ) {
                component.set("v.isSigned", true);
                component.set("v.isSuccessMessage", true);
                component.set("v.successMessage", a.getReturnValue().result);

                setTimeout( $A.getCallback(function(){ self.checkRecipientStatusUpdate(component, agreementWrapper, 0); }), 500);
            } else {         
                self.initAgreementData(component);

                component.set("v.isLoading", false);
            }
        
        });
   
        $A.enqueueAction(action);
    },

    checkRecipientStatusUpdate: function(component, agreementWrapper, counter) {
        var self = this;

        if( counter++ > 30 ) {
            component.set("v.isErrorMessage", true);    
            component.set("v.errorMessage", $A.get("$Label.echosign_dev1.Self_Sign_Signing_Not_Available_Error"));
            component.set("v.isLoading", false);

            self.hideElemVisibility("signDialog");

            return;
        }

        var action = component.get("c.isRecipientStatusCompleted");
        action.setParams({
            "agreementId": JSON.stringify( agreementWrapper.agreement.Id ),
        });
        
        action.setCallback(this, function(a) {
            var isSuccess = self.checkResult(component, a);

            if( !isSuccess ) {
                self.initAgreementData(component);
                return;
            }

            var isSignedStatus = a.getReturnValue().result;

            if( isSignedStatus === true ) {
                self.initAgreementData(component);
                return;
            }

            setTimeout( $A.getCallback(function(){ self.checkRecipientStatusUpdate(component, agreementWrapper, counter); }), 500);
        });
        $A.enqueueAction(action);
    },

    viewAll : function(component, attributeName) {
        var self = this;

        component.set(attributeName, true);
    },

    viewAgreementSignedPdf : function(component, index, agreementWrappers) {
        var self = this;
        
        component.set("v.isLoading", true);

        var agreementWrapper = agreementWrappers[index];

        var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
            "url": agreementWrapper.agreementSignedPdfUrl
            });
        urlEvent.fire();

        component.set("v.isLoading", false);
    },

    sendSignAgreement : function(component, index) {
        var self = this;
        
        component.set("v.isLoading", true);

        var agreementWrapper = component.get("v.result").templateAgreementWrappers[index];

        component.set("v.signAgreementWrapper", agreementWrapper);
        
        var recipients = new Array();
        for(var i = 0; i < agreementWrapper.recipientWrappers.length; i++) {
            recipients[i] = agreementWrapper.recipientWrappers[i].recipient;
        }
        
        var action = component.get("c.saveAgreementData");
        action.setParams({
            "agreementStr": JSON.stringify(agreementWrapper.agreement),
            "recipientsStr": JSON.stringify(recipients),
            "deletedRecipientsStr": JSON.stringify(new Array()),
            "documentsStr": JSON.stringify(agreementWrapper.attachmentWrappers),
            "deletedDocumentsStr": JSON.stringify(agreementWrapper.deletedAttachmentWrappers),
            "templatesStr": JSON.stringify(agreementWrapper.templateWrappers),
            "deletedTemplatesStr": JSON.stringify(agreementWrapper.deletedTemplateWrappers)
        });
        
        action.setCallback(this, function(a) {
            var isSuccess = self.checkResult(component, a);
            if( !isSuccess ) {
                return;
            }
            
            var agreementWrapper = a.getReturnValue();
            
            self.sendForSignature(component, agreementWrapper);
        });
   
        $A.enqueueAction(action);
    },
    
    signAgreement: function(component, index) {
        var self = this;
        
        component.set("v.isLoading", true);

        var agreementWrapper = component.get("v.result").waitingYouAgreementWrappers[index];

        component.set("v.signAgreementWrapper", agreementWrapper);

        self.pollSigningUrl(component, agreementWrapper, 0);
    },

    sendForSignature: function(component, agreementWrapper) {
        var self = this;
        
        var action = component.get("c.sendAgreementData");
        action.setParams({
            "agreementStr": JSON.stringify(agreementWrapper.agreement)
        });
        
        action.setCallback(this, function(a) {
            var isSuccess = self.checkResult(component, a);
            if( !isSuccess ) {
                return;
            }
            
            var sendDocumentResult = a.getReturnValue();
            var errorMessage = sendDocumentResult.errorMessage;
            
            if( errorMessage ) {
                component.set("v.isLoading", false);
                component.set("v.errorMessage", errorMessage);
            } else {
                agreementWrapper.agreement.echosign_dev1__Document_Key__c = sendDocumentResult.documentKey;
                
                component.set("v.signAgreementWrapper", agreementWrapper);

                self.pollSigningUrl(component, agreementWrapper, 0);
                return false;
            }
        });
        
        $A.enqueueAction(action);
    },
    
    pollSigningUrl: function(component, agreementWrapper, counter) {
        var self = this;

        if( counter++ > 5 ) {
            component.set("v.isErrorMessage", true);    
            component.set("v.errorMessage", $A.get("$Label.echosign_dev1.Self_Sign_Signing_Not_Available_Error"));
            component.set("v.isLoading", false);

            self.hideElemVisibility("signDialog");

            return;
        }

        var action = component.get("c.retrieveSigningUrl");
        action.setParams({
            "agreementStr": JSON.stringify( agreementWrapper.agreement ),
            "isUserFilter": true,
            "isFillSign": false
        });
        
        action.setCallback(this, function(a) {
            var isSuccess = self.checkResult(component, a);

            if( !isSuccess ) {
                self.initAgreementData(component);
                return;
            }

            var signingUrl = a.getReturnValue().result;
            if( signingUrl == null || signingUrl.length == 0 ) {
                self.pollSigningUrl(component, agreementWrapper, counter);
            } else {
				component.set("v.signUrl", signingUrl);
                
                self.showElemVisibility("signDialog");
            }
        });
        $A.enqueueAction(action);
    },
    
    checkPopup : function(component, popup, masterId) {
        var self = this;
        
        var intervalRef = setInterval( function() {             
            if( !popup || popup.closed ) {
                clearInterval(intervalRef);
                
                component.set("v.isLoading", false);
                component.set("v.isSigned", true);
            }
        }, 
        500 );
    },
    
    checkResult : function(component, response) {
        var self = this;
        
        var state = response.getState();
        if (state !== "ERROR") {
            if( ( response.getReturnValue() !== undefined && response.getReturnValue() !== null ) &&
               ( response.getReturnValue().error !== undefined && response.getReturnValue().error !== null ) ) {
                self.handleError(component, response.getReturnValue().error);
                return false;
            } else if( ( response.getReturnValue() !== undefined && response.getReturnValue() !== null ) &&
               ( response.getReturnValue().errorMessage !== undefined && response.getReturnValue().errorMessage !== null ) ) {
                self.handleError(component, response.getReturnValue().errorMessage);
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
        var self = this;
        
        if( errorMessage.indexOf("Invalid date") != -1 ) {
            errorMessage = errorMessage.replace("Invalid date", $A.get("$Label.echosign_dev1.Self_Sign_Invalid_Date_Error"));
        }

        component.set("v.isErrorMessage", true);    
        component.set("v.errorMessage", errorMessage);
        component.set("v.isLoading", false);
    },
 
    hideElemVisibility: function(elemId) {
        var elem = document.getElementById(elemId);
        if( !elem ) {
            return;
        }
        
        var elemClass = elem.getAttribute("class");
        
        if( elemClass.indexOf("slds-show") !== -1 ) {
            elemClass = elemClass.replace("slds-show", "slds-hide");
        	elem.setAttribute("class", elemClass);
        }
    },
    
    showElemVisibility: function(elemId) {
        var elem = document.getElementById(elemId);
        if( !elem ) {
            return;
        }
        
        var elemClass = elem.getAttribute("class");
        
        if( elemClass.indexOf("slds-hide") !== -1 ) {
            elemClass = elemClass.replace("slds-hide", "slds-show");
        	elem.setAttribute("class", elemClass);
        }
    }
})