public class SendEmailToSendSms {
    @InvocableMethod(label='SendEmailToSMS')
    public static void sendEmailWithOrgWideAddress(List<Id> orgWideEmailId) {
        String recipient = '670372587@sms.depourense.gal';
        String subject = 'Gracias por contactar con la OUVAC de la Diputación de Ourense. Trataremos de resolver su consulta a la mayor brevedad posible registrada en el caso 00001257. Info sobre Protección de Datos  https://www.depourense.gal/pr.html';
        String body = 'Esto es un test de envio de correo para corroborar como esta llegando el email al servidor';
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setOrgWideEmailAddressId(orgWideEmailId[0]);
        email.setToAddresses(new String[] {recipient});
        email.setSubject(subject);
        email.setPlainTextBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }
}