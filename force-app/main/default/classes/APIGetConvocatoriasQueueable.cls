public class APIGetConvocatoriasQueueable implements Queueable, Database.AllowsCallouts {
    public void execute(QueueableContext context) {
        // Llamar al método que hace el callout
        APIGetConvocatorias.obtenerConvocatorias();
    }
 }