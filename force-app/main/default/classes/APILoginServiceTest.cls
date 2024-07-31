@IsTest
public class APILoginServiceTest {
    @IsTest
    static void testLoginSuccess() {
        // Insertar datos de prueba en Custom Metadata
        APICredentials__mdt credentials = new APICredentials__mdt(
            DeveloperName = 'Default_Credentials',
        Username__c = 'gnoss',
        Password__c = 'o0qf39Gh8I');
        insert credentials;
        // Simular la respuesta de la API
        String jsonResponse = '{"token": "dummyToken"}';
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(jsonResponse);
        res.setStatusCode(200);
        // Crear el mock de Http
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(res));
        // Llamar al método login
        String token = APILoginService.login();
        // Verificar que el token sea correcto
        System.assertEquals('dummyToken', token);
    }