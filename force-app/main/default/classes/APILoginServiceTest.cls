@isTest
public class APILoginServiceTest {
    // Método de prueba para el login
    @isTest
    static void testLogin() {
        // Configurar el mock para simular la llamada HTTP
        Test.setMock(HttpCalloutMock.class, new APILoginServiceMock());
        // Ejecutar el método que se va a probar
        String token = APILoginService.login();
        // Verificar que el token se obtuvo correctamente
        System.assertNotEquals(null, token, 'El token no debe ser nulo');
        System.assert(token.startsWith('eyJ'), 'El token debe comenzar con "eyJ"');
    }

    // Método de prueba para guardar los tokens
    @isTest
    static void testSaveTokens() {
        // Ejecutar el método de guardar tokens de forma asincrónica
        Test.startTest();
        APILoginService.saveTokens('fakeToken123', 'fakeRefreshToken123', 1729701726L);
        Test.stopTest();
        // Verificar que el token se haya guardado correctamente en la base de datos
        TokenStorage__c storedToken = [SELECT Token__c, RefreshToken__c FROM TokenStorage__c LIMIT 1];
        System.assertEquals('fakeToken123', storedToken.Token__c, 'El token guardado no coincide');
        System.assertEquals('fakeRefreshToken123', storedToken.RefreshToken__c, 'El refresh token guardado no coincide');
    }
    
    // Método de prueba para obtener el token almacenado
    @isTest
    static void testGetToken() {
        // Crear un token de prueba en la base de datos
        TokenStorage__c tokenStorage = new TokenStorage__c(Token__c = 'testToken123', RefreshToken__c = 'testRefreshToken123');
        insert tokenStorage;
        // Ejecutar el método que se va a probar
        String token = APILoginService.getToken();
        // Verificar que el token se obtuvo correctamente
        System.assertEquals('testToken123', token, 'El token recuperado no coincide');
    }
    // Método de prueba para refrescar el token
    @isTest
    static void testRefreshAccessToken() {
        // Configurar el mock para simular la llamada HTTP
        Test.setMock(HttpCalloutMock.class, new APILoginServiceMock());
        // Ejecutar el método que se va a probar
        String newToken = APILoginService.refreshAccessToken('fakeRefreshToken123');
        // Verificar que el nuevo token se obtuvo correctamente
        System.assertNotEquals(null, newToken, 'El nuevo token no debe ser nulo');
        System.assert(newToken.startsWith('eyJ'), 'El nuevo token debe comenzar con "eyJ"');
    }
    // Método para probar el flujo completo de login y refresco de token
    @isTest
    static void testFullTokenFlow() {
        // Configurar el mock para simular la llamada HTTP
        Test.setMock(HttpCalloutMock.class, new APILoginServiceMock());
        // Simular login inicial
        String token = APILoginService.login();
        System.assertNotEquals(null, token, 'El token no debe ser nulo');
        System.assert(token.startsWith('eyJ'), 'El token debe comenzar con "eyJ"');
        // Probar refresco de token
        String refreshToken = APILoginService.refreshAccessToken('fakeRefreshToken123');
        System.assertNotEquals(null, refreshToken, 'El token de refresco no debe ser nulo');
        System.assert(refreshToken.startsWith('eyJ'), 'El token de refresco debe comenzar con "eyJ"');
    }
    // Mock class para simular las respuestas de las llamadas HTTP
    private class APILoginServiceMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            // Simulación de la respuesta JSON de la API de login
            if (req.getEndpoint().contains('login_check')) {
                res.setBody('{"token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9", "refresh_token": "2392e7a399ceadae50aa73d6ea9cee38b6c365d0966d8aec4c798a3392620a2c", "refresh_token_expiration": 1729701726}');
            }
            // Simulación de la respuesta JSON de la API de refresco
            else if (req.getEndpoint().contains('token/refresh')) {
                res.setBody('{"token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9", "refresh_token": "2392e7a399ceadae50aa73d6ea9cee38b6c365d0966d8aec4c798a3392620a2c", "refresh_token_expiration": 1729701726}');
            }
            return res;
        }
    }
}