({
    doInit: function(component, event, helper) {
        helper.renderFileUploadCmp(component, event, helper, component.get("v.recordId"));
        helper.doInit(component, event, helper, component.get("v.recordId"));
    },
    doRender: function(component, event, helper) {
        $A.get("e.force:refreshView").fire(); 
        var parentId = event.getParam("parentId");
        helper.renderFileUploadCmp(component, event, helper, parentId);
        helper.doInit(component, event, helper, parentId);
    },
})