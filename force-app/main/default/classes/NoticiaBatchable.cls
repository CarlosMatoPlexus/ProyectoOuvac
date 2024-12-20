public class NoticiaBatchable implements Database.Batchable<String>, Database.AllowsCallouts {
    private List<String> idNoticias;
    private String token;
    public NoticiaBatchable(List<String> idNoticias, String token) {
        this.idNoticias = idNoticias;
        this.token = token;
    }
    // El método start devolverá la lista de idNoticias directamente como un Iterable
    public Iterable<String> start(Database.BatchableContext bc) {
        System.debug('Batch iniciado con ' + idNoticias.size() + ' noticias');
        return idNoticias;
    }
    // El método execute recibe una lista de idNoticias (Strings) para procesar
    public void execute(Database.BatchableContext bc, List<String> scope) {
        System.debug('Ejecutando batch para noticias: ' + scope);
        // Llamada a la API para obtener los detalles de las noticias
        List<String> detallesJson = APIGetNoticias.obtenerDetallesNoticias(scope, token);
        // Procesar las noticias
        NoticiaService.procesarNoticia(detallesJson);
        System.debug('Batch ejecutado correctamente para las noticias: ' + scope);
    }
    public void finish(Database.BatchableContext bc) {
        System.debug('Finalización del procesamiento de las noticias');
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems
                          FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        System.debug('Job result: ' + a.JobItemsProcessed + ' de ' + a.TotalJobItems + ' procesadas.');
    }
}