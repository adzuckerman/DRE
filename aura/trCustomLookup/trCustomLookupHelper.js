({
  fetchSearchResults: function(component, event, helper) {
    component.set('v.timer', null);
    component.set('v.searchRunning', true);
    component.set('v.searchRunning', false);
    var action = component.get('c.searchObjectsFromTypeahead');
    var actionParams = {
      currentSearchInputValue: component.get('v.searchString'),
      scope: component.get('v.scope'),
      template: component.get('v.template'),
      projectRecordTypeToSearch: component.get('v.projectRecordTypeToSearch'),
      searchParameters: component.get('v.searchParameters'),
      templateRestrictions: helper._getTemplateRestrictions(component)
    };
    action.setParams(actionParams);
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === 'SUCCESS') {
        var searchResults = response.getReturnValue();
        helper._buildDataForDropdown(searchResults, component);
      } else {
        helper.popErrorMessage(component, action);
      }
    });
    $A.enqueueAction(action);
  },
  _getTemplateRestrictions: function(component) {
    var templateRestrictionString = component.get('v.templateRestrictions');
    if (
      templateRestrictionString &&
      typeof templateRestrictionString === 'string'
    ) {
      var splitString = templateRestrictionString.split(',');
      return splitString;
    }
    return null;
  },
  _buildDataForDropdown: function(data, component) {
    var scope = component.get('v.scope');
    if (data === null) {
      component.set('v.searchResults', []);
    } else {
      if (scope === 'tasks') {
        data.forEach(function(searchResultObj) {
          searchResultObj['resultName'] = searchResultObj.Name;
          searchResultObj['parent'] = searchResultObj.TASKRAY__trTaskGroup__r
            ? searchResultObj.TASKRAY__trTaskGroup__r.Name
            : '';
          searchResultObj['gParent'] = searchResultObj.TASKRAY__Project__r
            ? searchResultObj.TASKRAY__Project__r.Name
            : '';
        });
      } else if (scope === 'checklistGroups') {
        data.forEach(function(searchResultObj) {
          searchResultObj['resultName'] = searchResultObj.Name;
          searchResultObj['parent'] = searchResultObj.TASKRAY__TaskForGroup__r
            ? searchResultObj.TASKRAY__TaskForGroup__r.Name
            : '';
          searchResultObj['gParent'] =
            searchResultObj.TASKRAY__TaskForGroup__r &&
            searchResultObj.TASKRAY__TaskForGroup__r.TASKRAY__trTaskGroup__r
              ? searchResultObj.TASKRAY__TaskForGroup__r.TASKRAY__trTaskGroup__r
                  .Name
              : '';
          searchResultObj['ggParent'] =
            searchResultObj.TASKRAY__TaskForGroup__r &&
            searchResultObj.TASKRAY__TaskForGroup__r.TASKRAY__Project__r
              ? searchResultObj.TASKRAY__TaskForGroup__r.TASKRAY__Project__r
                  .Name
              : '';
        });
      } else if (scope === 'taskGroups') {
        data.forEach(function(searchResultObj) {
          searchResultObj['resultName'] = searchResultObj.Name;
          searchResultObj['parent'] = searchResultObj.TASKRAY__Project__r
            ? searchResultObj.TASKRAY__Project__r.Name
            : '';
        });
      } else if (scope === 'projects') {
        data.forEach(function(searchResultObj) {
          searchResultObj['resultName'] = searchResultObj.Name;
          searchResultObj['parent'] =
            searchResultObj.TASKRAY__trTemplate__c === true
              ? $A.get('$Label.TASKRAY.TaskRay_ProjectTypeahead_TemplateLabel')
              : '';
        });
      } else if (scope === 'anySObject' || scope === 'owner') {
        data.forEach(function(searchResultObj) {
          searchResultObj['resultName'] = searchResultObj.Name;
        });
      }
      component.set('v.searchResults', data);
    }
  },
  popErrorMessage: function(component, action) {
    var errors = action.getError();
    var msg =
      errors &&
      errors[0] &&
      errors[0].pageErrors &&
      errors[0].pageErrors[0] &&
      errors[0].pageErrors[0] &&
      errors[0].pageErrors[0].message
        ? errors[0].pageErrors[0].statusCode +
          ' ' +
          errors[0].pageErrors[0].message
        : '';
    if (msg == '') {
      if (typeof errors[0].message != 'undefined' && errors[0].message) {
        msg = errors[0].message;
      }
    }

    var showToast = $A.get('e.force:showToast');
    showToast.setParams({
      title: 'Error: ',
      message: 'Taskray encountered an error: ' + msg,
      type: 'error'
    });
    showToast.fire();
  },
  clearSelection: function(component, event, helper) {
    component.set('v.selectedSearchResult', null);
    component.set('v.selectedPills', []);
    component.set('v.searchResults', []);
    var selectionEvent = component.getEvent('trGenericEvent');
    selectionEvent.setParams({
      actionType: 'lookupSelected',
      payload: {
        selectedRecord: null
      }
    });
    selectionEvent.fire();
  }
});