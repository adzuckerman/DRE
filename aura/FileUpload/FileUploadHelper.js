({    
    doInit: function(component, event, helper, parentId) {
        console.log('::doInit-->parentId='+parentId);
        
        var action = component.get("c.getFileList");
        action.setParams({
            "parentId": parentId
        });
 
        // set call back 
        action.setCallback(this, function(response) {            
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('::doInit-->lstFiles='+JSON.stringify(response.getReturnValue()));
                // store the response 
            	component.set("v.lstFiles",  response.getReturnValue());  
                // handel the response errors        
              } else if (state === "INCOMPLETE") {
                alert("From server: " + response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        // enqueue the action
        $A.enqueueAction(action);
    },
    
    renderFileUploadCmp: function(component, event, helper, parentId ){
        $A.createComponent("c:FileUploadPanel", {
            "parentId" : parentId
        }, function(newCmp) {
            if (component.isValid()) {
                component.set("v.body", newCmp);
            }
        });
	},

})