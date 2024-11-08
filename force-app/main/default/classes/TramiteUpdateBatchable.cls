public class TramiteUpdateBatchable implements Database.Batchable<SObject>, Database.AllowsCallouts {
    private List<String> idTramites;
    private String token;
    public TramiteUpdateBatchable(List<String> idTramites, String token) {
        this.idTramites = idTramites;
        this.token = token;
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id FROM Knowledge__kav WHERE Tramite_id__c IN: idTramites]);
        
    }
    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<String> detallesJson = APIGetTramites.obtenerDetallesTramites(idTramites, token);
        TramiteServiceToUpdate.updateTramite(detallesJson);
    }
    public void finish(Database.BatchableContext bc) {
        System.debug('Finalización del procesamiento de actualización de tramites');
    }
}