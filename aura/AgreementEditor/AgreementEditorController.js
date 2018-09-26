({
    doInit : function(component, event, helper) {
        //alert("doInit");
        //"use strict";
        
        //alert("navigator.userAgent: " + navigator.userAgent);
        
        var isIe11 = ( navigator.userAgent.match(/rv:11.0/i) !== null );   
        component.set("v.isIe11", isIe11);
        
        var isSafari = /^((?!chrome|android).)*safari/i.test(navigator.userAgent);
        component.set("v.isSafari", isSafari);
        
        var isMacOs = ( navigator.userAgent.match(/Mac OS/i) !== null );
        component.set("v.isMacOs", isMacOs);
        
        var isFirefox = ( navigator.userAgent.match(/Firefox/i) !== null );
        component.set("v.isFirefox", isFirefox);

        //This is better option for detecting chrome as user-ager can be spoofed.
        var isChrome = !!window.chrome;
        component.set("v.isChrome", isChrome);
        
        var isEdge = navigator.appVersion.indexOf('Edge') > -1;
        component.set("v.isEdge", isEdge);
        
        helper.initSettings(component);
        helper.initAgreement(component);
        helper.initSchema(component);
        
        var action = component.get("c.getSitePrefix");
        action.setCallback(this, function(a) {
            if( !component.isValid() ) {
                return;
            }

            component.set("v.sitePrefix",  a.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    
    afterPageLoaded : function(component, event, helper) {
        helper.changeRecipientRowCSSStylingForMobile(component);
        helper.initPageCustom(component);
    },
    
    dismissAlert : function(component, event, helper) {
        component.set("v.errorMessage", null);
    },
    
    dismissErrorMessage : function(component, event, helper) {  
        var agreementWrapper = component.get("v.agreementWrapper");      
        var agreement = agreementWrapper.agreement;
        
        helper.setFieldValue(component, agreement, "ErrorMessage__c", null);
        component.set("v.agreementWrapper", agreementWrapper);
    },
    
    onSelectESignatureType : function(component, event, helper) {
        helper.selectSignatureType(component, "e-Signature");
    },

    onSelectFaxSignatureType : function(component, event, helper) {
        helper.selectSignatureType(component, "Written Signature");
    },
    
    onTemplateSelected : function(component, event, helper) {
        var selectedTemplateWrappers = event.getParam("selectedTemplateWrappers");
        var isCanceled = event.getParam("isCanceled");
        var disableScrolling = false;
        helper.backgroundScrolling(component, disableScrolling);
        if( isCanceled ) {
            component.set("v.isShowAddTemplatesDialog", false);
            return;
        }
        
        helper.addSelectedTemplates(component, selectedTemplateWrappers);
    },
    
    onDocumentSelected : function(component, event, helper) {
        var uploadedFileWrappers = event.getParam("uploadedFileWrappers");
        var selectedContentWrappers = event.getParam("selectedContentWrappers");
        var selectedDocumentWrappers = event.getParam("selectedDocumentWrappers");
        var selectedLibraryDocumentWrappers = event.getParam("selectedLibraryDocumentWrappers");
        var isCanceled = event.getParam("isCanceled");
        var disableScrolling = false;
        helper.backgroundScrolling(component, disableScrolling);
        if( isCanceled ) {
            component.set("v.isShowAddDocumentsDialog", false);
            return;
        }
        
        
        helper.addSelectedFiles(component, uploadedFileWrappers, selectedContentWrappers, selectedDocumentWrappers, selectedLibraryDocumentWrappers);
    },
    
    addRecipient : function(component, event, helper) {
        event.target.blur();
        helper.addRecipient(component);
    },
    
    addRecipientMe : function(component, event, helper) {
        event.target.blur();
        helper.addRecipientMe(component);
    },
    
    sendAgreement : function(component, event, helper) {
        helper.saveSendForSignature(component);
    },
      
    hostAgreement : function(component, event, helper) {
        helper.hostAgreement(component);
    },
    
    sendReminder : function(component, event, helper) {
        helper.sendReminder(component);
    },
     
    updateAgreement : function(component, event, helper) {
        helper.updateAgreement(component);
    },
    
    viewAgreement : function(component, event, helper) {
        helper.viewAgreement(component);
    },
    
    cancelAgreement : function(component, event, helper) {
        helper.cancelAgreement(component);
    },
    
    deleteAgreement : function(component, event, helper) {
        helper.deleteAgreement(component);
    },
    
    saveAgreement : function(component, event, helper) {
        helper.saveAgreement(component);
    },
    
    viewDocument : function(component, event, helper) {
        var documentIndex = event.target.dataset.order;
        helper.viewDocument(component, documentIndex);
    },
    
    viewUploadedDocument : function(component, event, helper) {
        var documentIndex = event.target.dataset.order;
        helper.viewUploadedDocument(component, documentIndex);
    },
        
    deleteTemplate : function(component, event, helper) {
        var templateIndex = event.target.dataset.order;
        helper.deleteTemplate(component, templateIndex);
    },
    
    deleteDocument : function(component, event, helper) {
        var documentIndex = event.target.dataset.order;
        helper.deleteDocument(component, documentIndex);
    },
    
    deleteRecipient : function(component, event, helper) {
        var recipientIndex = event.target.dataset.order;
        helper.deleteRecipient(component, recipientIndex);
    },
    deleteRecipientFromMobile : function(component, event, helper) {
        var recipientIndex = component.get("v.selectedRecipientIndex");
        var disableScrolling = false;
        helper.backgroundScrolling(component, disableScrolling);
        helper.hideElemVisibility("collapsedRecipientFeature", component);
        helper.deleteRecipient(component, recipientIndex);
        helper.popNotificationMessage(component, $A.get("$Label.echosign_dev1.delete_recipient_confirmation"), "ALERT");
    },
    reorderRecipient : function(component, event, helper) {
        var recipientIndex = event.target.dataset.order;
        var recipientNewOrder = event.target.value;
        helper.reorderRecipient(component, recipientIndex, recipientNewOrder);
    },
    
    onSelectSignerRole : function(component, event, helper) {
        var recipientIndex = helper.getNestedOrderValue(event);
        helper.selectSignerRole(component, recipientIndex, "Signer");
    },
    
    onSelectApproverRole : function(component, event, helper) {
        var recipientIndex = helper.getNestedOrderValue(event);
        helper.selectSignerRole(component, recipientIndex, "Approver");
    },
    
    onSelectAcceptorRole : function(component, event, helper) {
        var recipientIndex = helper.getNestedOrderValue(event);
        helper.selectSignerRole(component, recipientIndex, "Acceptor");
    },
      
    onSelectFormFillerRole : function(component, event, helper) {
        var recipientIndex = helper.getNestedOrderValue(event);
        helper.selectSignerRole(component, recipientIndex, "Form Filler");
    },
      
    onSelectCertifiedRole : function(component, event, helper) {
        var recipientIndex = helper.getNestedOrderValue(event);
        helper.selectSignerRole(component, recipientIndex, "Certified Recipient");
    },

    onSelectDelegateSignerRole : function(component, event, helper) {
        var recipientIndex = helper.getNestedOrderValue(event);
        helper.selectSignerRole(component, recipientIndex, "Delegate to Signer");
    },
    
    onSelectDelegateApproverRole : function(component, event, helper) {
        var recipientIndex = helper.getNestedOrderValue(event);
        helper.selectSignerRole(component, recipientIndex, "Delegate to Approver");
    },
    
    onSelectDelegateAcceptorRole : function(component, event, helper) {
        var recipientIndex = helper.getNestedOrderValue(event);
        helper.selectSignerRole(component, recipientIndex, "Delegate to Acceptor");
    },
    
    onSelectDelegateFormFillerRole : function(component, event, helper) {
        var recipientIndex = helper.getNestedOrderValue(event);
        helper.selectSignerRole(component, recipientIndex, "Delegate to Form Filler");
    },
    
    onSelectDelegateCertifiedRecipientRole : function(component, event, helper) {
        var recipientIndex = helper.getNestedOrderValue(event);
        helper.selectSignerRole(component, recipientIndex, "Delegate to Certified Recipient");
    },
    
    onSignDeadlinePrevMonth : function(component, event, helper) {
        helper.moveDeadlineDate(component, "Previous");
    },
    
    onSignDeadlineNextMonth : function(component, event, helper) {
        helper.moveDeadlineDate(component, "Next");
    },
    
    selectAgreementDeadline : function(component, event, helper) {
        var month = component.get("v.expirePickerSelectedMonthValue");
        var year = component.get("v.expirePickerSelectedYearValue");
        var day = event.target.dataset.order;
        
        helper.setAgreementDeadline(component, year, month, day);
    },
     
    editAgreementDeadline : function(component, event, helper) {
        var deadlineValue = component.get("v.agreementWrapper.signingDeadlineFormatted")
        //alert("deadlineValue: " + deadlineValue);
        
        if( !deadlineValue ) {
            helper.setAgreementDeadline(component, null, null, null); 
        } else {
            var deadlineDate = new Date(deadlineValue);
            helper.setAgreementDeadline(component, deadlineDate.getFullYear(), deadlineDate.getMonth(), deadlineDate.getDate());     
        }
    },
    
    onTooltipOver : function(component, event, helper) {
        //var tooltipElemId = helper.getNestedOrderValue(event);
        //helper.showElemVisibility(tooltipElemId);
    },
    
    onTooltipOut : function(component, event, helper) {
        //var tooltipElemId = helper.getNestedOrderValue(event);
        //helper.hideElemVisibility(tooltipElemId);
    },
    
    selectSignInOrder : function(component, event, helper) {
        helper.selectSignOrder(component, "Sign in Order");
    }, 
    
    selectSignInAnyOrder : function(component, event, helper) {
        helper.selectSignOrder(component, "Sign in Any Order");
    },
  
    selectFillSign : function(component, event, helper) {
        helper.selectSignOrder(component, "Fill & Sign");

        var agreementWrapper = component.get('v.agreementWrapper');

        agreementWrapper.recipientWrappers = new Array();

        var recipientWrappers = new Array();

        component.set('v.recipientWrappers', recipientWrappers);
        component.set('v.agreementWrapper', agreementWrapper);
    },

    selectOnlyISign : function(component, event, helper) {
        helper.selectSignOrder(component, "Only I Sign");
    },
    
    onSelectContactRecipientType : function(component, event, helper) {
        var recipientIndex = helper.getNestedOrderValue(event);
        var elem = "recipientTypeDropdown";
        helper.selectRecipientType(component, recipientIndex, "Contact", elem);
    },
    onSelectLeadRecipientType : function(component, event, helper) {
        var recipientIndex = helper.getNestedOrderValue(event);
        var elem = "recipientTypeDropdown";
        helper.selectRecipientType(component, recipientIndex, "Lead", elem);
    },
    
    onSelectUserRecipientType : function(component, event, helper) {
        var recipientIndex = helper.getNestedOrderValue(event);
        var elem = "recipientTypeDropdown";
        helper.selectRecipientType(component, recipientIndex, "User", elem);
    },
    
    onSelectGroupRecipientType : function(component, event, helper) {
        var recipientIndex = helper.getNestedOrderValue(event);
        var elem = "recipientTypeDropdown";
        helper.selectRecipientType(component, recipientIndex, "Group", elem);
    },
    
    onSelectEmailRecipientType : function(component, event, helper) {
        var recipientIndex = helper.getNestedOrderValue(event);
        var elem = "recipientTypeDropdown";
        helper.selectRecipientType(component, recipientIndex, "Email", elem);
    },
    
    /*Refactor this code. We should have same controller methods for same operation for desktop/tablet/mobile both.*/
    onSelectContactRecipientTypeFromMobile : function(component, event, helper) {
        var recipientIndex = component.get("v.selectedRecipientIndex");
        var elem = "recipientTypeSelectorMobileDialog";
        helper.selectRecipientType(component, recipientIndex, "Contact", elem);
        helper.hideElemVisibility("recipientSearchResultsOnMobile", component, recipientIndex);
    },

    onSelectLeadRecipientTypeFromMobile : function(component, event, helper) {
        var recipientIndex = component.get("v.selectedRecipientIndex");
        var elem = "recipientTypeSelectorMobileDialog";
        helper.selectRecipientType(component, recipientIndex, "Lead", elem);
        helper.hideElemVisibility("recipientSearchResultsOnMobile", component, recipientIndex);
    },
    
    onSelectUserRecipientTypeFromMobile : function(component, event, helper) {
        var recipientIndex = component.get("v.selectedRecipientIndex");
        var elem = "recipientTypeSelectorMobileDialog";
        helper.selectRecipientType(component, recipientIndex, "User", elem);
        helper.hideElemVisibility("recipientSearchResultsOnMobile", component, recipientIndex);
    },
    
    onSelectGroupRecipientTypeFromMobile : function(component, event, helper) {
        var recipientIndex = component.get("v.selectedRecipientIndex");
        var elem = "recipientTypeSelectorMobileDialog";
        helper.selectRecipientType(component, recipientIndex, "Group", elem);
        helper.hideElemVisibility("recipientSearchResultsOnMobile", component, recipientIndex);
    },
    
    onSelectEmailRecipientTypeFromMobile : function(component, event, helper) {
        var recipientIndex = component.get("v.selectedRecipientIndex");
        var elem = "recipientTypeSelectorMobileDialog";
        helper.selectRecipientType(component, recipientIndex, "Email", elem);
        helper.hideElemVisibility("recipientSearchResultsOnMobile", component, recipientIndex);
    },
    
    onReplaceRecipientMessageChange : function(component, event, helper) {
        helper.changeReplaceRecipient(component);
    },

    onSelectContactReplaceRecipientType : function(component, event, helper) {
        helper.selectReplaceRecipientType(component, "Contact");
    },
    
    closeReplaceRecipientTypeDialog : function(component, event, helper) {
		helper.hideElemVisibility("replaceRecipientTypeMobile", component);    
    },
    
    onSelectLeadReplaceRecipientType : function(component, event, helper) {
        helper.selectReplaceRecipientType(component, "Lead");
    },
    
    onSelectUserReplaceRecipientType : function(component, event, helper) {
        helper.selectReplaceRecipientType(component, "User");
    },
    
    onSelectEmailReplaceRecipientType : function(component, event, helper) {
        helper.selectReplaceRecipientType(component, "Email");
    },
    
    onReplaceRecipientSubmit : function(component, event, helper) {
        var disableScrolling = false;
        helper.backgroundScrolling(component, disableScrolling);
        helper.replaceRecipientSubmit(component);
    },
    
    onOpenRecipientMessage : function(component, event, helper) {
        var isSent = component.get("v.isSent");
        if( isSent ) {
            return;
        }
        
        var recipientIndex = event.target.dataset.order;
        helper.openRecipientMessage(component, recipientIndex, "recipientMessageDialog");
    },
    onOpenRecipientMessageFromMobile :  function(component, event, helper){
        var isSent = component.get("v.isSent");
        if( isSent ) {
            return;
        }
        
        var recipientIndex = component.get("v.selectedRecipientIndex");
        helper.hideElemVisibility("collapsedRecipientFeature", component);
        helper.openRecipientMessage(component, recipientIndex, "recipientMessageMobileDialog");
    },
    onSetRecipientMessage : function(component, event, helper) {
        var disableScrolling = false;
        helper.backgroundScrolling(component, disableScrolling);
        helper.setRecipientMessage(component);
    },
    
    toggleRecipientMessageDialog : function(component, event, helper) {
        component.get("v.isMobile") ? helper.toggleElemVisibility("recipientMessageMobileDialog", component): helper.toggleElemVisibility("recipientMessageDialog", component);
    },
    
    closeRecipientMessageDialog : function(component, event, helper) {
        var disableScrolling = false;
        helper.backgroundScrolling(component, disableScrolling);
        helper.hideElemVisibility("recipientMessageMobileDialog", component);
    },
    
    toggleReminder : function(component, event, helper) {
        var isSent = component.get("v.isSent");
        var settingsWrapper = component.get("v.settingsWrapper");
        if( isSent || helper.getFieldValue(component, settingsWrapper.customSettings, "Read_Only_Sign_Reminder__c") ) {
            return;
        }
        
        helper.toggleInputComponent(component, "reminderDropdown");
    },
    
    toggleLanguage : function(component, event, helper) {
        var isSent = component.get("v.isSent");
        var settingsWrapper = component.get("v.settingsWrapper");
        if( isSent || helper.getFieldValue(component, settingsWrapper.customSettings, "Read_Only_Language__c") ) {
            return;
        }
        
        helper.toggleInputComponent(component, "languageDropdown");
    },
    
    togglePostSignUrlProtocol : function(component, event, helper) {
        var isSent = component.get("v.isSent");
        var settingsWrapper = component.get("v.settingsWrapper");
        if( isSent || helper.getFieldValue(component, settingsWrapper.customSettings, "Read_Only_Post_Sign_Options__c") ) {
            return;
        }
        
        helper.toggleInputComponent(component, "postSignUrlProtocolDropdown");
    },
    
    toggleRecipientType : function(component, event, helper) {
        event.target.blur();
        var isSent = component.get("v.isSent");
        var settingsWrapper = component.get("v.settingsWrapper");
        if( isSent || helper.getFieldValue(component, settingsWrapper.customSettings, "Read_Only_Recipient__c") ) {
            return;
        }
        if(component.get("v.isMobile")){
            //In case of mobile click on recipient type button search contact window of mobile will open.
            var recipientIndex = helper.getNestedOrderValue(event);  
            if( !recipientIndex ) {
                return;
            }
            component.set("v.selectedRecipientIndex", recipientIndex);
            var disableScrolling = true;
            helper.backgroundScrolling(component, disableScrolling);
            helper.showElemVisibility("recipientLookUpMobileDialog", component, recipientIndex);
        }
        else{
            var recipientIndex = helper.getNestedOrderValue(event);
            helper.toggleElemVisibility( "recipientTypeDropdown", component, recipientIndex );
        }
    },
    
    showRecipientTypeFromMobile : function(component, event, helper) {
        // In case of mobile, click on recipient selector button will open the modal for recipient Lookup. 
        var recipientIndex = helper.getNestedOrderValue(event);  
        if( !recipientIndex ) {
            return;
        }
        var isSent = component.get("v.isSent");
        var settingsWrapper = component.get("v.settingsWrapper");
        if( isSent || helper.getFieldValue(component, settingsWrapper.customSettings, "Read_Only_Recipient__c") ) {
            return;
        }
        component.set("v.selectedRecipientIndex", recipientIndex);
        helper.showElemVisibility("recipientTypeSelectorMobileDialog", component, recipientIndex);
        return;
    },
    
    closeRecipientTypeFromMobile : function(component, event, helper) {
         // In case of mobile, click on recipient selector button will open the modal for recipient Lookup. 
        var recipientIndex = helper.getNestedOrderValue(event);  
        if( !recipientIndex ) {
            return;
        }
        var disableScrolling = true;
        helper.backgroundScrolling(component, disableScrolling);
        helper.hideElemVisibility("recipientTypeSelectorMobileDialog", component, recipientIndex);
        return;
    },
    
    toggleReplaceRecipientType : function(component, event, helper) {
        event.target.blur();
        
        if(component.get("v.isMobile")){
            var recipientIndex = component.get("v.selectedRecipientIndex");
            if( !recipientIndex ) {
                return;
            }
            var isSent = component.get("v.isSent");
            var settingsWrapper = component.get("v.settingsWrapper");
            helper.showElemVisibility( "replaceRecipientTypeMobile", component);
        }
        else{
            helper.toggleElemVisibility( "replaceRecipientTypeDropdown", component);
        }
    },
    
    toggleRecipientRole : function(component, event, helper) {
        event.target.blur();
        if(component.get("v.isMobile")){
            // In case of mobile, click on recipient selector button will open open the modal for recipient Lookup. 
            var recipientIndex = helper.getNestedOrderValue(event);  
            if( !recipientIndex ) {
                return;
            }
            component.set("v.selectedRecipientIndex", recipientIndex);
            var disableScrolling = true;
            helper.backgroundScrolling(component, disableScrolling);
            helper.showElemVisibility("recipientRoleMobileDialog", component, recipientIndex);
            return;
        }
        
        var recipientIndex = helper.getNestedOrderValue(event);
        helper.toggleInputComponent(component, "recipientRoleDropdown", recipientIndex);
    },
    
    toggleDeadline : function(component, event, helper) {
        var isSent = component.get("v.isSent");
        var settingsWrapper = component.get("v.settingsWrapper");
        if( isSent || helper.getFieldValue(component, settingsWrapper.customSettings, "Read_Only_Sign_Expiration__c") ) {
            return;
        }
        
        helper.toggleInputComponent(component, "deadlineDate");
    },
    
    toggleRecipientVerificationType : function(component, event, helper) {
        helper.toggleElemVisibility("recipientVerificationTypeDropdown", component);
    },
    
    toggleRecipientAddress : function(component, event, helper) {
        helper.toggleInputComponent(component, "recipientAddressDropdown");
    },
    
    hideReplaceRecipientDialog : function(component, event, helper) {
        var disableScrolling = false;
        helper.backgroundScrolling(component, disableScrolling);
        helper.hideElemVisibility("replaceRecipientDialog", component);
    }, 
    
    toggleReplaceRecipientDialog : function(component, event, helper) {
        var recipientIndex = helper.getNestedOrderValue(event);
        component.set("v.selectedRecipientIndex", recipientIndex);
        helper.createReplaceRecipient(component, recipientIndex);
        var disableScrolling = true;
        helper.backgroundScrolling(component, disableScrolling);
        helper.toggleElemVisibility("replaceRecipientDialog", component);
    }, 
    
    selectRecipientEmailAddress : function(component, event, helper) {
        var recipientIndex = helper.getNestedOrderValue(event);
        helper.selectRecipientAddress(component, recipientIndex, "email");
    },
    
    selectRecipientFaxAddress : function(component, event, helper) {
        var recipientIndex = helper.getNestedOrderValue(event);
        helper.selectRecipientAddress(component, recipientIndex, "fax");
    },
    
    addCc : function(component, event, helper) {
        var agreementWrapper = component.get("v.agreementWrapper");
        agreementWrapper.isCcSet = true;
        
        component.set("v.agreementWrapper", agreementWrapper);
    },
    
    toggleSignOrder : function(component, event, helper) {
        var settingsWrapper = component.get("v.settingsWrapper");
        if( helper.getFieldValue(component, settingsWrapper.customSettings, "Read_Only_Recipient_Signing_Order_Field__c") ) {
            return;
        }
        
        helper.toggleInputComponent(component, "signOrderDropdown");
    },
    
    toggleInProgressActions : function(component, event, helper) {
        helper.toggleElemVisibility("inProgressActionsDropdown", component);
    },
    
    toggleInAuthoringActions : function(component, event, helper) {
        helper.toggleElemVisibility("inAuthoringActionsDropdown", component);
    },
    
    toggleCancelAgreementDialog : function(component, event, helper) {
        var disableScrolling = true;
        helper.backgroundScrolling(component, disableScrolling);
        helper.toggleElemVisibility("cancelAgreementDialog", component);
    },
     
    closeCancelAgreementDialog : function(component, event, helper) {
        var disableScrolling = false;
        helper.backgroundScrolling(component, disableScrolling);
        helper.hideElemVisibility("cancelAgreementDialog", component);
    },
    
    toggleDeleteAgreementDialog : function(component, event, helper) {
        var disableScrolling = true;
        helper.backgroundScrolling(component, disableScrolling);
        helper.toggleElemVisibility("deleteAgreementDialog", component);
    },
    
    closeDeleteAgreementDialog : function(component, event, helper) {
        var disableScrolling = false;
        helper.backgroundScrolling(component, disableScrolling);
        helper.hideElemVisibility("deleteAgreementDialog", component);
    },
    
    toggleAddDocumentsDialog : function(component, event, helper) {
        //helper.toggleElemVisibility("addDocumentsDialog");
        var disableScrolling = true;
        helper.backgroundScrolling(component, disableScrolling);
        component.set("v.isShowAddDocumentsDialog", true);
    },
    
    toggleAddTemplatesDialog : function(component, event, helper) {
        var disableScrolling = true;
        helper.backgroundScrolling(component, disableScrolling);
        component.set("v.isShowAddTemplatesDialog", true);
    },
    
    onSelectRecipientCountryCode : function(component, event, helper) {
        var countryCode = event.target.dataset.order;
        var recipientIndex = event.target.parentElement.dataset.order;
        helper.selectRecipientCountryCode(component, countryCode, recipientIndex);
    },
    
    storeRecipientVerification : function(component, event, helper) {
        var recipientIndex = event.target.dataset.order;
        helper.storeRecipientVerification(component, recipientIndex);
    },
    
    storeRecipientVerificationFromMobile : function(component, event, helper) {
        var recipientIndex = event.target.dataset.order;
        var isMobile = true;
        helper.storeRecipientVerification(component, recipientIndex, isMobile);
        var disableScrolling = false;
        helper.backgroundScrolling(component, disableScrolling);
    },
    openRecipientVerificationDialog : function(component, event, helper) {
        var recipientIndex = event.target.dataset.order;
        var isMobile = false;
        helper.openRecipientVerificationDialog(component, recipientIndex, isMobile);
    },
    
    openRecipientVerificationMobileDialog : function(component, event, helper) {
        var recipientIndex = component.get("v.selectedRecipientIndex");
        helper.hideElemVisibility("collapsedRecipientFeature", component);
        var isMobile = true;
        helper.openRecipientVerificationDialog(component, recipientIndex, isMobile);
    },
  
    closeRecipientVerificationDialog : function(component, event, helper) {
        if(component.get("v.isMobile")){
            var disableScrolling =false;
            helper.backgroundScrolling(component, disableScrolling);
            helper.hideElemVisibility("recipientVerificationMobileDialog", component);
            helper.hideElemVisibility("verificationPhoneInputForm", component);
            helper.hideElemVisibility("verificationPasswordInputForm", component);
            //"recipientVerificationOptions" is child of "recipientVerificationMobileDialog". so making it visibile so that 
            //when ever "recipientVerificationMobileDialog" opens options are visible.
            helper.showElemVisibility("recipientVerificationOptions", component);
        }
        else{
        helper.hideElemVisibility("recipientVerificationDialog", component);
        }
    },
    toggleRecipientVerificationSelection : function(component, event, helper) {
        helper.toggleInputComponent(component, "recipientVerificationDropdown");
    },
    
    onRecipientEmailVerificationSelection : function(component, event, helper) {
        var recipientIndex = event.target.dataset.order;
        helper.selectRecipientVerification(component, recipientIndex, "recipientVerificationDropdown", "Email");
    },
    
    onRecipientKbaVerificationSelection : function(component, event, helper) {
        var recipientIndex = event.target.dataset.order;
        helper.selectRecipientVerification(component, recipientIndex, "recipientVerificationDropdown", "KBA");
    },
    
    onRecipientSocialVerificationSelection : function(component, event, helper) {
        var recipientIndex = event.target.dataset.order;
        helper.selectRecipientVerification(component, recipientIndex, "recipientVerificationDropdown", "Social");
    },
    
    onRecipientPasswordVerificationSelection : function(component, event, helper) {
        var recipientIndex = event.target.dataset.order;
        var isMobile=false;
        helper.selectRecipientVerification(component, recipientIndex, "recipientVerificationDropdown", "Password", isMobile);
    },
    
    onRecipientPhoneVerificationSelection : function(component, event, helper) {
        var recipientIndex = event.target.dataset.order;
        helper.selectRecipientVerification(component, recipientIndex, "recipientVerificationDropdown", "Phone");
    },
    
    toggleRecipientVerificationCountry : function(component, event, helper) {
        helper.toggleInputComponent(component, "recipientVerificationCountryDropdown");
    },
    
    toggleAgreementVerificationSelection : function(component, event, helper) {
        var isSent = component.get("v.isSent");
        var settingsWrapper = component.get("v.settingsWrapper");
        if( isSent || helper.getFieldValue(component, settingsWrapper.customSettings, "Read_Only_Security_Options__c") ) {
            return;
        }
        
        helper.toggleInputComponent(component, "agreementVerificationDropdown");
    },
    
    toggleAgreementInternalVerificationSelection : function(component, event, helper) {
        var isSent = component.get("v.isSent");
        var settingsWrapper = component.get("v.settingsWrapper");
        if( isSent || helper.getFieldValue(component, settingsWrapper.customSettings, "Read_Only_Security_Options__c") ) {
            return;
        }
        
        helper.toggleInputComponent(component, "agreementInternalVerificationDropdown");
    },
    
    toggleAgreementExternalVerificationSelection : function(component, event, helper) {
        var isSent = component.get("v.isSent");
        var settingsWrapper = component.get("v.settingsWrapper");
        if( isSent || helper.getFieldValue(component, settingsWrapper.customSettings, "Read_Only_Security_Options__c") ) {
            return;
        }
        
        helper.toggleInputComponent(component, "agreementExternalVerificationDropdown");
    },
    onAgreementEmailVerificationSelection : function(component, event, helper) {
        helper.selectAgreementVerification(component, "Email", null);
    },
    
    onAgreementKbaVerificationSelection : function(component, event, helper) {
        helper.selectAgreementVerification(component, "KBA", null);
    },
    
    onAgreementSocialVerificationSelection : function(component, event, helper) {
        helper.selectAgreementVerification(component, "Social", null);
    },
    
    onAgreementPasswordVerificationSelection : function(component, event, helper) {
        helper.selectAgreementVerification(component, "Password", null);
    },
    
    onAgreementEmailInternalVerificationSelection : function(component, event, helper) {
        helper.selectAgreementVerification(component, "Email", "Internal");
    },
    
    onAgreementKbaInternalVerificationSelection : function(component, event, helper) {
        helper.selectAgreementVerification(component, "KBA", "Internal");
    },
    
    onAgreementSocialInternalVerificationSelection : function(component, event, helper) {
        helper.selectAgreementVerification(component, "Social", "Internal");
    },
    
    onAgreementPasswordInternalVerificationSelection : function(component, event, helper) {
        helper.selectAgreementVerification(component, "Password", "Internal");
    },
    
    onAgreementEmailExternalVerificationSelection : function(component, event, helper) {
        helper.selectAgreementVerification(component, "Email", "External");
    },
    
    onAgreementKbaExternalVerificationSelection : function(component, event, helper) {
        helper.selectAgreementVerification(component, "KBA", "External");
    },
    
    onAgreementSocialExternalVerificationSelection : function(component, event, helper) {
        helper.selectAgreementVerification(component, "Social", "External");
    },
    
    onAgreementPasswordExternalVerificationSelection : function(component, event, helper) {
        helper.selectAgreementVerification(component, "Password", "External");
    },
    
    setAgreementViewPasswordToggleEnable : function(component, event, helper) {
        helper.setAgreementViewPasswordProcess(component, event, false);
    },
    
    setAgreementViewPassword : function(component, event, helper) {
        helper.setAgreementViewPasswordProcess(component, event, true);
    },
    
    setAgreementSignPasswordToggleEnable : function(component, event, helper) {
        helper.setAgreementSignPasswordProcess(component, event, false);
    },
    
    setAgreementSignPassword : function(component, event, helper) {
        helper.setAgreementSignPasswordProcess(component, event, true);
    },
   
    setRecipientSignPasswordProcess : function(component, event, helper) {
        helper.setRecipientSignPasswordProcess(component, event, true);
    },
    
    onSenderSignsClick : function(component, event, helper) {
        var isSent = component.get("v.isSent");
        var settingsWrapper = component.get("v.settingsWrapper");
        if( isSent || helper.getFieldValue(component, settingsWrapper.customSettings, "Read_Only_Sender_Signs__c") ) {
            return;
        }
        
        var agreementWrapper = component.get("v.agreementWrapper");
        
        if( component.get("v.agreementSenderSigns") ) {
            agreementWrapper.agreementSenderSigns = "Sign Last";
        } else {
            agreementWrapper.agreementSenderSigns = null;   
        }
          
        component.set("v.agreementWrapper", agreementWrapper);
    },
    
    toggleSenderSigns : function(component, event, helper) {
        var isSent = component.get("v.isSent");
        if( isSent ) {
            return;
        }
        
        helper.toggleElemVisibility("senderSignsDropdown", component);
    },
    
    selectSenderSignsOrder : function(component, event, helper) {
        var signingOrder = event.target.dataset.order;
        
        var agreementWrapper = component.get("v.agreementWrapper");
        
        agreementWrapper.agreementSenderSigns = signingOrder;
        
        if( agreementWrapper.agreementSenderSigns == "Sign First" ) {
            agreementWrapper.agreementSenderSignsLabel = $A.get("$Label.echosign_dev1.Agreement_Editor_Sign_First_Label ");
        } else if( agreementWrapper.agreementSenderSigns == "Sign Last" ) {
            agreementWrapper.agreementSenderSignsLabel = $A.get("$Label.echosign_dev1.Agreement_Editor_Sign_Last_Label ");
        }
        
        component.set("v.agreementWrapper", agreementWrapper);
        //In mobile it is getting changed to old value after click.
        component.set("v.agreementWrapper.agreementSenderSigns", signingOrder);
        helper.toggleElemVisibility("senderSignsDropdown", component);
        helper.refreshPage(component);
    },
    
    deleteSenderSigns : function(component, event, helper) {
        var agreementWrapper = component.get("v.agreementWrapper");
        
        agreementWrapper.agreementSenderSigns = null;
        
        component.set("v.agreementSenderSigns", false);
        component.set("v.agreementWrapper", agreementWrapper);
    },
    
    setRecipientEmail : function(component, event, helper) {
        var targetId = "recipientEmailInput";
        var recipientIndex = helper.getNestedOrderValue(event);
        var agreementWrapper = component.get("v.agreementWrapper");
        var recipientWrapper = agreementWrapper.recipientWrappers[recipientIndex];
        var email = document.getElementById(targetId + recipientIndex).value;
        recipientWrapper.email = email;
    },
    
    searchRecipient : function(component, event, helper) {
        var recipientIndex = helper.getNestedOrderValue(event);

        if( !recipientIndex ) {
            return;
        }

        component.set("v.selectedRecipientIndex", recipientIndex);
        
        var targetId = "recipientInputLookup";

        var searchResultsRecordId = "recipientSearchResults";
        
        var agreementWrapper = component.get("v.agreementWrapper");
        var recipientWrapper = agreementWrapper.recipientWrappers[recipientIndex];
        var recipientType = helper.getFieldValue(component, recipientWrapper.recipient, "Recipient_Type__c");
        var searchKey = document.getElementById(targetId + recipientIndex).value;
        helper.searchSObjects(component, helper, targetId, recipientType, searchResultsRecordId, recipientIndex, searchKey);
    },
    searchRecipientFromMobile : function(component, event, helper){
        var recipientIndex = component.get("v.selectedRecipientIndex");  

        if( !recipientIndex ) {
            return;
        }

        /*component.set("v.selectedRecipientIndex", recipientIndex);*/
        
        var targetId = "recipientInputLookupOnMobile";

        var searchResultsRecordId = "recipientSearchResultsOnMobile";
        
        var agreementWrapper = component.get("v.agreementWrapper");
        var recipientWrapper = agreementWrapper.recipientWrappers[recipientIndex];
        var recipientType = helper.getFieldValue(component, recipientWrapper.recipient, "Recipient_Type__c");
        
        helper.searchSObjects(component, helper, targetId, recipientType, searchResultsRecordId, recipientIndex);
    },
    
    searchReplaceRecipient : function(component, event, helper) {
        var targetId = "replaceRecipientInputLookup";
        var searchResultsRecordId = "replaceRecipientSearchResults";
        component.get("v.isMobile") ? searchResultsRecordId = "replaceRecipientSearchResultsOnMobile" : searchResultsRecordId = "replaceRecipientSearchResults";
        var recipientWrapper = component.get("v.replacementRecipientWrapper");
        var recipientType = helper.getFieldValue(component, recipientWrapper.recipient, "Recipient_Type__c");
        
        helper.searchSObjects(component, helper, targetId, recipientType, searchResultsRecordId);
    },
    
    selectPostSignUrlProtocol  : function(component, event, helper) {
        var selectedProtocol = event.target.dataset.order;
        
        var agreementWrapper = component.get("v.agreementWrapper");
        agreementWrapper.agreementPostSignUrlProtocol = selectedProtocol;
        component.set("v.agreementWrapper", agreementWrapper);
        
        helper.toggleElemVisibility("postSignUrlProtocolDropdown", component);
    },
    
    selectAgreementReminder : function(component, event, helper) {
        var selectedReminder = event.target.dataset.order;
        
        component.set("v.agreementReminder", selectedReminder);
        if( selectedReminder == "Every Day, Until Signed" ) {
            component.set("v.agreementReminderLabel", $A.get("$Label.echosign_dev1.Agreement_Editor_Reminder_Every_Day_Label"));         
        } else if( selectedReminder == "Every Week, Until Signed" ) {
            component.set("v.agreementReminderLabel", $A.get("$Label.echosign_dev1.Agreement_Editor_Reminder_Every_Week_Label"));
        } else {
            component.set("v.agreementReminderLabel", $A.get("$Label.echosign_dev1.Agreement_Editor_Reminder_Never_Label"));
        }
        
        helper.toggleElemVisibility("reminderDropdown", component);
    },
    
    selectAgreementLanguage : function(component, event, helper) {
        var selectedLanguage = event.target.dataset.order;
        
        component.set("v.agreementLanguage", selectedLanguage);
        
        var schemaWrapper = component.get("v.schemaWrapper");
        
        for( var i = 0; i < schemaWrapper.agreementLanguageOptions.length; i++ ) {
            if( schemaWrapper.agreementLanguageOptions[i].value == selectedLanguage ) {
                component.set("v.agreementLanguageLabel", schemaWrapper.agreementLanguageOptions[i].label);
                break;
            }
        }
        
        helper.toggleElemVisibility("languageDropdown", component);
    },
    
    closeAccountDialog : function(component, event, helper){
        helper.hideElemVisibility("accountSearchResultsMobile", component);
        var disableScrolling = false;
        helper.backgroundScrolling(component, disableScrolling);
    },
    
    closeOpportunityDialog : function(component, event, helper){
        helper.hideElemVisibility("opportunitySearchResultsMobile", component);
        var disableScrolling = false;
        helper.backgroundScrolling(component, disableScrolling);
    },
    
    closeContractDialog : function(component, event, helper){
        helper.hideElemVisibility("contractSearchResultsMobile", component);
        var disableScrolling = false;
        helper.backgroundScrolling(component, disableScrolling);
    },
    
    selectAccountSearchResult : function(component, event, helper) {
        var selectedResultRecordId = event.target.dataset.order;
        helper.setAgreementParentSearchResult(component, selectedResultRecordId, "account");
        var disableScrolling = false;
        helper.backgroundScrolling(component, disableScrolling);
    },
    
    selectOppSearchResult : function(component, event, helper) {
        var selectedResultRecordId = event.target.dataset.order;
        helper.setAgreementParentSearchResult(component, selectedResultRecordId, "opportunity");
        var disableScrolling = false;
        helper.backgroundScrolling(component, disableScrolling);
    },
    
    selectContractSearchResult : function(component, event, helper) {
        var selectedResultRecordId = event.target.dataset.order;
        helper.setAgreementParentSearchResult(component, selectedResultRecordId, "contract");
        var disableScrolling = false;
        helper.backgroundScrolling(component, disableScrolling);
    },
    
    openAccountDialog : function(component, event, helper) {
        var searchItemWrappers = new Array();
        component.set("v.searchItemWrappers", searchItemWrappers);
        helper.showElemVisibility("accountSearchResultsMobile", component);
        var disableScrolling = true;
        helper.backgroundScrolling(component, disableScrolling);
    },
    
    openOppDialog : function(component, event, helper) {
        var searchItemWrappers = new Array();
        component.set("v.searchItemWrappers", searchItemWrappers);
        helper.showElemVisibility("opportunitySearchResultsMobile", component);
        var disableScrolling = true;
        helper.backgroundScrolling(component, disableScrolling);
    },
    
    openContractDialog : function(component, event, helper) {
        var searchItemWrappers = new Array();
        component.set("v.searchItemWrappers", searchItemWrappers);
        helper.showElemVisibility("contractSearchResultsMobile", component);
        var disableScrolling = true;
        helper.backgroundScrolling(component, disableScrolling);
    },
    
    searchAccount : function(component, event, helper) {
        var targetId = "accountInputLookup";
        component.get("v.isMobile") ? targetId = "accountInputLookupMobile" : targetId = "accountInputLookup";
        var searchResultsRecordId = "accountSearchResults";
        component.get("v.isMobile") ? searchResultsRecordId = "accountSearchResultsMobile" : searchResultsRecordId = "accountSearchResults";
        var disableScrolling = true;
        helper.backgroundScrolling(component, disableScrolling);
        helper.searchSObjects(component, helper, targetId, "account", searchResultsRecordId);
    },
    
    searchOpp : function(component, event, helper) {
        var targetId = "oppInputLookup";
        component.get("v.isMobile") ? targetId = "oppInputLookupMobile" : targetId = "oppInputLookup";
        var searchResultsRecordId = "opportunitySearchResults";
        component.get("v.isMobile") ? searchResultsRecordId = "opportunitySearchResultsMobile" : searchResultsRecordId = "opportunitySearchResults";
        var disableScrolling = true;
        helper.backgroundScrolling(component, disableScrolling);
        helper.searchSObjects(component, helper, targetId, "opportunity", searchResultsRecordId);
    },
    
    searchContract : function(component, event, helper) {
        var targetId = "contractInputLookup";
        component.get("v.isMobile") ? targetId = "contractInputLookupMobile" : targetId = "contractInputLookup";
        var searchResultsRecordId = "contractSearchResults";
        component.get("v.isMobile") ? searchResultsRecordId = "contractSearchResultsMobile" : searchResultsRecordId = "contractSearchResults";
        var disableScrolling = true;
        helper.backgroundScrolling(component, disableScrolling);
        helper.searchSObjects(component, helper, targetId, "contract", searchResultsRecordId);
    },
    
    selectDayReminderOption : function(component, event, helper) {
        helper.selectDayReminderOption(component);
    },
    
    navToMyself : function(component, event, helper) {
        var agreementWrapper = component.get("v.agreementWrapper");
        helper.navigateToSObject(  component.get("v.sitePrefix") + "/" + agreementWrapper.contextUserId );
    },
    
    navToRecipient : function(component, event, helper) {
        var recipientIndex = helper.getNestedOrderValue(event);
        helper.navToRecipientRefRecord(component, recipientIndex);
    },
    
    navToReplaceRecipient : function(component, event, helper) {
        helper.navToReplaceRecipientRefRecord(component);
    },
    
    navToAccount : function(component, event, helper) {
        var agreementWrapper = component.get("v.agreementWrapper");
         helper.navigateToSObject( component.get("v.sitePrefix") + "/" + helper.getFieldValue(component, agreementWrapper.agreement, "Account__c") );
    },
    
    navToOpp : function(component, event, helper) {
        var agreementWrapper = component.get("v.agreementWrapper");
        
         helper.navigateToSObject( component.get("v.sitePrefix") + "/" + helper.getFieldValue(component, agreementWrapper.agreement, "Opportunity__c") );
    },
    
    navToContract : function(component, event, helper) {
        var agreementWrapper = component.get("v.agreementWrapper");
        
         helper.navigateToSObject( component.get("v.sitePrefix") + "/" + helper.getFieldValue(component, agreementWrapper.agreement, "Contract__c") );
    },
    
    viewSignedDocumentLink : function(component, event, helper) {
        var agreementWrapper = component.get("v.agreementWrapper");
        
        helper.navToUrl( helper.getFieldValue(component, agreementWrapper.agreement, "SignedPDF__c") );
    },
    
    selectRecipientSearchResult : function(component, event, helper) {
        var selectedResultRecordId = helper.getNestedOrderValue(event);
        var recipientIndex = component.get("v.selectedRecipientIndex");
        var elem = "recipientSearchResults";
        helper.setRecipientSearchResult(component, recipientIndex, selectedResultRecordId, elem);
    },
    
    selectRecipientSearchResultFromMobile : function(component, event, helper){
        var selectedResultRecordId = helper.getNestedOrderValue(event);
        var recipientIndex = component.get("v.selectedRecipientIndex");
        var elem = "recipientSearchResultsOnMobile";
        helper.setRecipientSearchResult(component, recipientIndex, selectedResultRecordId, elem);
        var disableScrolling = false;
		helper.backgroundScrolling(component, disableScrolling);
        helper.hideElemVisibility("recipientLookUpMobileDialog", component, recipientIndex);
        
    },
    
    selectReplaceRecipientSearchResult : function(component, event, helper) {
        var selectedResultRecordId = event.target.dataset.order;
        helper.setReplaceRecipientSearchResult(component, selectedResultRecordId);
    },
    
    selectUnsetRecipient : function(component, event, helper) {
        var recipientIndex = helper.getNestedOrderValue(event);
        helper.unsetRecipient(component, recipientIndex);
    },
    
    selectUnsetReplaceRecipient : function(component, event, helper) {
        helper.unsetReplaceRecipient(component);
    },
    
    selectUnsetAccount : function(component, event, helper) {
        helper.unsetAccount(component);
    },
    
    selectUnsetOpp : function(component, event, helper) {
        helper.unsetOpp(component);
    },
    
    selectUnsetContract : function(component, event, helper) {
        helper.unsetContract(component);
    },

    navigateToEvents : function(component, event, helper) {
        var agreementId = component.get("v.agreementId");
        sforce.one.navigateToURL('/apex/echosign_dev1__AgreementEvents?agreementId=' + agreementId + '&tab=Events');
        return;
    },
    
    navigateToSignedPdf: function(component, event, helper) {
        var agreementId = component.get("v.agreementId");
        sforce.one.navigateToURL('/apex/echosign_dev1__AgreementEvents?agreementId=' + agreementId + '&tab=SignedPdf');
        return;
    },
    
    /*,
    
    dismissAlert : function(component, evt, helper){      
        component.set("v.isSaved", false);
        component.set("v.isError", false);
        component.set("v.isNotProcessing", true);
    }*/
    
    /*Mobile specific changes*/
    selectCollapsedRecipientFeatures : function(component, event, helper){
        event.target.blur();
        
        var recipientIndex = event.currentTarget.dataset.order;  
        if( !recipientIndex ) {
            return;
        }
        component.set("v.selectedRecipientIndex", recipientIndex);
        var disableScrolling = true;
        helper.backgroundScrolling(component, disableScrolling);
        helper.toggleInputComponent(component, "collapsedRecipientFeature");
    },
    
    closeCollapsedFeaturesFromMobile : function(component, event, helper){
        var disableScrolling = false;
        helper.backgroundScrolling(component, disableScrolling);
        helper.hideElemVisibility("collapsedRecipientFeature", component);   
    },
    
    displayRecipientVerificationOptions : function(component, event, helper){
        helper.showElemVisibility("recipientVerificationOptions", component);
        helper.hideElemVisibility("verificationPasswordInputForm", component);
        helper.hideElemVisibility("verificationPhoneInputForm", component);
    },
    onRecipientEmailVerificationSelectionFromMobile : function(component, event, helper){
        var recipientIndex = component.get("v.selectedRecipientIndex");
        var isMobile = true;
        /*No Div is closed while selecting verification unlike desktop and tablet.*/
        helper.selectRecipientVerification(component, recipientIndex, "", "Email");
        helper.storeRecipientVerification(component, recipientIndex, isMobile);
        var disableScrolling = false;
        helper.backgroundScrolling(component, disableScrolling);
    },
    onRecipientPasswordVerificationSelectionFromMobile : function(component, event, helper) {
        var recipientIndex = component.get("v.selectedRecipientIndex");
        helper.selectRecipientVerification(component, recipientIndex, "recipientVerificationOptions", "Password");
        helper.showElemVisibility("verificationPasswordInputForm", component);
    },
    onRecipientKbaVerificationSelectionFromMobile : function(component, event, helper){
        var recipientIndex = component.get("v.selectedRecipientIndex");
        var isMobile = true;
        /*No Div is closed while selecting verification unlike desktop and tablet.*/
        helper.selectRecipientVerification(component, recipientIndex, "", "KBA");
        helper.storeRecipientVerification(component, recipientIndex, isMobile);
        var disableScrolling = false;
        helper.backgroundScrolling(component, disableScrolling);
        helper.popNotificationMessage(component, $A.get("$Label.echosign_dev1.kba_verification_confirmation"));
    },
    onRecipientSocialVerificationSelectionFromMobile: function(component, event, helper){
        var recipientIndex = component.get("v.selectedRecipientIndex");
        var isMobile = true;
        /*No Div is closed while selecting verification unlike desktop and tablet.*/
        helper.selectRecipientVerification(component, recipientIndex, "", "Social");
        helper.storeRecipientVerification(component, recipientIndex, isMobile);
        var disableScrolling = false;
        helper.backgroundScrolling(component, disableScrolling);
        helper.popNotificationMessage(component, $A.get("$Label.echosign_dev1.social_verification_confirmation"));
    },
    onRecipientPhoneVerificationSelectionFromMobile : function(component, event, helper) {
        var recipientIndex = component.get("v.selectedRecipientIndex");
        helper.showElemVisibility("verificationPhoneInputForm", component);
        helper.selectRecipientVerification(component, recipientIndex, "recipientVerificationOptions", "Phone");
    },
     toggleRecipientVerificationCountryFromMobile : function(component, event, helper) {
        helper.toggleInputComponent(component, "recipientVerificationCountryDropdownMobile");
    },
    onSelectRecipientCountryCode : function(component, event, helper) {
        var countryCode = event.target.dataset.order;
        var recipientIndex = event.target.parentElement.dataset.order;
        helper.selectRecipientCountryCode(component, countryCode, recipientIndex, "recipientVerificationCountryDropdownMobile");
    },
    openRecipientLookUpModalForMobile : function(component, event, helper){
        var recipientIndex = helper.getNestedOrderValue(event);  
        if( !recipientIndex ) {
            return;
        }
        component.set("v.selectedRecipientIndex", recipientIndex);
        var disableScrolling = true;
        helper.backgroundScrolling(component, disableScrolling);
        helper.showElemVisibility("recipientLookUpMobileDialog", component, recipientIndex);
    },
    closeContactModalForMobile : function(component, event, helper){
        var recipientIndex = component.get("v.selectedRecipientIndex");
        var disableScrolling = false;
		helper.backgroundScrolling(component, disableScrolling);
        helper.hideElemVisibility("recipientSearchResultsOnMobile", component, recipientIndex);
        helper.hideElemVisibility("recipientLookUpMobileDialog", component, recipientIndex);
    },
    setBackgroundPosition : function(component, event, helper){
        var disableScrolling = false;
        helper.backgroundScrolling(component, disableScrolling);
    },
    
    toggleAgreementOptions : function(component, event, helper){
        helper.toggleInputComponent(component, "CollapsedAgreementOptionButton");
        helper.toggleInputComponent(component, "ExpandedAgreementOptionButton");
        helper.toggleInputComponent(component, "AgreementOptions");
    }
})