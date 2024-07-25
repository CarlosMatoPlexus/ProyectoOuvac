public class SendEmailQueueable implements Queueable {
    private List<CaseTriggerHandler.EmailMessageData> emailDataList;

    public SendEmailQueueable(List<CaseTriggerHandler.EmailMessageData> emailDataList) {
        this.emailDataList = emailDataList;
    }

    public void execute(QueueableContext context) {
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();

        for (CaseTriggerHandler.EmailMessageData emailData : emailDataList) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] { emailData.toAddress });
            email.setTemplateId(emailData.templateId);
            email.setTargetObjectId(emailData.targetObjectId);
            email.setSaveAsActivity(false);
            emailsToSend.add(email);
        }

        try {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailsToSend);
            for (Messaging.SendEmailResult result : results) {
                if (result.isSuccess()) {
                    System.debug('Email enviado correctamente');
                } else {
                    System.debug('Fallo en el envío del mail ' + result.getErrors()[0].getMessage());
                }
            }
        } catch (Exception e) {
            System.debug('Error enviando emails ' + e.getMessage());
        }
    }
}