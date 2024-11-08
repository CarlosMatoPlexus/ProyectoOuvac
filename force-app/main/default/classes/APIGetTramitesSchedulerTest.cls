@isTest
public class APIGetTramitesSchedulerTest {
    @isTest
    static void testScheduleJob() {
        // Simular el mock para el callout
        Test.setMock(HttpCalloutMock.class, new APIGetTramiteMock());
        // Simular la ejecución del trabajo programado
        Test.startTest();
        String cronExp = '0 30 3 * * ?';
        System.schedule('Test tramite Job', cronExp, new APIGetTramitesScheduler());
        Test.stopTest();
        // Verificar que el trabajo programado se haya encolado
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                         FROM CronTrigger WHERE CronJobDetail.Name = 'Test tramite Job' LIMIT 1];
        System.assertEquals(cronExp, ct.CronExpression, 'La expresión cron debe ser la misma.');
        System.assert(ct.NextFireTime != null, 'El trabajo programado debe tener una próxima ejecución.');
    }
    // Nuevo método para cubrir el método scheduleDailyJob()
    @isTest
    static void testScheduleDailyJob() {
        // Simular el mock para el callout
        Test.setMock(HttpCalloutMock.class, new APIGetTramiteMock());
        // Simular la ejecución del método scheduleDailyJob
        Test.startTest();
        APIGetTramitesScheduler.scheduleDailyJob();
        Test.stopTest();
        // Verificar que el trabajo programado se haya encolado correctamente
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                         FROM CronTrigger WHERE CronJobDetail.Name = 'Daily APIGetTramites Job' LIMIT 1];
        System.assertEquals('0 0 3 * * ?', ct.CronExpression, 'La expresión cron debe ser la misma.');
        System.assert(ct.NextFireTime != null, 'El trabajo programado debe tener una próxima ejecución.');
    }
    @isTest
    static void testQueueableCallout() {
        // Simular el mock para el callout
        Test.setMock(HttpCalloutMock.class, new APIGetTramiteMock());
        // Ejecutar el Queueable directamente
        Test.startTest();
        System.enqueueJob(new APIGetTramitesQueueable());
        Test.stopTest();
    }
    // Mock class para simular las respuestas de las llamadas HTTP
    private class APIGetTramiteMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            // Simulación de la respuesta de login
            if (req.getEndpoint().contains('/login_check')) {
                res.setBody('{"token": "mockToken123", "refresh_token": "mockRefreshToken123", "refresh_token_expiration": 1729701726}');
            }
            // Simulación de la respuesta JSON de la API para obtener detalles de los tramites
            else if (req.getEndpoint().contains('/tramites')) {
                // Usar DateTime.now() para simular la fecha actual en los detalles
                String fechaActual = DateTime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'+\'02:00');
                res.setBody('[' +
                    ' {' +
                    '  "id": 514,' +
                    '  "codigo": "001/2666943",' +
                    '  "titulo": "Abastecimiento de Aguas (Baja)",' +
                    '  "descripcion": "Permite tramitar expedientes relativos a la baja en el servicio público de abastecimiento y saneamiento de agua.",' +
                    '  "institucion": {' +
                    '      "code": "001",' +
                    '      "name": "Allariz"' +
                    '  },' +
                    '  "tema": "/api/temas/011",' +
                    '  "activo": true,' +
                    '  "fecha_creacion": "2024-08-06T12:52:19+02:00",' +
                    '  "fecha_modificacion": "' + fechaActual + '"' + 
                    ' }' +
                    ']');
            }
            return res;
        }
    }
}