<aura:application access="GLOBAL" extends="ltng:outApp">
  <aura:dependency resource="TASKRAY:trPendingInterviews"/>
  <aura:dependency resource="TASKRAY:trComponentContainer"/>
  <aura:dependency resource="TASKRAY:trToDoByDay_interviewItem"/>
  <aura:dependency resource="TASKRAY:trTaskRayInbox_celebration"/>
  <aura:dependency resource="TASKRAY:trComponentHeader"/>
  <aura:dependency resource="TASKRAY:svgIcon"/>
  <aura:dependency resource="TASKRAY:trFlowWrapper"/>
  <aura:dependency resource="TASKRAY:trNavigateToTaskRayEvent"/>
  <aura:dependency resource="markup://force:*" type="EVENT"/>
  <aura:dependency resource="TASKRAY:trNavigateToTaskRayEvent" type="EVENT"/>
  <aura:dependency resource="lightning:formattedDateTime"/>
  <aura:dependency resource="lightning:card"/>
  <aura:dependency resource="lightning:flow"/>
</aura:application>