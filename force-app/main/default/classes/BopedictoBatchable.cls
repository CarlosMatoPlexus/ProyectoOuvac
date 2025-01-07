public class BopedictoBatchable implements Database.Batchable<String>, Database.AllowsCallouts {
    private List<String> idBopedictos;
    private String token;
    public BopedictoBatchable(List<String> idBopedictos, String token) {
        this.idBopedictos = idBopedictos;
        this.token = token;
    }
    // El método start devolverá la lista de idBopedictos directamente como un Iterable
    public Iterable<String> start(Database.BatchableContext bc) {
        System.debug('Batch iniciado con ' + idBopedictos.size() + ' Bopedictos');
        return idBopedictos;
    }
    // El método execute recibe una lista de idBopedictos (Strings) para procesar
    public void execute(Database.BatchableContext bc, List<String> scope) {
        System.debug('Ejecutando batch para Bopedictos: ' + scope);
        // Llamada a la API para obtener los detalles de los bopedictos
        List<String> detallesJson = APIGetBopedictos.obtenerDetallesBopedictos(scope, token);
        // Procesar las Bopedictos
        Bopedictoservice.procesarBopedicto(detallesJson);
        System.debug('Batch ejecutado correctamente para los bopedictos: ' + scope);
    }
    public void finish(Database.BatchableContext bc) {
        System.debug('Finalización del procesamiento de los bopedictos');
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems
                          FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        System.debug('Job result: ' + a.JobItemsProcessed + ' de ' + a.TotalJobItems + ' procesadas.');
    }
}