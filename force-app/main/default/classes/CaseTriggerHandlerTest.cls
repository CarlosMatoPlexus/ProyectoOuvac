@isTest
public class CaseTriggerHandlerTest {

    @isTest
    static void testFindEmailSubjectEmpty() {
        Case testCase1 = new Case(Subject = '', Origin = 'Email');
        Case testCase2 = new Case(Subject = 'Test Subject', Origin = 'Email');
        Case testCase3 = new Case(Subject = '', Origin = 'Web');
        
        List<Case> testCases = new List<Case>{testCase1, testCase2, testCase3};
        insert testCases;

        Test.startTest();
        CaseTriggerHandler.findEmailSubjectEmpty(testCases);
        Test.stopTest();

        List<Case> processedCases = [SELECT Id, Subject FROM Case WHERE Id IN :testCases];
        System.assertEquals(3, processedCases.size());
        System.assertNotEquals('', processedCases[0].Subject);
    }

    @isTest
    static void testHandleEmailToCaseWithoutSubject() {
    
        Case testCase1 = new Case(Subject = '', Origin = 'Email', SuppliedEmail = 'test@example.com');
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'test@example.com');
        insert testContact;
        
        List<Case> testCases = new List<Case>{testCase1};

        Test.startTest();
        CaseTriggerHandler.handleEmailToCaseWithoutSubject(testCases);
        Test.stopTest();

        List<Contact> insertedContacts = [SELECT Id, Email FROM Contact WHERE Email = :testContact.Email];
        System.assertEquals(1, insertedContacts.size(), 'un contact insertado');
        
        List<AsyncApexJob> jobs = [SELECT Id, JobType, Status FROM AsyncApexJob WHERE JobType = 'Queueable'];
        System.assertNotEquals(0, jobs.size(), 'un job en la cola');
        
    }

    @isTest
    static void testHandleEmailToCaseToDelete() {
        
        Case testCase1 = new Case(Subject = '', Origin = 'Email');
        Case testCase2 = new Case(Subject = 'Test Subject', Origin = 'Email');
        Case testCase3 = new Case(Subject = '', Origin = 'Web');
        

        List<Case> tesListCases1 = new List<Case>{testCase1};
        List<Case> testListCases2 = new List<Case>{testCase2};
        List<Case> testListCases3 = new List<Case>{testCase3};

        insert tesListCases1;
        insert testListCases2;
        insert testListCases3;


        Test.startTest();
        CaseTriggerHandler.handleEmailToCaseToDelete(tesListCases1);
        CaseTriggerHandler.handleEmailToCaseToDelete(testListCases2);
        CaseTriggerHandler.handleEmailToCaseToDelete(testListCases3);
        Test.stopTest();

        List<AsyncApexJob> jobs = [SELECT Id, JobType, Status FROM AsyncApexJob WHERE JobType = 'Queueable'];
        System.assertNotEquals(0, jobs.size(), 'A queueable job should be enqueued');
    }

    @isTest
    static void testGetLargeAttachments() {
        
        Case testCase = new Case(Subject = 'Test Case', Origin = 'Email');
        insert testCase;

        EmailMessage testEmailMessage = new EmailMessage(
            ParentId = testCase.Id,
            Subject = 'Test Email',
            Status = '3'
        );
        insert testEmailMessage;

        ContentVersion testContentVersion = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'TestDocument.txt',
            VersionData = Blob.valueOf('Test content data')
        );
        insert testContentVersion;

        testContentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :testContentVersion.Id];

        ContentDocumentLink testContentDocumentLink = new ContentDocumentLink(
            LinkedEntityId = testEmailMessage.Id,
            ContentDocumentId = testContentVersion.ContentDocumentId,
            ShareType = 'V'
        );
        insert testContentDocumentLink;

        Test.startTest();
        CaseTriggerHandler.getLargeAttachments(new List<Case>{testCase});
        Test.stopTest();

        List<ContentDocument> deletedDocuments = [SELECT Id FROM ContentDocument WHERE Id = :testContentVersion.ContentDocumentId];
        System.assertEquals(1, deletedDocuments.size(), 'The ContentDocument debería haberse borrado');

        List<AsyncApexJob> jobs = [SELECT Id, JobType, Status FROM AsyncApexJob WHERE JobType = 'Future'];
        System.assertNotEquals(1, jobs.size(), 'un future job debería estar encolado');
    }

    @isTest
    static void testHandleEmailToCaseWithoutSubject_MissingTemplate() {
        Case testCase = new Case(Subject = '', Origin = 'Email', SuppliedEmail = 'missingtemplate@example.com');
        List<Case> testCases = new List<Case>{testCase};

        Test.startTest();
        CaseTriggerHandler.handleEmailToCaseWithoutSubject(testCases);
        Test.stopTest();

        List<Contact> contacts = [SELECT Id FROM Contact WHERE Email = 'missingtemplate@example.com'];
        System.assertEquals(1, contacts.size(), 'No se debe insertar ningún contacto');

        List<AsyncApexJob> jobs = [SELECT Id, JobType FROM AsyncApexJob WHERE JobType = 'Queueable'];
        System.assertEquals(1, jobs.size(), 'No se debe encolar ningún job');
    }

    @isTest
    static void testDeleteLargeAttachments_NoAttachments() {
        Case testCase = new Case(Subject = 'Test Case No Attachments', Origin = 'Email');
        insert testCase;

        Test.startTest();
        CaseTriggerHandler.getLargeAttachments(new List<Case>{testCase});
        Test.stopTest();

        List<ContentDocument> deletedDocuments = [SELECT Id FROM ContentDocument];
        System.assertEquals(0, deletedDocuments.size(), 'No debe haberse borrado ningún ContentDocument');

        List<CaseComment> caseComments = [SELECT Id, CommentBody FROM CaseComment WHERE ParentId = :testCase.Id];
        System.assertEquals(0, caseComments.size(), 'No se deben haber añadido comentarios al caso');
    }

    @isTest
    static void testGetLargeAttachments_WithCaseComment() {
        
        Case testCase = new Case(Subject = 'Test Case Large Attachment', Origin = 'Email');
        insert testCase;

        EmailMessage testEmailMessage = new EmailMessage(
            ParentId = testCase.Id,
            Subject = 'Test Email with Large Attachment',
            Status = '3'
        );
        insert testEmailMessage;

        Blob largeBlob = Blob.valueOf('0'.repeat(1048577));
        ContentVersion testContentVersion = new ContentVersion(
            Title = 'Large Document',
            PathOnClient = 'LargeDocument.txt',
            VersionData = largeBlob
        );
        insert testContentVersion;

        testContentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :testContentVersion.Id];

        ContentDocumentLink testContentDocumentLink = new ContentDocumentLink(
            LinkedEntityId = testEmailMessage.Id,
            ContentDocumentId = testContentVersion.ContentDocumentId,
            ShareType = 'V'
        );
        insert testContentDocumentLink;

        Test.startTest();
        CaseTriggerHandler.getLargeAttachments(new List<Case>{testCase});
        Test.stopTest();


        List<ContentDocument> deletedDocuments = [SELECT Id FROM ContentDocument WHERE Id = :testContentVersion.ContentDocumentId];
        System.assertEquals(0, deletedDocuments.size(), 'El ContentDocument debería haberse borrado');

        List<CaseComment> caseComments = [SELECT Id, CommentBody FROM CaseComment WHERE ParentId = :testCase.Id];
        System.assertEquals(1, caseComments.size(), 'Debería haberse creado un comentario en el caso');
        System.assert(caseComments[0].CommentBody.contains('El adjunto no cumple con los requisitos para poder adjuntarlo'), 'El comentario debería indicar que el adjunto es demasiado grande');
    }
}