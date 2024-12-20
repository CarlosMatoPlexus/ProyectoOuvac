public class BopedictoUpdateBatchable implements Database.Batchable<SObject>, Database.AllowsCallouts {
    private List<String> idBopedictos;
    private String token;
    public BopedictoUpdateBatchable(List<String> idBopedictos, String token) {
        this.idBopedictos = idBopedictos;
        this.token = token;
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id FROM Knowledge__kav WHERE Bopedicto_Id__c IN :idBopedictos]);
    }
    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<String> detallesJson = APIGetBopedictos.obtenerDetallesBopedictos(idBopedictos, token);
        //BopedictoServiceToUpdate.updateBopedicto(detallesJson);
    }
    public void finish(Database.BatchableContext bc) {
        System.debug('Finalización del procesamiento de actualización de bopedictos');
    }
}