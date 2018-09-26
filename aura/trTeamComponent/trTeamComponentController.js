({
  doInit: function(component, event, helper) {
    var action = component.get('c.getTaskBoardURLForUser');
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === 'SUCCESS') {
        component.set(
          'v.iframeURL',
          response
            .getReturnValue()
            .replace('TASKRAY__trtaskboard', 'TASKRAY__trTeamAction') +
            '?Id=' +
            component.get('v.recordId')
        );
        component.set('v.iframeLoaded', false);
      }
    });
    $A.enqueueAction(action);
  },
  iframeLoaded: function(component, event, helper) {
    component.set('v.iframeLoaded', true);
  }
});