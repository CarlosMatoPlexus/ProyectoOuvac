@isTest
public class APIGetBopedictosSchedulerTest {
    @isTest
    static void testScheduleJob() {
        // Simular el mock para el callout
        Test.setMock(HttpCalloutMock.class, new APIBopedictosMock());
        // Simular la ejecución del trabajo programado
        Test.startTest();
        String cronExp = '0 40 3 * * ?';
        System.schedule('Test Bopedicto Job', cronExp, new APIGetBopedictosScheduler());
        Test.stopTest();
        // Verificar que el trabajo programado se haya encolado
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                         FROM CronTrigger WHERE CronJobDetail.Name = 'Test bopedicto Job' LIMIT 1];
        System.assertEquals(cronExp, ct.CronExpression, 'La expresión cron debe ser la misma.');
        System.assert(ct.NextFireTime != null, 'El trabajo programado debe tener una próxima ejecución.');
    }
    // Nuevo método para cubrir el método scheduleDailyJob()
    @isTest
    static void testScheduleDailyJob() {
        // Simular el mock para el callout
        Test.setMock(HttpCalloutMock.class, new APIBopedictosMock());
        // Simular la ejecución del método scheduleDailyJob
        Test.startTest();
        APIGetBopedictosScheduler.scheduleDailyJob();
        Test.stopTest();
        // Verificar que el trabajo programado se haya encolado correctamente
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                         FROM CronTrigger WHERE CronJobDetail.Name = 'Daily APIGetBopedictos Job' LIMIT 1];
        System.assertEquals('0 40 3 * * ?', ct.CronExpression, 'La expresión cron debe ser la misma.');
        System.assert(ct.NextFireTime != null, 'El trabajo programado debe tener una próxima ejecución.');
    }
    @isTest
    static void testQueueableCallout() {
        // Simular el mock para el callout
        Test.setMock(HttpCalloutMock.class, new APIBopedictosMock());
        // Ejecutar el Queueable directamente
        Test.startTest();
        System.enqueueJob(new APIGetBopedictosQueueable());
        Test.stopTest();
    }
    // Mock class para simular las respuestas de las llamadas HTTP
    private class APIBopedictosMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            // Simulación de la respuesta de login
            if (req.getEndpoint().contains('/login_check')) {
                res.setBody('{"token": "mockToken123", "refresh_token": "mockRefreshToken123", "refresh_token_expiration": 1729701726}');
            }
            // Simulación de la respuesta JSON de la API para obtener detalles de los bopedictos
            else if (req.getEndpoint().contains('/bop_edictos')) {
                // Usar DateTime.now() para simular la fecha actual en los detalles
                String fechaActual = DateTime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'+\'02:00');
                res.setBody('['+
                    '{'+
                    '       "id": 60881,'+
                    '       "id_bop_edicto_externo": 661,'+
                    '       "bop": {'+
                    '           "id": 7901,'+
                    '           "id_bop_externo": 241'+
                    '       },'+
                    '       "sumario": "Exposición pública de la iniciación del expediente para investigar la titularidad de un terreno",'+
                    '       "institucion": {'+
                    '           "code": "001",'+
                    '           "name": "Allariz"'+
                    '       },'+
                    '       "tema": {'+
                    '           "code": "012",'+
                    '           "name": "Otras"'+
                    '       },'+
                    '       "activo": true,'+
                    '       "fecha_creacion": "2024-11-29T13:30:22+01:00",'+
                    '       "fecha_modificacion": "' + fechaActual + '",'+
                    '       "ambito": {'+
                    '           "id": 202,'+
                    '           "name": "Local"'+
                    '       }'+
                    '}'+
                ']');
            }
            return res;
        }
    }
}