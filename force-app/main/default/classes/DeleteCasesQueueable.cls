public class DeleteCasesQueueable implements Queueable, Database.AllowsCallouts {
    private List<Id> caseIdsToDelete;

    public DeleteCasesQueueable(List<Id> caseIds) {
        this.caseIdsToDelete = caseIds;
    }

    public void execute(QueueableContext context) {
        try {
            List<Case> casesToDelete = [SELECT Id FROM Case WHERE Id IN :caseIdsToDelete];
            System.debug('casos borrados' +casesToDelete);
            delete casesToDelete;
            
        } catch (DmlException e) {
            System.debug('Error borrando casos ' + e.getMessage());
            throw e;
        }
    }
}