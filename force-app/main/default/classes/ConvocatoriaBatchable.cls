public class ConvocatoriaBatchable implements Database.Batchable<String>, Database.AllowsCallouts {
    private List<String> codeBdns;
    private String token;
    public ConvocatoriaBatchable(List<String> codeBdns, String token) {
        this.codeBdns = codeBdns;
        this.token = token;
    }
    // El método start devolverá la lista de codeBdns directamente como un Iterable
    public Iterable<String> start(Database.BatchableContext bc) {
        System.debug('Batch iniciado con ' + codeBdns.size() + ' convocatorias');
        return codeBdns;
    }
    // El método execute recibe una lista de codeBdns (Strings) para procesar
    public void execute(Database.BatchableContext bc, List<String> scope) {
        System.debug('Ejecutando batch para convocatorias: ' + scope);
        // Llamada a la API para obtener los detalles de las convocatorias
        List<String> detallesJson = APIGetConvocatorias.obtenerDetallesConvocatorias(scope, token);
        // Procesar las convocatorias
        ConvocatoriaService.procesarConvocatoria(detallesJson);
        System.debug('Batch ejecutado correctamente para las convocatorias: ' + scope);
    }
    public void finish(Database.BatchableContext bc) {
        System.debug('Finalización del procesamiento de convocatorias');
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems
                          FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        System.debug('Job result: ' + a.JobItemsProcessed + ' de ' + a.TotalJobItems + ' procesadas.');
    }
}