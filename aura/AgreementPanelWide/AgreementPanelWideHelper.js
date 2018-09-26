({
    initAgreementData : function(component, masterObjectRecordId, recordFieldName) {
        var masterObjectRecordId = component.get("v.recordId");
        var recordFieldName = component.get("v.recordFieldName");
        var agreementTemplateRecordIds = component.get("v.agreementTemplateRecordIds");
        var resultSize = 4;
        
        var action = component.get("c.getRecentAgreementData");
        action.setParams({
            "masterObjectRecordId" : masterObjectRecordId,
            "recordFieldName" : recordFieldName,
            "orderFieldName" : "LastModifiedDate",
            "resultSize" : resultSize,
            "agreementTemplateRecordIds" : agreementTemplateRecordIds
        });
        
        action.setCallback(this, function(a) {
            var recordAgreementDataResult = a.getReturnValue();
            
            component.set("v.recentResult", recordAgreementDataResult);
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },
    
    initSettings: function(component) {
        var action = component.get("c.getSettings");
        action.setCallback(this, function(a) {
            var settingsWrapper = a.getReturnValue();
            component.set("v.settingsWrapper", settingsWrapper);
        });
        $A.enqueueAction(action);
    },
    
    getNamespacePrefix : function(component) {
        return "echosign_dev1__";
    },
    
    createNewAgreement : function(component, agreementTemplateId) {
        var self = this;
        
        self.toggleElemVisibility(component, "newAgreementWideDropdown");
        
        var masterObjectRecordId = component.get("v.recordId");
        var agreementUrl = "/apex/" + self.getNamespacePrefix(component) + "AgreementEditor";
        
        if( agreementTemplateId != null ) {
            agreementUrl += ( "?templateId=" + agreementTemplateId + "&masterId=" + masterObjectRecordId );
        }
        
        self.navToUrl(agreementUrl);
        
        component.set("v.isLoading", false);
    },
    
    invokeAgreementAction : function(component, agreementId, actionName) {
        var self = this;
        
        self.hideElemVisibility(component, "agreementActionWideDropdown" + agreementId);
        
        var agreementUrl = "/apex/" + self.getNamespacePrefix(component) + "AgreementEditor?id=" + agreementId;
        
        if( actionName != "edit" ) {
            agreementUrl += ( "&onloadAction=" + actionName );
        }
        
        self.navToUrl(agreementUrl);
    },
    
    hideElemVisibility : function(component, elemId) {
        var cmpTarget = component.find(elemId);

        if( !cmpTarget ) {
            return;
        }

        $A.util.removeClass(cmpTarget, "slds-show");
        $A.util.addClass(cmpTarget, "slds-hide");
    },
     
    showElemVisibility : function(component, elemId) {
        var cmpTarget = component.find(elemId);

        if( !cmpTarget ) {
            return;
        }
        
        $A.util.removeClass(cmpTarget, "slds-hide");
        $A.util.addClass(cmpTarget, "slds-show");
    },
    
    toggleElemVisibility : function(component, elemId) {
        var cmpTarget = component.find(elemId);

        if( !cmpTarget ) {
            return;
        }
        
        $A.util.toggleClass(cmpTarget, "slds-show");
        $A.util.toggleClass(cmpTarget, "slds-hide");
    },
    
    toggleIterElemVisibility : function(component, topElemId, className, elemId) {
        var elem = component.find(topElemId).getElement();
        var elems = elem.getElementsByClassName(className);
        var elem;
        for( var i = 0; i < elems.length; i++ ) {
            if( elems[i].id == elemId ) {
                elem = elems[i];
            } else {
                $A.util.removeClass(elems[i], "slds-show");
                $A.util.addClass(elems[i], "slds-hide");
            }
        }
        
        if( elem == null ) {
            return;
        }
        
        $A.util.toggleClass(elem, "slds-show");
        $A.util.toggleClass(elem, "slds-hide");
    }, 
    
    navToUrl : function(url) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": url
        });
        urlEvent.fire();
    }
})