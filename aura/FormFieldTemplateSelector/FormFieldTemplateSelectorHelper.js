({
    initAllTemplates : function(component) {
        var self = this;
        
        self.initTemplates(component);
    },
    
    initTemplates : function(component) {
        var action = component.get("c.queryFormFieldTemplates");
        
        action.setCallback(this, function(a) {
            var libraryDocumentWrappers = a.getReturnValue();
            
            component.set("v.libraryDocumentWrappers", libraryDocumentWrappers);
            component.set("v.isLoading", false);
        });
        
        $A.enqueueAction(action);
    },
    
    selectTemplates : function(component) {
        var libraryDocumentWrappers = component.get("v.libraryDocumentWrappers");
        var selectedDocumentId = component.get("v.selectedDocumentId");
        
        var newSelectedDocumentId;
        
        for(var i = 0; i < libraryDocumentWrappers.length; i++) {
            var libraryDocumentWrapper = libraryDocumentWrappers[i];
            
            var isSelected = libraryDocumentWrapper.isSelected;

            if( !isSelected ) {
                continue;
            }
            
            if( isSelected && !selectedDocumentId ) {
                newSelectedDocumentId = libraryDocumentWrapper.documentKey;
                libraryDocumentWrapper.isSelected = true;
            	break;
            }
            
            if( libraryDocumentWrapper.isSelected && selectedDocumentId == libraryDocumentWrapper.documentKey ) {
                libraryDocumentWrapper.isSelected = false;
            } else if( isSelected && selectedDocumentId != libraryDocumentWrapper.documentKey ) {
                newSelectedDocumentId = libraryDocumentWrapper.documentKey;
                libraryDocumentWrapper.isSelected = true;
            }
        }
        
        component.set("v.libraryDocumentWrappers", libraryDocumentWrappers);
        component.set("v.selectedDocumentId", newSelectedDocumentId);
    },
    
    cancelAddFiles : function(component) {
        component.set("v.isLoading", true);
        
        var compEvent = component.getEvent("notifyTemplatesSelected");
        compEvent.setParams({"isCanceled" : true });
        compEvent.fire();
    },

    addTemplates : function(component) {
        component.set("v.isLoading", true);

        var libraryDocumentWrappers = component.get("v.libraryDocumentWrappers");
        
        var selectedTemplateWrappers = new Array();
        var templateComponents = component.find("templateSelected");

        for(var i = 0; i < libraryDocumentWrappers.length; i++) {
            var libraryDocumentWrapper = libraryDocumentWrappers[i];
            var isSelected = libraryDocumentWrapper.isSelected;

            if( !isSelected ) {
                continue;
            }
            
            selectedTemplateWrappers.push(libraryDocumentWrapper);
        }
        
        var compEvent = component.getEvent("notifyTemplatesSelected");
        
        compEvent.setParams({"selectedTemplateWrappers" : selectedTemplateWrappers });
        
        compEvent.fire();
    },
    
    searchTemplate : function(component, searchTerm) {
        var action = component.get("c.queryFormFieldTemplates");
        action.setParams({
            "name" : searchTerm
        });
        
        action.setCallback(this, function(a) {
            var libraryDocumentWrappers = a.getReturnValue();
            
            component.set("v.libraryDocumentWrappers", libraryDocumentWrappers);
        });
        
        $A.enqueueAction(action);
    }
})