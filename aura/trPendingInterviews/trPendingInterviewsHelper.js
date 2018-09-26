({
  getInterviews: function(component, event, helper) {
    //getPendingInterviewsForRecordId
    var action = component.get('c.getPendingInterviewsForRecordId');
    action.setParams({
      recordId: component.get('v.recordId')
    });
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === 'SUCCESS') {
        // success with records
        if (response.getReturnValue().length > 0) {
          component.set('v.pendingInterviews', response.getReturnValue());
        } else {
          console.log('collapse');
        }
        // if (response.getReturnValue().length > 0) {
        //   helper.organizeResponse(component, response);
        // }
      } else {
        helper.popErrorMessage(component, action);
      }
      component.set('v.initRan', true);
    });
    $A.enqueueAction(action);
  },
  completeInterview: function(interviewId, component, event, helper) {
    var action = component.get('c.completePendingInterviewForRecordId');
    action.setParams({
      recordId: component.get('v.recordId'),
      interviewId: interviewId
    });
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === 'SUCCESS') {
        // success with records
        if (
          response.getReturnValue().length === 0 &&
          component.get('v.pendingInterviews').length > 0
        ) {
          helper.runConfetti(component, event, helper);
        }
        component.set('v.pendingInterviews', response.getReturnValue());
      } else {
        helper.popErrorMessage(component, action);
      }
    });
    $A.enqueueAction(action);
  },
  popErrorMessage: function(component, action) {
    var errors = action.getError();
    var msg = errors &&
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
  runConfetti: function(component) {
    console.log('run confetti');
    component.set('v.showConfetti', true);
    console.log(component.get('v.showConfetti'));
    window.setTimeout(
      $A.getCallback(
        function() {
          component.set('v.showConfetti', false);
        }.bind(this)
      ),
      6000
    );
  }
});