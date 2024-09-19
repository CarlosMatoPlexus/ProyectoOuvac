trigger CaseTrigger on Case (before insert, before update, after insert, after update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            CaseTriggerHandler.findEmailSubjectEmpty(Trigger.new);
        }
        if (Trigger.isUpdate) {
            CaseTriggerHandler.validateStatus(Trigger.oldMap, Trigger.newMap);
        }
    }
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            RouteCasesBasedOnSkills.RouteCasesBasedOnSkills(Trigger.new);
            CaseTriggerHandler.getLargeAttachments(Trigger.new);
        } 
        if (Trigger.isUpdate) {
            CaseTriggerHandler.handleEmailToCaseToDelete(Trigger.new);
            RouteCasesBasedOnSkills.handleAmbitosChange(Trigger.oldMap, Trigger.newMap);
            RouteCasesBasedOnSkills.handleCaseStatusChange(Trigger.oldMap, Trigger.newMap);
        } 
    }
}