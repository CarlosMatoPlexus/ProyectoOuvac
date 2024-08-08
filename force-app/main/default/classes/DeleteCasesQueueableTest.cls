@isTest
public class DeleteCasesQueueableTest {

    @isTest
    static void testExecute() {
        Case testCase1 = new Case(Subject = 'Test Case 1', Origin = 'Email');
        Case testCase2 = new Case(Subject = 'Test Case 2', Origin = 'Web');
        Case testCase3 = new Case(Subject = '', Origin = 'Email');
        
        insert new List<Case>{ testCase1, testCase2, testCase3 };

        List<Id> caseIdsToDelete = new List<Id>{ testCase1.Id, testCase2.Id, testCase3.Id };

        Test.startTest();

        DeleteCasesQueueable queueable = new DeleteCasesQueueable(caseIdsToDelete);
        System.enqueueJob(queueable);

        Test.stopTest();

        List<Case> deletedCases = [SELECT Id FROM Case WHERE Id IN :caseIdsToDelete ALL ROWS];
        System.assertNotEquals(0, deletedCases.size(), 'un caso se borrará');

    }
}