@isTest
public class APIGetConvocatoriasQueueableTest {
    @isTest
    static void testQueueableExecution() {
        // Configurar el mock para simular la llamada HTTP
        Test.setMock(HttpCalloutMock.class, new APIGetConvocatoriasMock());
        // Ejecutar el trabajo Queueable
        Test.startTest();
        System.enqueueJob(new APIGetConvocatoriasQueueable());
        Test.stopTest();
        // Aquí podrías agregar más verificaciones según lo que haga APIGetConvocatorias.obtenerConvocatorias(),
        // como por ejemplo la inserción de registros en Salesforce o procesamiento de datos.
        // Como ejemplo básico, puedes verificar que no hubo errores en la ejecución del job.
        List<AsyncApexJob> jobs = [SELECT Id, Status FROM AsyncApexJob WHERE JobType = 'Queueable' LIMIT 1];
        System.assertEquals('Completed', jobs[0].Status, 'El trabajo Queueable debe haberse completado.');
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