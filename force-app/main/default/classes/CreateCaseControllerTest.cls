@isTest
private class CreateCaseControllerTest {
   @isTest
   static void testSaveCase_success() {
       // Preparación
       Case testCase = new Case(
           Subject = 'Test Caso',
           Entidades__c = 'Deputación',
           Ambitos__c = 'Recaudación',
           Origin = 'Email'
       );
       ApexPages.StandardController stdController = new ApexPages.StandardController(testCase);
       CreateCaseController controller = new CreateCaseController(stdController);
       // Ejecución
       Test.startTest();
       PageReference result = controller.saveCase();
       Test.stopTest();
       // Verificación
       System.assertNotEquals(null, result);
       System.assert(result.getUrl().contains('/' + testCase.Id));
   }
   @isTest
   static void testSaveCase_exception() {
       // Preparación
       Case testCase = new Case(
           Subject = 'Test Caso',
           Entidades__c = 'Deputación',
           Ambitos__c = 'Recaudación',
           Origin = 'Email'
       );
       ApexPages.StandardController stdController = new ApexPages.StandardController(testCase);
       CreateCaseController controller = new CreateCaseController(stdController);
       // Forzar un error al insertar
       Test.startTest();
       System.runAs(new User(Id = UserInfo.getUserId())) {
           testCase.Subject = null;
           try {
               controller.saveCase();
           } catch (Exception e) {
               System.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
           }
       }
       Test.stopTest();
   }
   @isTest
   static void testGetFilteredContacts() {
       // Preparación
       Contact testContact1 = new Contact(
           FirstName = 'Test',
           LastName = 'User1',
           Email = 'test1@example.com',
           Phone = '1234567890'
       );
       Contact testContact2 = new Contact(
           FirstName = 'Test',
           LastName = 'User2',
           Email = 'test2@example.com',
           Phone = '0987654321'
       );
       insert new List<Contact> { testContact1, testContact2 };
       String searchTerm = 'Test';
       // Ejecución
       Test.startTest();
       List<Contact> contacts = CreateCaseController.getFilteredContacts(searchTerm);
       Test.stopTest();
       // Verificación
       System.assertNotEquals(null, contacts);
       System.assertEquals(2, contacts.size());
   }
   @isTest
   static void testSaveNewContact_success() {
       // Preparación
       String firstName = 'Controller';
       String lastName = 'Test';
       String email = 'test@controller.com';
       String phone = '1234567890';
       // Ejecución
       Test.startTest();
       Map<String, Object> response = CreateCaseController.saveNewContact(firstName, lastName, email, phone);
       Test.stopTest();
       // Verificación
       System.assertEquals('success', response.get('status'));
       System.assertEquals('Controller Test', response.get('contactName'));
       System.assertNotEquals(null, response.get('contactId'));
   }
   @isTest
   static void testSaveNewContact_duplicado() {
       // Preparación
       String firstName = 'Controller';
       String lastName = 'Test';
       String email = 'test@controller.com';
       String phone = '1234567890';
       // Crear un contacto existente con el mismo email y teléfono
       Contact existingContact = new Contact(
           FirstName = 'Prueba',
           LastName = 'Test Controller',
           Email = email,
           Phone = phone
       );
       insert existingContact;
       // Ejecución
       Test.startTest();
       Map<String, Object> response = CreateCaseController.saveNewContact(firstName, lastName, email, phone);
       Test.stopTest();
       // Verificación
       System.assertEquals('error', response.get('status'));
       System.assertEquals('El contacto con este correo electrónico y teléfono ya existe.', response.get('message'));
   }
   @isTest
   static void testSaveNewContact_noEmailNoPhone() {
       // Preparación
       String firstName = 'No';
       String lastName = 'EmailPhone';
       String email = '';
       String phone = '';
       // Ejecución
       Test.startTest();
       Map<String, Object> response = CreateCaseController.saveNewContact(firstName, lastName, email, phone);
       Test.stopTest();
       // Verificación
       System.assertEquals('success', response.get('status'));
       System.assertEquals('No EmailPhone', response.get('contactName'));
       System.assertNotEquals(null, response.get('contactId'));
   }
   @isTest
   static void testSaveNewContact_infoParcial() {
       // Preparación
       String firstName = '';
       String lastName = 'SoloApellido';
       String email = 'partial@example.com';
       String phone = '';
       // Ejecución
       Test.startTest();
       Map<String, Object> response = CreateCaseController.saveNewContact(firstName, lastName, email, phone);
       Test.stopTest();
       // Verificación
       System.assertEquals('success', response.get('status'));
       System.assertEquals('SoloApellido', response.get('contactName'));
       System.assertNotEquals(null, response.get('contactId'));
   }
   @isTest
   static void testSaveNewContact_emptyFields() {
       // Preparación
       String firstName = '';
       String lastName = '';
       String email = '';
       String phone = '';
       // Ejecución
       Test.startTest();
       Map<String, Object> response = CreateCaseController.saveNewContact(firstName, lastName, email, phone);
       Test.stopTest();
       // Verificación
       System.assertEquals('error', response.get('status'));
       System.assert(response.get('message') != null);
   }
   @isTest
   static void testSaveNewContact_onlyEmail() {
       // Preparación
       String firstName = '';
       String lastName = 'SoloEmail';
       String email = 'soloemail@example.com';
       String phone = '';
       // Ejecución
       Test.startTest();
       Map<String, Object> response = CreateCaseController.saveNewContact(firstName, lastName, email, phone);
       Test.stopTest();
       // Verificación
       System.assertEquals('success', response.get('status'));
       System.assertEquals('SoloEmail', response.get('contactName'));
       System.assertNotEquals(null, response.get('contactId'));
   }
   @isTest
   static void testSaveNewContact_onlyPhone() {
       // Preparación
       String firstName = '';
       String lastName = 'SoloPhone';
       String email = '';
       String phone = '0987654321';
       // Ejecución
       Test.startTest();
       Map<String, Object> response = CreateCaseController.saveNewContact(firstName, lastName, email, phone);
       Test.stopTest();
       // Verificación
       System.assertEquals('success', response.get('status'));
       System.assertEquals('SoloPhone', response.get('contactName'));
       System.assertNotEquals(null, response.get('contactId'));
   }

   @isTest
    static void testSaveNewContact_fieldCustomValidationException() {
        // Preparación
        String firstName = 'Test';
        String lastName = 'validacion phone';
        String email = 'validacionPhone@test.com';
        String phone = '12345678'; // Un teléfono que seguramente fallará la validación
        // Ejecución
        Test.startTest();
        Map<String, Object> response = CreateCaseController.saveNewContact(firstName, lastName, email, phone);
        Test.stopTest();
        // Verificación
        System.assertEquals('error', response.get('status'));
        String errorMessage = (String) response.get('message');
        System.assert(errorMessage != null, 'El mensaje de error no debe ser nulo');
        System.assert(errorMessage.contains('El numero telefónico debe contener entre 9 y 11 dígitos.'), 'El mensaje de error debería contener El numero telefónico debe contener entre 9 y 11 dígitos.');
    }
}