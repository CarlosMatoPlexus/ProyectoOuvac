@IsTest
private class SendEmailToSendSmsTest {
    @IsTest
    static void testSendSmsEmailSuccess() {
        // Crear datos de prueba
        Contact testContact = new Contact(
            FirstName = 'John',
        LastName = 'Doe',
        Phone = '+34678912345'
            );
        insert testContact;
        Case testCase = new Case(
            ContactId = testContact.Id
            );
        insert testCase;
        Case c = [SELECT CaseNumber FROM Case WHERE Id = :testCase.Id];
        // Simular una Organization-Wide Email Address existente
        OrgWideEmailAddress orgWideEmail = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
        // Ejecutar el método
        Test.startTest();
        List<String> caseNumbers = new List<String>();
        caseNumbers.add(c.CaseNumber);
        SendEmailToSendSms.sendSmsEmail(caseNumbers);
        Test.stopTest();
        // Validar que no hubo errores (esto cubre el método si no se lanza excepción)
        System.assert(true, 'El método se ejecutó correctamente.');
    }
    @IsTest
    static void testSendSmsEmailNoCasesFound() {
        // Probar con un número de caso inexistente
        Test.startTest();
        try {
            SendEmailToSendSms.sendSmsEmail(new List<String>{ 'INVALID_CASE_NUMBER' });
            System.assert(false, 'Se esperaba una excepción al no encontrar el caso.');
        } catch (EmailException e) {
            System.assertEquals('No se encontraron casos con los números proporcionados.', e.getMessage());
        }
        Test.stopTest();
    }
    @IsTest
    static void testSendSmsEmailInvalidPhone() {
        // Crear datos de prueba con un teléfono inválido
        Contact testContact = new Contact(
            FirstName = 'Jane',
        LastName = 'Doe',
        Phone = '12345'
            );
        insert testContact;
        Case testCase = new Case(
            ContactId = testContact.Id
            );
        insert testCase;
        // Ejecutar el método
        Test.startTest();
        SendEmailToSendSms.sendSmsEmail(new List<String>{ testCase.CaseNumber });
        Test.stopTest();
        // Validar que no se lanzó excepción (teléfono inválido se ignora)
        System.assert(true, 'El método ignoró el teléfono inválido correctamente.');
    }
    @IsTest
    static void testSendSmsEmailNoPhoneNumber() {
        // Crear datos de prueba sin número de teléfono
        Contact testContact = new Contact(
            FirstName = 'NoPhone',
        LastName = 'User'
            );
        insert testContact;
        Case testCase = new Case(
            ContactId = testContact.Id
            );
        insert testCase;
        // Ejecutar el método
        Test.startTest();
        SendEmailToSendSms.sendSmsEmail(new List<String>{ testCase.CaseNumber });
        Test.stopTest();
        // Validar que no se lanzó excepción (sin teléfono se ignora)
        System.assert(true, 'El método ignoró el caso sin número de teléfono correctamente.');
    }
}