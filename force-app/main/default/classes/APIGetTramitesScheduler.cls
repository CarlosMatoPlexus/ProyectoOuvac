global class APIGetTramitesScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        // Encolar el trabajo Queueable para permitir el callout
        System.enqueueJob(new APIGetTramitesQueueable());
    }
    // Método para programar la clase para ejecutarse todos los días a las 3 AM
    public static void scheduleDailyJob() {
        // Cron expression para todos los días a las 3:30 AM
        String cronExp = '0 30 3 * * ?';
        // Programar la ejecución
        System.schedule('Daily APIGetTramites Job', cronExp, new APIGetTramitesScheduler());
    }
}