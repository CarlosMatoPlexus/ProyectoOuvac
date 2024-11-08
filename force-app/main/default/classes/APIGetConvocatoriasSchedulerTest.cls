@isTest
public class APIGetConvocatoriasSchedulerTest {
    @isTest
    static void testScheduleJob() {
        // Simular el mock para el callout
        Test.setMock(HttpCalloutMock.class, new APIGetConvocatoriasMock());
        // Simular la ejecución del trabajo programado
        Test.startTest();
        String cronExp = '0 0 3 * * ?';
        System.schedule('Test Convocatorias Job', cronExp, new APIGetConvocatoriasScheduler());
        Test.stopTest();
        // Verificar que el trabajo programado se haya encolado
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                         FROM CronTrigger WHERE CronJobDetail.Name = 'Test Convocatorias Job' LIMIT 1];
        System.assertEquals(cronExp, ct.CronExpression, 'La expresión cron debe ser la misma.');
        System.assert(ct.NextFireTime != null, 'El trabajo programado debe tener una próxima ejecución.');
    }
    // Nuevo método para cubrir el método scheduleDailyJob()
    @isTest
    static void testScheduleDailyJob() {
        // Simular el mock para el callout
        Test.setMock(HttpCalloutMock.class, new APIGetConvocatoriasMock());
        // Simular la ejecución del método scheduleDailyJob
        Test.startTest();
        APIGetConvocatoriasScheduler.scheduleDailyJob();
        Test.stopTest();
        // Verificar que el trabajo programado se haya encolado correctamente
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                         FROM CronTrigger WHERE CronJobDetail.Name = 'Daily APIGetConvocatorias Job' LIMIT 1];
        System.assertEquals('0 0 3 * * ?', ct.CronExpression, 'La expresión cron debe ser la misma.');
        System.assert(ct.NextFireTime != null, 'El trabajo programado debe tener una próxima ejecución.');
    }
    @isTest
    static void testQueueableCallout() {
        // Simular el mock para el callout
        Test.setMock(HttpCalloutMock.class, new APIGetConvocatoriasMock());
        // Ejecutar el Queueable directamente
        Test.startTest();
        System.enqueueJob(new APIGetConvocatoriasQueueable());
        Test.stopTest();
        // Verificar si se ejecutó correctamente (agregar verificaciones adicionales si es necesario)
    }
    // Mock class para simular las respuestas de las llamadas HTTP
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