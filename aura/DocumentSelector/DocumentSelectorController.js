({    
    doInit : function(component, event, helper) {
        helper.initAllDocuments(component);
    },
    
    onFilesUploaded : function(component, event, helper) {
        helper.storeFilesUploaded(component);
    },
    
    openDocument : function(component, event, helper) {
        var documentId = event.target.dataset.order;
        helper.openDocument(documentId);
    },
     
    onCancelAddFiles : function(component, event, helper) {
        helper.cancelAddFiles(component);
    },
    
    OpenAddFilesOptions : function(component, event, helper){
        helper.hideElemVisibility(component, "contentItem");
        helper.hideElemVisibility(component, "documentItem");
        helper.hideElemVisibility(component, "libraryItem");
        helper.showElemVisibility(component, "itemsList");
    },
    
    onAddFiles : function(component, event, helper) {
        var isMobile = false;
        helper.addFiles(component, isMobile);
    },
     
    onAddFilesFromMobile : function(component, event, helper) {
        var isMobile = true;
        helper.addFiles(component, isMobile);
    },
    
    onSearchContent : function(component, event, helper) {
        var searchTerm = component.get("v.contentSearchTerm");
        helper.searchContent(component, searchTerm);
    },
    
    onSearchDocument : function(component, event, helper) {
        var searchTerm = component.get("v.documentSearchTerm");
        helper.searchDocument(component, searchTerm);
    },
    
    onSearchLibraryDocument : function(component, event, helper) {
        var searchTerm = component.get("v.libraryDocumentSearchTerm");
        helper.searchLibraryDocument(component, searchTerm);
    },
    
    openTab : function(component, event, helper) {
        var tabIndex = event.target.dataset.order;
        helper.openTab(component, tabIndex);
    },
    
    openTabFromMobile : function(component, event, helper){
        var tabIndex = event.target.dataset.order;
        helper.openTabFromMobile(component, tabIndex);
    },
    
    dismissAlert : function(component, event, helper) {
        component.set("v.errorMessage", null);
    }
})