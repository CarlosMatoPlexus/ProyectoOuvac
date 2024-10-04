public class APIGetTramitesQueueable implements Queueable, Database.AllowsCallouts {
    public void execute(QueueableContext context) {
        // Llamar al método que hace el callout
        APIGetTramites.obtenerTramites();
    }
}