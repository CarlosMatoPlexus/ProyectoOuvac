@isTest
public class SendEmailQueueableTest {
    @isTest
    static void testSendEmailQueueable() {
        
        Case testCase = new Case(Subject = 'Test Case', Origin = 'Email', SuppliedEmail = 'test@example.com');
        insert testCase;

        Id templateId = [SELECT Id FROM EmailTemplate LIMIT 1].Id;

        Id targetObjectId = testCase.Id;
        String toAddress = 'test@example.com';

        CaseTriggerHandler.EmailMessageData emailData = new CaseTriggerHandler.EmailMessageData(toAddress, templateId, targetObjectId);
        List<CaseTriggerHandler.EmailMessageData> emailDataList = new List<CaseTriggerHandler.EmailMessageData>{ emailData };

        Test.startTest();
        System.enqueueJob(new SendEmailQueueable(emailDataList));
        Test.stopTest();

        List<AsyncApexJob> jobs = [SELECT Id, JobType, Status FROM AsyncApexJob WHERE JobType = 'Queueable'];
        System.assertNotEquals(0, jobs.size(), 'A queueable job should be enqueued');

    }
}