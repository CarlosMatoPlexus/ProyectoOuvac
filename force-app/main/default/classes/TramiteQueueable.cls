public class TramiteQueueable implements Queueable, Database.AllowsCallouts {
    private List<String> idTramites;
    private String token;
    
    //Constructor que recibe el bloque de idTramites y el token
    public TramiteQueueable(List<String> idTramites, String token) {
        this.idTramites = idTramites;
        this.token = token;
    }
    public void execute(QueueableContext context) {
        // lamar a obtenerDetallesTramites para el bloque actual
        List<String> detallesJson = APIGetTramites.obtenerDetallesTramites(idTramites, token);
        //Procesar los detalles obtenidos
        TramiteService.procesarTramite(detallesJson);
    }
}