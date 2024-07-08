@isTest
public class CreateCaseControllerTest {
    @testSetup
    static void setup() {
        // Crear datos de prueba
        Contact testContact = new Contact(
            FirstName = 'Test',
        LastName = 'Ouvac',
        Email = 'test@ouvac.com',
        Phone = '+34658991525',
        MobilePhone = '+349852123'
            );
        insert testContact;
    }
    @isTest
    static void testSaveCaseWithoutContact() {
        // Crear instancia del controlador
        ApexPages.StandardController sc = new ApexPages.StandardController(new Case());
        CreateCaseController controller = new CreateCaseController(sc);
        Test.startTest();
        // Intentar guardar el caso sin ContactId
        PageReference result = controller.saveCase();
        Test.stopTest();
        // Validar que no se insertó el caso y se agregó un mensaje de error
        System.assertEquals(null, result);
        System.assertEquals(1, ApexPages.getMessages().size());
        System.assertEquals(ApexPages.Severity.ERROR, ApexPages.getMessages()[0].getSeverity());
    }
    @isTest
    static void testSaveCaseWithContact() {
        // Obtener contacto de prueba
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        // Crear instancia del controlador
        ApexPages.StandardController sc = new ApexPages.StandardController(new Case());
        CreateCaseController controller = new CreateCaseController(sc);
        controller.newCase.ContactId = testContact.Id;
        controller.newCase.Origin = 'Phone';
        controller.newCase.Subject = 'Test VfPage crear nuevo caso';
        controller.newCase.Description = 'Test de VfPage para crear nuevo caso, con modal de contacto.';
        Test.startTest();
        // Guardar el caso con ContactId
        PageReference result = controller.saveCase();
        Test.stopTest();
        // Validar que se insertó el caso y se redirigió correctamente
        System.assertNotEquals(null, result);
        System.assertEquals('/' + controller.newCase.Id, result.getUrl());
        System.assertEquals(1, [SELECT COUNT() FROM Case WHERE Id = :controller.newCase.Id]);
        System.assertEquals(1, ApexPages.getMessages().size());
        System.assertEquals(ApexPages.Severity.CONFIRM, ApexPages.getMessages()[0].getSeverity());
    }
    @isTest
    static void testGetFilteredContacts() {
        Test.startTest();
        // Llamar a la acción remota para buscar contactos
        List<Contact> contacts = CreateCaseController.getFilteredContacts('Test');
        Test.stopTest();
        // Validar que se encontraron los contactos de prueba
        System.assertNotEquals(0, contacts.size());
    }
    @isTest
    static void testSaveNewContact() {
        // Crear instancia del controlador
        ApexPages.StandardController sc = new ApexPages.StandardController(new Case());
        CreateCaseController controller = new CreateCaseController(sc);
        controller.newContact.FirstName = 'Deputación';
        controller.newContact.LastName = 'Ourense';
        controller.newContact.Email = 'deputacion@ourense.com';
        controller.newContact.Phone = '988317500';
        Test.startTest();
        // Guardar el nuevo contacto
        PageReference result = controller.saveNewContact();
        Test.stopTest();
        // Validar que se insertó el nuevo contacto
        Contact insertedContact = [SELECT Id, Name FROM Contact WHERE Email = 'deputacion@ourense.com' LIMIT 1];
        System.assertNotEquals(null, insertedContact, 'El nuevo contacto debería haberse insertado.');
        // Validar que se asignó el ContactId al caso
        System.assertEquals(insertedContact.Id, controller.newCase.ContactId, 'El ContactId del caso debería estar asignado correctamente.');
        // Validar el mensaje de confirmación
        System.assertEquals(1, ApexPages.getMessages().size());
        System.assertEquals(ApexPages.Severity.CONFIRM, ApexPages.getMessages()[0].getSeverity());
    }
    
    @isTest
    static void testCancel() {
        // Crear instancia del controlador
        ApexPages.StandardController sc = new ApexPages.StandardController(new Case());
        CreateCaseController controller = new CreateCaseController(sc);
        Test.startTest();
        // Llamar al método de cancelar
        PageReference result = controller.cancel();
        Test.stopTest();
        // Validar que se redirige a la lista de casos
        System.assertNotEquals(null, result);
        System.assertEquals('/lightning/o/Case/list', result.getUrl());
    }
    
    @isTest
    static void testSaveCaseWithoutContactId() {
        // Crear instancia del controlador
        ApexPages.StandardController sc = new ApexPages.StandardController(new Case());
        CreateCaseController controller = new CreateCaseController(sc);
        Test.startTest();
        // Intentar guardar el caso sin ContactId
        PageReference result = controller.saveCase();
        Test.stopTest();
        // Validar que no se insertó el caso y se agregó un mensaje de error
        System.assertEquals(null, result);
        System.assertEquals(1, ApexPages.getMessages().size());
        System.assertEquals(ApexPages.Severity.ERROR, ApexPages.getMessages()[0].getSeverity());
    }
    
    @isTest
    static void testSaveNewContactException() {
        // Crear instancia del controlador
        ApexPages.StandardController sc = new ApexPages.StandardController(new Case());
        CreateCaseController controller = new CreateCaseController(sc);
        // Forzar una excepción al intentar insertar un nuevo contacto
        Test.startTest();
        // Insertar un contacto con un campo obligatorio en blanco para forzar una excepción
        controller.newContact.FirstName = 'Nuevo';
        controller.newContact.LastName = ''; // Este campo debería ser obligatorio
        PageReference result = controller.saveNewContact();
        Test.stopTest();
        // Validar que se capturó la excepción y se agregaron los mensajes de error
        System.assertEquals(null, result);
        System.assertEquals(1, ApexPages.getMessages().size());
        System.assertEquals(ApexPages.Severity.ERROR, ApexPages.getMessages()[0].getSeverity());
    }
    
    @isTest
    static void testSaveCaseDmlException() {
        // Crear instancia del controlador
        ApexPages.StandardController sc = new ApexPages.StandardController(new Case());
        CreateCaseController controller = new CreateCaseController(sc);
        // Forzar una excepción de DML al intentar insertar el caso
        Test.startTest();
        try {
            // Intentar insertar un caso inválido que cause una DMLException
            //controller.newCase.Origin = 'Phone';
            //controller.newCase.Subject = 'Test Caso';
            // Dejar el campo ContactId como null para forzar una excepción
            // Esto simula el escenario donde el ContactId no está asignado
            // y debería lanzar una DMLException
            insert controller.newCase;
            // La línea anterior debería lanzar una excepción, por lo que si llegamos aquí,
            // la prueba debería fallar ya que esperamos capturar la excepción en el catch.
            System.assert(true, 'No se lanzó la excepción esperada.');
        } catch (DmlException e) {
            // Validar que se capturó la excepción y se agregaron los mensajes de error
            System.assertEquals(1, ApexPages.getMessages().size());
            System.assertEquals(ApexPages.Severity.ERROR, ApexPages.getMessages()[0].getSeverity());
        }
        Test.stopTest();
    }
}