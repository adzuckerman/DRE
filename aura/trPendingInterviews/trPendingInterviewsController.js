({
  doInit: function(component, event, helper) {
    if (component.get('v.inLightningOut')) {
      window.forceCORSIcons = true;
    }
    helper.getInterviews(component, event, helper);
  },
  handleComponentEvent: function(component, event, helper) {
    var payload = event.getParam('payload');
    if (event.getParam('actionType') === 'completeInterview') {
      helper.completeInterview(payload.Id, component, event, helper);
      event.stopPropagation();
    }
  }
});