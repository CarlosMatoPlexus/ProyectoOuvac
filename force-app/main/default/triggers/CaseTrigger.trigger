trigger CaseTrigger on Case (before insert, before update, after insert, after update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            CaseTriggerHandler.findEmailSubjectEmpty(Trigger.new);
        }
    }
    if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            CaseTriggerHandler.handleEmailToCaseToDelete(Trigger.new);
        } 
    }
}