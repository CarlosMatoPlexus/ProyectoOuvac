@isTest
public class ConvocatoriaBatchableTest {
   @isTest
   static void testConvocatoriaBatchable() {
       // Crear una lista de codeBdns simulada
       List<String> codeBdnsList = new List<String>{ '321906', '321907' };
       // Simular un token
       String token = 'mockToken123';
       // Configurar el mock para simular la llamada HTTP
       Test.setMock(HttpCalloutMock.class, new APIGetConvocatoriasMock());
       // Ejecutar el batch
       Test.startTest();
       ConvocatoriaBatchable batchJob = new ConvocatoriaBatchable(codeBdnsList, token);
       ID batchJobId = Database.executeBatch(batchJob, 2);
       Test.stopTest();
       // Verificar que el trabajo Batchable se ejecutó correctamente
       AsyncApexJob job = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE Id = :batchJobId LIMIT 1];
       System.assertEquals('Completed', job.Status, 'El trabajo Batch debe estar completado.');
       System.assertEquals(1, job.TotalJobItems, 'El número total de items debe ser 1.');
       System.assertEquals(1, job.JobItemsProcessed, 'El número de items procesados debe ser 1.');
       System.assertEquals(0, job.NumberOfErrors, 'No debería haber errores en el procesamiento del batch.');
   }
   // Mock class para simular las respuestas de las llamadas HTTP
   private class APIGetConvocatoriasMock implements HttpCalloutMock {
       public HttpResponse respond(HttpRequest req) {
           HttpResponse res = new HttpResponse();
           res.setHeader('Content-Type', 'application/json');
           res.setStatusCode(200);
           // Simulación de la respuesta JSON de la API para obtener detalles de convocatorias
           if (req.getEndpoint().contains('/convocatorias')) {
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