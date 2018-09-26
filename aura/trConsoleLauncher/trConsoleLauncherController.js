({
  openTab: function(component, event, helper) {
    var workspaceAPI = component.find('workspace');
    workspaceAPI
      .openTab({
        url: '/apex/TASKRAY__trtaskboard',
        focus: true
      })
      .then(function(response) {
        console.log(response);
        workspaceAPI
          .getEnclosingTabId()
          .then(function(tabId) {
            console.log(tabId);
            if (tabId) {
              workspaceAPI.closeTab({ tabId });
            }
          })
          .catch(function(error) {
            console.log(error);
          });
      })
      .catch(function(error) {
        console.log(error);
      });
  }
});