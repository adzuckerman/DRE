({
  getDestinationProjects: function(component, event, helper) {
    var contextRecordId = helper.getRecordId(component, event, helper);
    var action = component.get('c.getItemsForRecordId');
    action.setParams({ recordId: contextRecordId });
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === 'SUCCESS') {
        var relatedProjects = response.getReturnValue();
        if (relatedProjects.length === 0) {
          component.set('v.noDestinationProjectsAvailable', true);
        } else {
          var destinationProjects = [];
          relatedProjects.forEach(function(projObj) {
            destinationProjects.push({
              Id: projObj.project.Id,
              Name: projObj.project.Name,
              RecordTypeId: projObj.project.RecordTypeId
            });
          });
          component.set('v.destinationProjectOptions', destinationProjects);
          if (!helper.getIsContextual(component, event, helper)) {
            component.set('v.destinationProject', 'select-a-project');
          } else {
            component.set('v.destinationProject', destinationProjects[0].Id);
          }
          component.set(
            'v.destinationProjectRecordTypeId',
            destinationProjects[0].RecordTypeId
          );
        }
      }
    });
    $A.enqueueAction(action);
  },
  setDefaults: function(component, event, helper) {
    var stitchTypes = [
      {
        label: $A.get(
          '$Label.TASKRAY.TaskRay_AddStitchModal_TemplateProjectOpt'
        ),
        value: 'project'
      },
      {
        label: $A.get(
          '$Label.TASKRAY.TaskRay_AddStitchModal_TemplateTaskGroupOpt'
        ),
        value: 'task-group'
      }
    ];
    component.set('v.stitchTypes', stitchTypes);
    component.set('v.selectedStitchType', 'task-group');
    var scheduleOptions = [
      {
        label: $A.get(
          '$Label.TASKRAY.TaskRay_CloneModal_ScheduleInput_firstTask'
        ),
        value: 'Start'
      },
      {
        label: $A.get(
          '$Label.TASKRAY.TaskRay_CloneModal_ScheduleInput_lastTask'
        ),
        value: 'End'
      },
      {
        label: $A.get(
          '$Label.TASKRAY.TaskRay_CloneModal_ScheduleInput_milestone'
        ),
        value: 'milestone'
      }
    ];
    component.set('v.scheduleOptions', scheduleOptions);
    component.set(
      'v.selectedScheduleDate',
      $A.localizationService.formatDate(new Date(), 'YYYY-MM-DD')
    );
    component.set('v.selectedScheduleOption', 'Start');
  },
  getIsContextual: function(component, event, helper) {
    if (component.get('v.overrideRecordId') || component.get('v.recordId')) {
      return true;
    }
    return false;
  },
  getRecordId: function(component, event, helper) {
    if (component.get('v.overrideRecordId')) {
      return component.get('v.overrideRecordId');
    } else if (component.get('v.recordId')) {
      return component.get('v.recordId');
    }
    return $A.get('$SObjectType.CurrentUser.Id');
  },
  checkForButtonEnabled: function(component, event, helper) {
    var destinationProject = component.get('v.destinationProject');
    var templateLookup = component.find('template-lookup');
    var templateSet =
      templateLookup && templateLookup.get('v.selectedSearchResult');
    //.get('v.selectedSearchResult');
    if (
      destinationProject &&
      destinationProject !== 'select-a-project' &&
      templateSet
    ) {
      component.set('v.insertButtonEnabled', true);
    } else {
      component.set('v.insertButtonEnabled', false);
    }
  },
  cloneProjectIntoProject: function(cloneConfig, component, event, helper) {
    component.set('v.cloneRunning', true);
    var action = component.get('c.cloneProjectsIntoExistingProjects');
    action.setParams({ cloneConfigsJSON: JSON.stringify(cloneConfig) });
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === 'SUCCESS') {
        component.set('v.showCloneSuccess', true);
        helper.reInitComponent(component, event, helper);
        window.setTimeout(
          $A.getCallback(function() {
            component.set('v.showCloneSuccess', false);
          }),
          5000
        );
      } else {
        helper.popErrorMessage(component, action);
      }
      component.set('v.cloneRunning', false);
    });
    $A.enqueueAction(action);
  },
  cloneTaskGroupIntoProject: function(cloneConfig, component, event, helper) {
    component.set('v.cloneRunning', true);
    var action = component.get('c.cloneTaskGroupsToExistingProjects');
    action.setParams({ cloneConfigsJSON: JSON.stringify(cloneConfig) });
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === 'SUCCESS') {
        component.set('v.showCloneSuccess', true);
        helper.reInitComponent(component, event, helper);
        window.setTimeout(
          $A.getCallback(function() {
            component.set('v.showCloneSuccess', false);
          }),
          5000
        );
      } else {
        helper.popErrorMessage(component, action);
      }
      component.set('v.cloneRunning', false);
    });
    $A.enqueueAction(action);
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
  reInitComponent: function(component, event, helper) {
    helper.setDefaults(component, event, helper);
    var templateLookup = component.find('template-lookup');
    templateLookup.reInit();
  }
});