({
  reInit: function(component, event, helper) {
    helper.clearSelection(component, event, helper);
  },
  handleKeyUp: function(component, event, helper) {
    var timer = component.get('v.timer');
    if (timer) {
      clearTimeout(timer);
    }
    timer = window.setTimeout(
      $A.getCallback(function() {
        helper.fetchSearchResults(component, event, helper);
      }),
      650
    );
    component.set('v.timer', timer);
  },
  handleFocus: function(component, event, helper) {
    component.set('v.searchIsFocused', true);
    helper.fetchSearchResults(component, event, helper);
  },
  handleBlur: function(component, event, helper) {
    //Timeout to allow the selection to occur without destroying
    window.setTimeout(
      $A.getCallback(function() {
        component.set('v.searchIsFocused', false);
      }),
      150
    );
  },
  handleResultClick: function(component, event, helper) {
    var resultId = event.currentTarget.id;
    var results = component.get('v.searchResults');
    var result = results.find(function(resultObj) {
      return resultObj.Id === resultId;
    });
    component.set('v.selectedSearchResult', result);
    component.set('v.selectedPills', [{ label: result.Name }]);
    component.set('v.searchResults', []);
    var selectionEvent = component.getEvent('trGenericEvent');
    selectionEvent.setParams({
      actionType: 'lookupSelected',
      payload: {
        selectedRecord: result
      }
    });
    selectionEvent.fire();
  },
  handleClearSelection: function(component, event, helper) {
    helper.clearSelection(component, event, helper);
  }
});