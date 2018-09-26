({    
    doInit : function(component, event, helper) {
        helper.initAllTemplates(component);
    },

    onCancelAddFiles : function(component, event, helper) {
        helper.cancelAddFiles(component);
    },
    
    onAddTemplates : function(component, event, helper) {
        helper.addTemplates(component);
    },
    
    onTemplateSelect : function(component, event, helper) {
        helper.selectTemplates(component);
    },
    
    onSearchTemplate : function(component, event, helper) {
        var searchTerm = component.get("v.templateSearchTerm");
        
        helper.searchTemplate(component, searchTerm);
    }
})