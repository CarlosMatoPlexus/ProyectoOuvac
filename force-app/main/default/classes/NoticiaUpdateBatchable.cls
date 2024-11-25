public class NoticiaUpdateBatchable implements Database.Batchable<SObject>, Database.AllowsCallouts {
    private List<String> idNoticias;
    private String token;
    public NoticiaUpdateBatchable(List<String> idNoticias, String token) {
        this.idNoticias = idNoticias;
        this.token = token;
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id FROM Knowledge__kav WHERE Noticia_Id__c IN :idNoticias]);
    }
    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<String> detallesJson = APIGetNoticias.obtenerDetallesNoticias(idNoticias, token);
        NoticiaServiceToUpdate.updateNoticia(detallesJson);
    }
    public void finish(Database.BatchableContext bc) {
        System.debug('Finalización del procesamiento de actualización de noticias');
    }
}