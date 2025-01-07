@isTest
public class APIGetBopedictosQueueableTest {
    @isTest
    static void testQueueableExecution() {
        // Configurar el mock para simular la llamada HTTP
        Test.setMock(HttpCalloutMock.class, new APIBopedictosMock());
        // Ejecutar el trabajo Queueable
        Test.startTest();
        System.enqueueJob(new APIGetBopedictosQueueable());
        Test.stopTest();
        // Verificar que no hubo errores en la ejecución del job.
        List<AsyncApexJob> jobs = [SELECT Id, Status FROM AsyncApexJob WHERE JobType = 'Queueable' LIMIT 1];
        System.assertEquals('Completed', jobs[0].Status, 'El trabajo Queueable debe haberse completado.');
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