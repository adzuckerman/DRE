/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class SyncRolesBatch implements Database.AllowsCallouts, Database.Batchable<SObject>, Database.Stateful {
    global Map<String,String> litmosUserMap;
    global Map<Id,UserRole> parentRoleMap;
    global Map<Id,UserRole> userRoleMap;
    global Map<String,String> userRoleSyncMap;
    global SyncRolesBatch() {

    }
    global void execute(Database.BatchableContext BC, List<UserRole> scope) {

    }
    global static Map<String,String> fetchCurrentUserRoleSyncMap() {
        return null;
    }
    global void finish(Database.BatchableContext BC) {

    }
    global static List<Litmos.LitmosTeamResponse> parseCreateTeamResponse(String reponseJSONString) {
        return null;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return null;
    }
}
