global class APIGetConvocatoriasScheduler implements Schedulable {
    // Método que se ejecuta en el cron job
    global void execute(SchedulableContext sc) {
        // Llamar al método obtenerConvocatorias
        APIGetConvocatorias.obtenerConvocatorias();
    }
    // Método para programar la clase para ejecutarse todos los días a las 3 AM
    public static void scheduleDailyJob() {
        // Cron expression para todos los días a las 3 AM
        String cronExp = '0 0 3 * * ?';
        // Programamos la ejecución
        System.schedule('Daily APIGetConvocatorias Job', cronExp, new APIGetConvocatoriasScheduler());
    }
 }