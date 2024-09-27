global class APIGetConvocatoriasScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        // Encolar el trabajo Queueable para permitir el callout
        System.enqueueJob(new APIGetConvocatoriasQueueable());
    }
    // Método para programar la clase para ejecutarse todos los días a las 3 AM
    public static void scheduleDailyJob() {
        // Cron expression para todos los días a las 3 AM
        String cronExp = '0 35 8 * * ?';
        // Programar la ejecución
        System.schedule('Daily APIGetConvocatorias Job', cronExp, new APIGetConvocatoriasScheduler());
    }
}