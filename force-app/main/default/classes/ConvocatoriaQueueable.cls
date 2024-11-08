public class ConvocatoriaQueueable implements Queueable, Database.AllowsCallouts {
    private List<String> codeBdns;
    private String token;
    
    //Constructor que recibe el bloque de codeBdns y el token
    public ConvocatoriaQueueable(List<String> codeBdns, String token) {
        this.codeBdns = codeBdns;
        this.token = token;
    }
    public void execute(QueueableContext context) {
        // lamar a obtenerDetallesConvocatorias para el bloque actual
        List<String> detallesJson = APIGetConvocatorias.obtenerDetallesConvocatorias(codeBdns, token);
        //Procesar los detalles obtenidos
        ConvocatoriaService.procesarConvocatoria(detallesJson);
    }
}