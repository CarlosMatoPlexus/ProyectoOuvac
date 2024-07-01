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
}