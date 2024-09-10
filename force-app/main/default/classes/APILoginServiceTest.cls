@IsTest
public class APILoginServiceTest {
   // Clase Mock para simular las respuestas HTTP
   private class HttpCalloutMockImpl implements HttpCalloutMock {
       private HttpResponse mockResponse;
       public HttpCalloutMockImpl(HttpResponse res) {
           this.mockResponse = res;
       }
       public HttpResponse respond(HttpRequest req) {
           return mockResponse;
       }
   }
   @IsTest
   static void testLoginSuccess() {
       // Simular la respuesta de la API
       String jsonResponse = '{"token": "dummyToken"}';
       HttpResponse res = new HttpResponse();
       res.setHeader('Content-Type', 'application/json');
       res.setBody(jsonResponse);
       res.setStatusCode(200);
       // Crear el mock de Http
       Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(res));
       // Llamar al método login
       Test.startTest();
       String token = APILoginService.login();
       Test.stopTest();
       // Verificar que el token sea correcto
       System.assertEquals('dummyToken', token);
   }
   @IsTest
   static void testLoginNoCredentials() {
       // Simular una respuesta vacía, ya que no hay credenciales
       HttpResponse res = new HttpResponse();
       res.setStatusCode(400);
       res.setBody('{"error": "No credentials found"}');
       // Crear el mock de Http
       Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(res));
       // Simular que no hay credenciales disponibles en Custom Metadata
       Test.startTest();
       String token = APILoginService.login();
       Test.stopTest();
       // Verificar que el token sea null debido a la falta de credenciales
       System.assertEquals(null, token);
   }
   @IsTest
   static void testLoginApiError() {
       // Simular una respuesta fallida de la API (por ejemplo, error 401)
       HttpResponse res = new HttpResponse();
       res.setStatusCode(401);
       res.setBody('{"error": "Unauthorized"}');
       // Crear el mock de Http
       Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(res));
       // Llamar al método login
       Test.startTest();
       String token = APILoginService.login();
       Test.stopTest();
       // Verificar que el token sea null debido al error de autenticación
       System.assertEquals(null, token);
   }
   @IsTest
   static void testSaveTokens() {
       // Llamar al método saveTokens para guardar los tokens simulados
       String token = 'dummyToken';
       String refreshToken = 'dummyRefreshToken';
       Long expiration = 1699999999;
       Test.startTest();
       APILoginService.saveTokens(token, refreshToken, expiration);
       Test.stopTest();
       // Verificar que los tokens fueron guardados correctamente en la base de datos
       TokenStorage__c tokenStorage = [SELECT Token__c, RefreshToken__c, TokenExpiration__c FROM TokenStorage__c LIMIT 1];
       System.assertEquals(token, tokenStorage.Token__c);
       System.assertEquals(refreshToken, tokenStorage.RefreshToken__c);
       System.assertNotEquals(null, tokenStorage.TokenExpiration__c);
   }
   @IsTest
   static void testGetTokenWithExistingToken() {
       // Insertar un token en la base de datos
       TokenStorage__c tokenStorage = new TokenStorage__c(
           Token__c = 'existingToken',
           RefreshToken__c = 'existingRefreshToken',
           TokenExpiration__c = System.now().addDays(1)
       );
       insert tokenStorage;
       // Llamar al método getToken
       Test.startTest();
       String token = APILoginService.getToken();
       Test.stopTest();
       // Verificar que el token obtenido sea el que se guardó
       System.assertEquals('existingToken', token);
   }
   @IsTest
   static void testRefreshAccessToken() {
       // Simular la respuesta de la API para refresh
       String jsonResponse = '{"token": "newToken", "refresh_token": "newRefreshToken", "refresh_token_expiration": 1699999999}';
       HttpResponse res = new HttpResponse();
       res.setHeader('Content-Type', 'application/json');
       res.setBody(jsonResponse);
       res.setStatusCode(200);
       // Crear el mock de Http
       Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(res));
       // Llamar al método refreshAccessToken
       Test.startTest();
       String newToken = APILoginService.refreshAccessToken('existingRefreshToken');
       Test.stopTest();
       // Verificar que se recibió el nuevo token
       System.assertEquals('newToken', newToken);
       // Verificar que los tokens fueron actualizados en la base de datos
       TokenStorage__c tokenStorage = [SELECT Token__c, RefreshToken__c FROM TokenStorage__c LIMIT 1];
       System.assertEquals('newToken', tokenStorage.Token__c);
       System.assertEquals('newRefreshToken', tokenStorage.RefreshToken__c);
   }
}