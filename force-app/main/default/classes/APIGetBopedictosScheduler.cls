global class APIGetBopedictosScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        // Encolar el trabajo Queueable para permitir el callout
        System.enqueueJob(new APIGetBopedictosQueueable());
    }
    // Método para programar la clase para ejecutarse todos los días a las 3:40 AM
    public static void scheduleDailyJob() {
        // Cron expression para todos los días a las 3:40 AM
        String cronExp = '0 40 3 * * ?';
        // Programar la ejecución
        System.schedule('Daily APIGetBopedictos Job', cronExp, new APIGetBopedictosScheduler());
    }
}