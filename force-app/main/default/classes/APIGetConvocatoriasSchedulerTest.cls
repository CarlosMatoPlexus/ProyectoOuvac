@isTest
public class APIGetConvocatoriasSchedulerTest {
    @isTest
    static void testScheduler() {
        // Configurar el mock para simular la llamada HTTP
        Test.setMock(HttpCalloutMock.class, new APIGetConvocatoriasMock());
        // Simular la programación del job
        Test.startTest();
        String cronExp = '0 0 3 * * ?';
        APIGetConvocatoriasScheduler.scheduleDailyJob();
        Test.stopTest();
        // Verificar que el job fue programado correctamente
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                         FROM CronTrigger WHERE CronExpression = :cronExp];
        System.assertEquals(cronExp, ct.CronExpression, 'La expresión cron debe coincidir');
        System.assertEquals(0, ct.TimesTriggered, 'El job no debe haber sido ejecutado aún');
    }
    // Método para probar la ejecución de la tarea
    @isTest
    static void testExecuteMethod() {
        // Configurar el mock para simular la llamada HTTP
        Test.setMock(HttpCalloutMock.class, new APIGetConvocatoriasMock());
        // Simular la llamada del método 'execute'
        Test.startTest();
        APIGetConvocatoriasScheduler scheduler = new APIGetConvocatoriasScheduler();
        scheduler.execute(null);
        Test.stopTest();
    }

    private class APIGetConvocatoriasMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            // Simulación de la respuesta de login
            if (req.getEndpoint().contains('/login_check')) {
                res.setBody('{"token": "mockToken123", "refresh_token": "mockRefreshToken123", "refresh_token_expiration": 1729701726}');
            }
            // Simulación de la respuesta JSON de la API para obtener detalles de convocatorias
            else if (req.getEndpoint().contains('/convocatorias')) {
                // Usar DateTime.now() para simular la fecha actual en los detalles
                String fechaActual = DateTime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'+\'02:00');
                res.setBody('[' +
                    '{' +
                    '"code_bdns": "321902",' +
                    '"fecha_recepcion": "2016-11-08T01:00:00+01:00",' +
                    '"descripcion": "Acuerdo de Junta de Gobierno de 29/09/2016 por el que se convocan subvenciones...",' +
                    '"importe_total": 25000,' +
                    '"fecha_modificacion": "' + fechaActual + '",' +  // Fecha actual simulada
                    '"fondo_ue": false' +
                    '}' +
                    ']');
            }
            return res;
        }
    }
}