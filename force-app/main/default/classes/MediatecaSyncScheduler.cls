global class MediatecaSyncScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        MediatecaApiService.syncKnowledgeData();
    }
    public static void scheduleDailySync() {
        // Configurar el cron para que corra todos los días a la hora deseada (por ejemplo, a la medianoche)
        String cronExp = '0 30 4 * * ?'; // A la medianoche
        MediatecaSyncScheduler scheduler = new MediatecaSyncScheduler();
        // Programar la tarea
        System.schedule('Daily Mediateca Sync', cronExp, scheduler);
    }
}