public with sharing class CreateCaseController {
    public Case newCase { get; set; }
    public Contact newContact { get; set; }
    public String contName { get; set; }
    public CreateCaseController(ApexPages.StandardController stdController) {
        this.newCase = (Case)stdController.getRecord();
        newContact = new Contact();
    }
    public PageReference saveCase() {
        try {
            insert newCase;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Caso'+ newCase.CaseNumber +'guardado exitosamente.'));
            return new PageReference('/' + newCase.Id);
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error al guardar el caso: ' + e.getMessage()));
            return null;
        }
    }
    
    @RemoteAction
    public static List<Contact> getFilteredContacts(String searchTerm) {
        String searchPattern = '%' + searchTerm + '%';
        return [SELECT Id, Name, Email, Phone, MobilePhone
                FROM Contact
                WHERE Name LIKE :searchPattern OR Email LIKE :searchPattern
                OR Phone LIKE :searchPattern OR MobilePhone LIKE :searchPattern];
    }

    @RemoteAction
    public static Map<String, Object> saveNewContact(String firstName, String lastName, String email, String phone) {
        Map<String, Object> response = new Map<String, Object>();
        try {
            if(email != '' && phone != ''){
                List<Contact> existingContacts = [SELECT Id FROM Contact WHERE Email = :email AND Phone = :phone LIMIT 1];
                if (!existingContacts.isEmpty()){
                    response.put('status', 'error');
                    response.put('message', 'El contacto con este correo electrónico y teléfono ya existe.');
                } else {
                    Contact newContact = new Contact(
                        FirstName = firstName,
                        LastName = lastName,
                        Email = email,
                        Phone = phone
                    );
                    insert newContact;
                    response.put('status', 'success');
                    if(newContact.FirstName != null){
                        response.put('contactName', newContact.FirstName + ' ' + newContact.LastName);
                    } else {
                        response.put('contactName', newContact.LastName);
                    }
                    response.put('contactId', newContact.Id);
                }
            } else {
                Contact newContact = new Contact();
                newContact.LastName = lastName;
                if(email != ''){
                    newContact.Email = email;
                }
                if(phone != ''){
                    newContact.Phone = phone;
                }
                if(firstName != ''){
                    newContact.FirstName = firstName;
                }
                insert newContact;
                response.put('status', 'success');
                if(newContact.FirstName != null){
                    response.put('contactName', newContact.FirstName + ' ' + newContact.LastName);
                } else {
                    response.put('contactName', newContact.LastName);
                }
                response.put('contactId', newContact.Id);
            }
        } catch (DmlException e) {
            System.debug('error: ' + e.getMessage());
            response.put('status', 'error');
            // Extraer solo la parte relevante del mensaje de error
            String errorMessage = e.getMessage();
            if (errorMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                // Suponiendo que el mensaje siempre contiene esta estructura
                Integer startIndex = errorMessage.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION') + 'FIELD_CUSTOM_VALIDATION_EXCEPTION, '.length();
                Integer endIndex = errorMessage.indexOf(':', startIndex);
                response.put('message', errorMessage.substring(startIndex, endIndex));
            } else {
                response.put('message', errorMessage);
            }
        } catch (Exception e) {
            response.put('status', 'error');
            response.put('message', e.getMessage());
        }
        return response;
    }
}
