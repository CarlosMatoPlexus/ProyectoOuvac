@isTest
public class ConvocatoriaQueueableTest {
   @isTest
   static void testConvocatoriaQueueable() {
       // Crear una lista de codeBdns simulada
       List<String> codeBdnsList = new List<String>{ '321906', '321907' };
       // Simular un token
       String token = 'mockToken123';
       // Configurar el mock para simular la llamada HTTP
       Test.setMock(HttpCalloutMock.class, new APIGetConvocatoriasMock());
       // Ejecutar la clase Queueable
       Test.startTest();
       ConvocatoriaQueueable queueableJob = new ConvocatoriaQueueable(codeBdnsList, token);
       ID jobId = System.enqueueJob(queueableJob);  // Enqueue the job
       Test.stopTest();
       // Verificar que el job fue encolado correctamente
       AsyncApexJob job = [SELECT Id, Status, JobType FROM AsyncApexJob WHERE Id = :jobId LIMIT 1];
       System.assertNotEquals(null, job, 'El trabajo Queueable debe haberse encolado.');
       System.assertEquals('Queueable', job.JobType, 'El tipo de trabajo debe ser "Queueable".');
       System.assertEquals('Completed', job.Status, 'El trabajo Queueable debería haberse completado.');
   }
   // Mock class para simular las respuestas de las llamadas HTTP
   private class APIGetConvocatoriasMock implements HttpCalloutMock {
       public HttpResponse respond(HttpRequest req) {
           HttpResponse res = new HttpResponse();
           res.setHeader('Content-Type', 'application/json');
           res.setStatusCode(200);
           // Simulación de la respuesta JSON de la API para obtener detalles de convocatorias
           if (req.getEndpoint().contains('/convocatorias/')) {
               res.setBody('[{' +
                   '"code_bdns": "321906",' +
                   '"fecha_recepcion": "2016-11-08T01:00:00+01:00",' +
                   '"descripcion": "Convocatoria de prueba",' +
                   '"importe_total": 25000,' +
                   '"fondo_ue": false,' +
                   '"fecha_modificacion": "2024-09-17T15:50:28+02:00"' +
                   '}]');
           }
           return res;
       }
   }
}