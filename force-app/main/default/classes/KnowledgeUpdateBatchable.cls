public class KnowledgeUpdateBatchable implements Database.Batchable<SObject>, Database.AllowsCallouts {
    private List<String> codeBdns;
    private String token;
    public KnowledgeUpdateBatchable(List<String> codeBdns, String token) {
        this.codeBdns = codeBdns;
        this.token = token;
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id FROM Knowledge__kav WHERE code_bdns__c IN :codeBdns]);
    }
    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<String> detallesJson = APIGetConvocatorias.obtenerDetallesConvocatorias(codeBdns, token);
        ConvocatoriaServiceToUpdate.updateConvocatoria(detallesJson);  // Llamar para actualizar registros existentes
    }
    public void finish(Database.BatchableContext bc) {
        System.debug('Finalización del procesamiento de actualización de convocatorias');
    }
}