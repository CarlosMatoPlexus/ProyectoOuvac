@IsTest
private class APIGetConvocatoriasTest {
   // Clase mock para simular la respuesta del servicio de autenticación
   private class MockLoginService {
       public String login() {
           return 'mockedToken';
       }
   }
   // Clase mock para simular las respuestas de los callouts HTTP
   private class MockHttpResponse implements HttpCalloutMock {
       public HTTPResponse respond(HTTPRequest req) {
           HttpResponse res = new HttpResponse();
           // Verificar el endpoint y devolver respuestas específicas para cada caso
           if (req.getEndpoint().contains('/api/convocatorias/')) {
               res.setStatusCode(200);
               res.setBody('{"id": "1", "code_bdns": "773553", "name": "Convocatoria Test"}');
           } else {
               res.setStatusCode(200);
               res.setBody('[{"code_bdns": "773553"}, {"code_bdns": "384926"}]');
           }
           return res;
       }
   }
   @IsTest
   static void testObtenerConvocatorias() {
       // Simular la respuesta HTTP usando el mock
       Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
       // Simular el login de autenticación
       Test.startTest();
       // Ejecutar el método a probar
       APIGetConvocatorias.obtenerConvocatorias();
       Test.stopTest();
       // Asegurarse de que se encoló el trabajo en la cola
       List<AsyncApexJob> jobs = [SELECT Id, Status FROM AsyncApexJob];
       System.assertEquals(1, jobs.size());
       System.assertEquals('Queued', jobs[0].Status);
   }
   @IsTest
   static void testObtenerDetallesConvocatorias() {
       // Simular la respuesta HTTP usando el mock
       Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
       // Crear una instancia del servicio de login simulado
       MockLoginService loginService = new MockLoginService();
       String token = loginService.login();
       List<String> codeBdns = new List<String>{'773553', '384926'};
       Test.startTest();
       // Ejecutar el método obtenerDetallesConvocatorias
       List<String> detalles = APIGetConvocatorias.obtenerDetallesConvocatorias(codeBdns, token);
       Test.stopTest();
       // Afirmar que se recibieron los detalles correctamente
       System.assertEquals(2, detalles.size());
       System.assert(detalles[0].contains('code_bdns'));
   }
   @IsTest
   static void testDividirLista() {
       List<String> lista = new List<String>{'1', '2', '3', '4', '5'};
       Integer bloqueSize = 2;
       // Ejecutar el método dividirLista
       List<List<String>> bloques = APIGetConvocatorias.dividirLista(lista, bloqueSize);
       // Verificar que la lista se dividió correctamente
       System.assertEquals(3, bloques.size());
       System.assertEquals(2, bloques[0].size()); // Primer bloque tiene 2 elementos
       System.assertEquals(1, bloques[2].size()); // Último bloque tiene 1 elemento
   }
}