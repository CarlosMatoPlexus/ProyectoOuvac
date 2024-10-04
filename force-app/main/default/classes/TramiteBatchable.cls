public class TramiteBatchable implements Database.Batchable<String>, Database.AllowsCallouts {
    private List<String> idTramiteList;
    private String token;
    public TramiteBatchable(List<String> idTramiteList, String token) {
        this.idTramiteList = idTramiteList;
        this.token = token;
    }
    // El método start devolverá la lista de Tramite Id directamente como un Iterable
    public Iterable<String> start(Database.BatchableContext bc) {
        System.debug('Batch iniciado con ' + idTramiteList.size() + ' tramites');
        return idTramiteList;
    }
    // El método execute recibe una lista de Tramite Id (Strings) para procesar
    public void execute(Database.BatchableContext bc, List<String> scope) {
        System.debug('Ejecutando batch para tramites: ' + scope);
        // Llamada a la API para obtener los detalles de los tramites
        List<String> detallesJson = APIGetTramites.obtenerDetallesTramites(scope, token);
        // Procesar los tramites
        TramiteService.procesarTramite(detallesJson);
        System.debug('Batch ejecutado correctamente para los tramites: ' + scope);
    }
    public void finish(Database.BatchableContext bc) {
        System.debug('Finalización del procesamiento de los tramites');
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems
                          FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        System.debug('Job result: ' + a.JobItemsProcessed + ' de ' + a.TotalJobItems + ' procesadas.');
    }
}

