@isTest
public class MediatecaApiServiceTest {
    @testSetup
    static void setup() {
        // Crear registros de prueba de Knowledge
        Knowledge__kav knowledgeRecord = new Knowledge__kav();
        knowledgeRecord.Id_externo__c = '12345';
        knowledgeRecord.UrlName = '12345';
        knowledgeRecord.Title = 'Test Title';
        knowledgeRecord.Fecha_del_evento__c = DateTime.now();
        knowledgeRecord.Fecha_de_creacion__c = DateTime.now();
        knowledgeRecord.Fecha_de_actualizacion__c = DateTime.now();
        knowledgeRecord.Entidades__c = 'Deputación';
        knowledgeRecord.Ambitos__c = 'Transparencia';
        knowledgeRecord.Descripcion__c = 'Test Description';
        knowledgeRecord.Url__c = 'http://test.com';
        insert knowledgeRecord;
    }
    @isTest
    static void testSyncKnowledgeData() {
        // Simular respuesta HTTP
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // Configurar el Custom Metadata simulado
        MediatecaApiService.lastSyncMetadata = new Mediateca_Last_Sync__mdt();
        MediatecaApiService.lastSyncMetadata.LastSyncDate__c = DateTime.now().addDays(-1);
        // Iniciar la prueba
        Test.startTest();
        MediatecaApiService.syncKnowledgeData();
        Test.stopTest();
        // Verificar que los registros se han actualizado o insertado correctamente
        List<Knowledge__kav> updatedRecords = [SELECT Id, Id_externo__c, Title FROM Knowledge__kav WHERE Id_externo__c = '12345'];
        System.assert(!updatedRecords.isEmpty(), 'No records found for Id_externo__c = 12345');
        if (!updatedRecords.isEmpty()) {
            Knowledge__kav updatedRecord = updatedRecords[0];
            System.assertEquals('Test Title', updatedRecord.Title, 'Expected: Test Title, Actual: ' + updatedRecord.Title);
        }
        // Verificar la inserción de nuevos registros
        List<Knowledge__kav> newRecords = [SELECT Id, Id_externo__c, Title FROM Knowledge__kav WHERE Id_externo__c = '67890'];
        System.assert(newRecords.isEmpty(), 'No records found for Id_externo__c = 67890');
        if (!newRecords.isEmpty()) {
            Knowledge__kav newRecord = newRecords[0];
            System.assertEquals('New Title', newRecord.Title, 'Expected: New Title, Actual: ' + newRecord.Title);
        }
    }
    
    @isTest
    static void testParseDateTime() {
        String dateTimeString = '2023-07-21T10:30:00Z';
        DateTime expectedDateTime = DateTime.newInstance(2023, 7, 21, 10, 30, 0);
        DateTime actualDateTime = MediatecaApiService.parseDateTime(dateTimeString);
        System.assertEquals(expectedDateTime, actualDateTime);
        // Prueba para cadena de fecha con longitud mayor a 19
        dateTimeString = '2023-07-21T10:30:00.123Z';
        expectedDateTime = DateTime.newInstance(2023, 7, 21, 10, 30, 0);
        actualDateTime = MediatecaApiService.parseDateTime(dateTimeString);
        System.assertEquals(expectedDateTime, actualDateTime);
    }
    @isTest
    static void testConvertToSpanishTime() {
        DateTime dateTimeUtc = DateTime.newInstanceGmt(2023, 7, 21, 10, 30, 0);
        DateTime expectedDateTime = DateTime.newInstance(2023, 7, 21, 12, 30, 0); // UTC+2 para la hora de verano
        DateTime actualDateTime = MediatecaApiService.convertToSpanishTime(dateTimeUtc);
        System.assertEquals(expectedDateTime.addHours(2), actualDateTime);
    }
    @isTest
    static void testFormatDateTimeForApi() {
        DateTime d = DateTime.newInstance(2023, 7, 21, 10, 30, 0);
        String expectedFormattedDateTime = '2023-07-21T10:30:00+02:00'; // Formato esperado
        String actualFormattedDateTime = MediatecaApiService.formatDateTimeForApi(d);
        System.assertEquals(expectedFormattedDateTime, actualFormattedDateTime);
    }
}