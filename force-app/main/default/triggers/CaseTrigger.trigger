trigger CaseTrigger on Case (before insert, before update, after insert, after update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            CaseTriggerHandler.findEmailSubjectEmpty(Trigger.new);
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
            //CaseTriggerHandler.handleCaseStatusChange(Trigger.oldMap, Trigger.newMap);
        } 
    }
}