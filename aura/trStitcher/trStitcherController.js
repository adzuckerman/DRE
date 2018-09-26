({
  doInit: function(component, event, helper) {
    helper.getDestinationProjects(component, event, helper);
    helper.setDefaults(component, event, helper);
  },
  insertStitch: function(component, event, helper) {
    var destinationProject = component.get('v.destinationProject');
    var selectedStitchType = component.get('v.selectedStitchType');
    var templateLookup = component.find('template-lookup');
    var templateObject =
      templateLookup && templateLookup.get('v.selectedSearchResult');
    var selectedScheduleDate = component.get('v.selectedScheduleDate');
    var selectedScheduleOption = component.get('v.selectedScheduleOption');
    var selectedMilestoneTaskId = component.get('v.selectedMilestoneTaskId');
    if (selectedStitchType === 'project') {
      var cloneConfig = {};
      cloneConfig[destinationProject] = [
        {
          templateProjectId: templateObject.Id,
          scheduleMode: selectedMilestoneTaskId
            ? selectedMilestoneTaskId
            : selectedScheduleOption,
          targetDate: selectedScheduleDate
        }
      ];
      helper.cloneProjectIntoProject(cloneConfig, component, event, helper);
    } else if (selectedStitchType === 'task-group') {
      var cloneConfig = {};
      cloneConfig[destinationProject] = [
        {
          templateTaskGroupId: templateObject.Id,
          scheduleMode: selectedMilestoneTaskId
            ? selectedMilestoneTaskId
            : selectedScheduleOption,
          targetDate: selectedScheduleDate,
          newTaskGroupName: templateObject.Name
        }
      ];
      helper.cloneTaskGroupIntoProject(cloneConfig, component, event, helper);
    }
  },
  handleDestinationProjectChange: function(component, event, helper) {
    var destinationProjectId = component
      .find('destination-project')
      .get('v.value');
    var destinationProjectObj = component
      .get('v.destinationProjectOptions')
      .find(function(projObj) {
        return projObj.Id === destinationProjectId;
      });
    if (destinationProjectObj && destinationProjectObj.RecordTypeId) {
      component.set(
        'v.destinationProjectRecordTypeId',
        destinationProjectObj.RecordTypeId
      );
    }
    helper.checkForButtonEnabled(component, event, helper);
  },
  handleComponentEvent: function(component, event, helper) {
    var payload = event.getParam('payload');
    if (event.getParam('actionType') === 'lookupSelected') {
      var milestoneTasks = [];
      var selectedMilestoneTaskId = '';
      if (
        payload.selectedRecord &&
        payload.selectedRecord.TASKRAY__TaskRay_Tasks__r
      ) {
        milestoneTasks = payload.selectedRecord.TASKRAY__TaskRay_Tasks__r;
        selectedMilestoneTaskId = milestoneTasks[0].Id;
      }
      component.set('v.milestoneTasks', milestoneTasks);
      component.set('v.selectedMilestoneTaskId', selectedMilestoneTaskId);
      helper.checkForButtonEnabled(component, event, helper);
      event.stopPropagation();
    }
  }
});