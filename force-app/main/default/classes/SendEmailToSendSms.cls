public class SendEmailToSendSms {
   
    @InvocableMethod(label='SendEmailToSMS')
    public static void sendSmsEmail(List<String> caseNumbers) {
        if (caseNumbers == null || caseNumbers.isEmpty()) {
            throw new EmailException('La lista de números de caso está vacía o es nula.');
        }
        List<Case> cases = [ SELECT CaseNumber, Contact.Phone FROM Case WHERE CaseNumber IN :caseNumbers];
        if (cases.isEmpty()) {
            throw new EmailException('No se encontraron casos con los números proporcionados.');
        }
        // Enviar un correo por cada caso encontrado
        for (Case c : cases) {
            if (isValidPhoneNumber(c.Contact.Phone)) {
                String recipient = c.Contact.Phone + '@sms.depourense.gal';
                String subject = 'Gracias por contactar con la OUVAC de la Diputación de Ourense. Trataremos de resolver su consulta a la mayor brevedad posible registrada en el caso ' + c.CaseNumber + '. Info sobre Protección de Datos https://www.depourense.gal/pr.html';
                sendEmail(recipient, subject);
            } else {
                System.debug('Número de teléfono no válido para el caso: ' + c.CaseNumber);
            }
        }
    }
    
    private static void sendEmail(String recipient, String subject) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[] { recipient });
        email.setSubject(subject);
        email.setPlainTextBody(subject);
        email.setOrgWideEmailAddressId(getOrgWideEmailId('comunicaciones_ouvac@depourense.gal'));
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
    }
   
    private static Id getOrgWideEmailId(String emailAddress) {
        OrgWideEmailAddress[] orgWideEmails = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = :emailAddress LIMIT 1];
        if (!orgWideEmails.isEmpty()) {
            return orgWideEmails[0].Id;
        } else {
            throw new EmailException('No se encontró la Organization-Wide Email Address con la dirección: ' + emailAddress);
        }
    }
   
    private static Boolean isValidPhoneNumber(String phone) {
        if (String.isBlank(phone)) {
            return false;
        }
        String regex = '^(?:\\+34|34|0034)?[6789]\\d{8}$|^\\+\\d{1,4}\\d{4,9}$';
        Pattern pattern = Pattern.compile(regex);
        Matcher matcher = pattern.matcher(phone);
        return matcher.matches();
    }
}