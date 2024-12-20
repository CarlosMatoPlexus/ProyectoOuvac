global class APIGetNoticiasScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        // Encolar el trabajo Queueable para permitir el callout
        System.enqueueJob(new APIGetNoticiasQueueable());
    }
    // Método para programar la clase para ejecutarse todos los días a las 3:35 AM
    public static void scheduleDailyJob() {
        // Cron expression para todos los días a las 3:35 AM
        String cronExp = '0 35 3 * * ?';
        // Programar la ejecución
        System.schedule('Daily APIGetNoticias Job', cronExp, new APIGetNoticiasScheduler());
    }
}