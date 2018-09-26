({
    initAllDocuments : function(component) {
        var self = this;
        
        var settingsWrapper = component.get("v.settingsWrapper");
        
        if( !settingsWrapper.customSettings.echosign_dev1__Disable_Content_Agreement_Attachments__c ) {
            self.initContents(component);
        }
        
        if( !settingsWrapper.customSettings.echosign_dev1__Disable_Attach_Agreement_Attachments__c ) {
            self.initDocuments(component);
        }
        
        if( settingsWrapper.customSettings.echosign_dev1__Enable_Library_Agreement_Attachments__c ) {
            self.initLibraryDocuments(component);
        }

        var isContentEnabled = component.get("v.isContentEnabled");

        if( ( !isContentEnabled || settingsWrapper.customSettings.echosign_dev1__Disable_Content_Agreement_Attachments__c ) &&
            !settingsWrapper.customSettings.echosign_dev1__Disable_Attach_Agreement_Attachments__c ) {
            component.set("v.isDocumentSelected", true);
        } else if( isContentEnabled && !settingsWrapper.customSettings.echosign_dev1__Disable_Content_Agreement_Attachments__c ) {
            component.set("v.isContentSelected", true);
        } else {
            component.set("v.isLibrarySelected", true);
        }
        
        if( settingsWrapper.customSettings.echosign_dev1__Disable_Content_Agreement_Attachments__c &&
            settingsWrapper.customSettings.echosign_dev1__Disable_Attach_Agreement_Attachments__c &&
           !settingsWrapper.customSettings.echosign_dev1__Enable_Library_Agreement_Attachments__c ) {
            component.set("v.isLoading", false);
        }
    },

    initAfterPageLoaded : function(component) {

    },
    
    initContents : function(component) {
        var action = component.get("c.queryContentDocuments");
        
        action.setCallback(this, function(a) {
            var contentWrappers = a.getReturnValue();
            
            component.set("v.isContentEnabled", contentWrappers != null);
            component.set("v.contentWrappers", contentWrappers);
            component.set("v.isLoading", false);
        });
        
        $A.enqueueAction(action);
    },
    
    initDocuments : function(component) {
        var action = component.get("c.queryDocuments");
        
        action.setCallback(this, function(a) {
            var documentWrappers = a.getReturnValue();
            
            component.set("v.documentWrappers", documentWrappers);
            component.set("v.isLoading", false);
        });
        
        $A.enqueueAction(action);
    },
    
    initLibraryDocuments: function(component) {
        var action = component.get("c.queryLibraryDocuments");
        
        action.setCallback(this, function(a) {
            var libraryDocumentWrappers = a.getReturnValue();
            
            component.set("v.libraryDocumentWrappers", libraryDocumentWrappers);
            component.set("v.isLoading", false);
        });
        
        $A.enqueueAction(action);
    },
    
    storeFilesUploaded : function(component) {
        var self = this;
        
        //var files = document.getElementById("files").files;
        var files = component.find("files").getElement().files;
        
        var reader = new FileReader();

        for (var i = 0, f; f = files[i]; i++) {
            reader.onload = (function(theFile) {
                return function(e) {
                    var uploadedFileWrapper = new Object();
                    
                    uploadedFileWrapper.name = theFile.name;
                    uploadedFileWrapper.type = self.getDocType( theFile.type );
                    uploadedFileWrapper.contentType = theFile.type;
                    uploadedFileWrapper.content = window.btoa( reader.result );
                    
                    if( uploadedFileWrapper.content.length > 990000 ) {
                        component.set("v.errorMessage", $A.get("$Label.echosign_dev1.Agreement_Editor_Large_File_Upload_Error"));
                        component.set("v.isLoading", false);
                        return;
                    }
                    
                    var uploadedFileWrappers = component.get("v.uploadedFileWrappers");
                    
                    uploadedFileWrappers.push(uploadedFileWrapper);
                    
                    component.set("v.uploadedFileWrappers", uploadedFileWrappers);
                    //component.set("v.isLoading", false);
                    var isMobile = false;
                    self.addFiles(component, isMobile);
                };
            })(f);
            
            reader.onloadstart = function(e) {
                component.set("v.isLoading", true);
            };
            
            reader.onabort = function(e) {
                component.set("v.isLoading", false);
            };
            
            reader.onerror  = function(e) {
                component.set("v.isLoading", false);
            };
            
            reader.readAsBinaryString(f);
        }
    },
    
    cancelAddFiles : function(component) {
        component.set("v.isLoading", true);
        
        var compEvent = component.getEvent("notifyDocumentsSelected");
        compEvent.setParams({"isCanceled" : true });
        compEvent.fire();
    },
    
    addFiles : function(component, isMobile) {
        component.set("v.isLoading", true);
        
        var uploadedFileWrappers = component.get("v.uploadedFileWrappers");
        var contentWrappers = component.get("v.contentWrappers");
        var documentWrappers = component.get("v.documentWrappers");
        var libraryDocumentWrappers = component.get("v.libraryDocumentWrappers");
        
        var selectedContentWrappers = new Array();
        var selectedDocumentWrappers = new Array();
        var selectedLibraryDocumentWrappers = new Array();
        
        for( var i = 0; i < contentWrappers.length; i++ ) { 
          	var contentWrapper = contentWrappers[i];
            var isSelected = contentWrapper.isSelected;
            
            if( !isSelected ) {
            	continue;
            }
                
			selectedContentWrappers.push(contentWrapper);
        }
        
        for( var i = 0; i < documentWrappers.length; i++ ) { 
          	var documentWrapper = documentWrappers[i];
            var isSelected = documentWrapper.isSelected;
            
            if( !isSelected ) {
            	continue;
            }
                
			selectedDocumentWrappers.push(documentWrapper);
        }

        for( var i = 0; i < libraryDocumentWrappers.length; i++ ) { 
          	var libraryDocumentWrapper = libraryDocumentWrappers[i];
            var isSelected = libraryDocumentWrapper.isSelected;
            
            if( !isSelected ) {
            	continue;
            }
                
			selectedLibraryDocumentWrappers.push(libraryDocumentWrapper);
        }
        
        var compEvent = component.getEvent("notifyDocumentsSelected");
        
        compEvent.setParams({"uploadedFileWrappers" : uploadedFileWrappers });
        compEvent.setParams({"selectedContentWrappers" : selectedContentWrappers });
        compEvent.setParams({"selectedDocumentWrappers" : selectedDocumentWrappers });
        compEvent.setParams({"selectedLibraryDocumentWrappers" : selectedLibraryDocumentWrappers });
        
        compEvent.fire();
    },
    
    searchContent : function(component, searchTerm) {
        var action = component.get("c.queryContentDocuments");
        action.setParams({
            "name" : searchTerm
        });
        
        action.setCallback(this, function(a) {
            var contentWrappers = a.getReturnValue();
            
            component.set("v.contentWrappers", contentWrappers);
        });
        
        $A.enqueueAction(action);
    },
    
    searchDocument : function(component, searchTerm) {
        var action = component.get("c.queryDocuments");
        action.setParams({
            "name" : searchTerm
        });
        
        action.setCallback(this, function(a) {
            var documentWrappers = a.getReturnValue();
            
            component.set("v.documentWrappers", documentWrappers);
        });
        
        $A.enqueueAction(action);
    },
    
    searchLibraryDocument : function(component, searchTerm) {
        var action = component.get("c.queryLibraryDocuments");
        action.setParams({
            "name" : searchTerm
        });
        
        action.setCallback(this, function(a) {
            var libraryDocumentWrappers = a.getReturnValue();
            
            component.set("v.libraryDocumentWrappers", libraryDocumentWrappers);
        });
        
        $A.enqueueAction(action);
    },
    
    openDocument : function(documentId) {
        var self = this;
   
        self.navToUrl( "/" + documentId );
    },
    
    openTab : function(component, tabIndex) {
        var self = this;
        
        self.removeClassElem(component, "tab-content-item-link", "esign-tab-selected-link");
        
        var tabIndexInt = parseInt(tabIndex);
        
        if( tabIndexInt == 1 ) {
            component.set("v.isContentSelected", true);
            component.set("v.isDocumentSelected", false);
            component.set("v.isLibrarySelected", false);
            
            self.activateElem(component, "tab-content-item");
            self.deactivateElem(component, "tab-document-item");
            self.deactivateElem(component, "tab-library-item");
        } else if( tabIndexInt == 2 ) {
            component.set("v.isContentSelected", false);
            component.set("v.isDocumentSelected", true);
            component.set("v.isLibrarySelected", false);
            
            self.deactivateElem(component, "tab-content-item");
            self.activateElem(component, "tab-document-item");
            self.deactivateElem(component, "tab-library-item");
        } else if( tabIndexInt == 3 ) {
            component.set("v.isContentSelected", false);
            component.set("v.isDocumentSelected", false);
            component.set("v.isLibrarySelected", true);
            
            self.deactivateElem(component, "tab-content-item");
            self.deactivateElem(component, "tab-document-item");
            self.activateElem(component, "tab-library-item");
        }
    },
    
    openTabFromMobile : function(component, tabIndex){
        var self = this;
        
        var tabIndexInt = parseInt(tabIndex);
        if( tabIndexInt == 1 ) {
            component.set("v.isContentSelected", true);
            component.set("v.isDocumentSelected", false);
            component.set("v.isLibrarySelected", false);
            
            self.showElemVisibility(component, "contentItem");
            self.hideElemVisibility(component, "itemsList");
            self.hideElemVisibility(component, "documentItem");
            self.hideElemVisibility(component, "libraryItem"); 
            //self.activateElem(component, "tab-content-item-on-mobile");
            //self.deactivateElem(component, "tab-document-item-on-mobile");
            //self.deactivateElem(component, "tab-library-item-on-mobile");
        }
        else if( tabIndexInt == 2 ) {
            component.set("v.isContentSelected", false);
            component.set("v.isDocumentSelected", true);
            component.set("v.isLibrarySelected", false);
            
            self.showElemVisibility(component, "documentItem");
            self.hideElemVisibility(component, "itemsList"); 
            self.hideElemVisibility(component, "contentItem"); 
            self.hideElemVisibility(component, "libraryItem"); 
        }
         else if( tabIndexInt == 3 ) {
            component.set("v.isContentSelected", false);
            component.set("v.isDocumentSelected", false);
            component.set("v.isLibrarySelected", true);
            self.showElemVisibility(component, "libraryItem");
            self.hideElemVisibility(component, "documentItem");
            self.hideElemVisibility(component, "itemsList"); 
            self.hideElemVisibility(component, "contentItem"); 
         }
    },
    
    removeClassElem : function(component, elemId, className) {
        var cmpTarget = component.find(elemId);

        if( !cmpTarget ) {
            return;
        }

        $A.util.addClass(cmpTarget, className);
    },
    
    deactivateElem : function(component, elemId) {
        var cmpTarget = component.find(elemId);

        if( !cmpTarget ) {
            return;
        }

        $A.util.removeClass(cmpTarget, "slds-active");
    },
    
    activateElem : function(component, elemId) {
        var cmpTarget = component.find(elemId);

        if( !cmpTarget ) {
            return;
        }

        $A.util.addClass(cmpTarget, "slds-active");
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
    
    navToUrl : function(url) {
        var self = this;
        
        window.open(url);
    },
    
    getDocType : function(contentType) {
        var docType = null;
        
        if( !contentType ) {
            docType = 'unknown';
        } else if( contentType.includes ('pdf') ) {
            docType = 'pdf';
        } else if( contentType.includes('doc') || contentType.includes('docx') || contentType.includes('word') ) {
            docType = 'word';
        } else if( contentType.includes('txt') || contentType.includes('log') ) {
            docType = 'txt';
        } else if( contentType.includes('xls') || contentType.includes('xlsx') ) {
            docType = 'excel';
        } else if( contentType.includes('ppt') || contentType.includes('pptx') ) {
            docType = 'ppt';
        } else if( contentType.includes('xml') ) {
            docType = 'xml';
        } else if( contentType.includes('png') || contentType.includes('img') || contentType.includes('jpeg') || contentType.includes('jpg') || contentType.includes('gif') || contentType.includes('image') ) {
            docType = 'image';
        } else {
            docType = contentType;
        }
        
        return docType;
    }
})