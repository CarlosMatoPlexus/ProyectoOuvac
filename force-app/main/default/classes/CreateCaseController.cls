public with sharing class CreateCaseController {
    public Case newCase { get; set; }
    public Contact newContact { get; set; }
    public String contName { get; set; }
    public String searchTerm { get; set; }
    public static Id conId { get; set; }
    public String errorMessage { get; set; }
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
                    response.put('message', 'El contacto con este email y teléfono ya existe.');
                }else {
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
                    }else {
                        response.put('contactName', newContact.LastName);
                    }
                    response.put('contactId', newContact.Id);
                }
            }else {
                Contact newContact = new Contact();
                newContact.LastName = lastName;
                if(email !=''){
                    newContact.Email = email;
                }
                if(phone !=''){
                    newContact.Phone = phone;
                }
                if(firstName !=''){
                    newContact.FirstName = firstName;
                }
                insert newContact;
                response.put('status', 'success');
                if(newContact.FirstName != null){
                    response.put('contactName', newContact.FirstName + ' ' + newContact.LastName);
                }else {
                    response.put('contactName', newContact.LastName);
                }
                response.put('contactId', newContact.Id);
                
            }
        } catch (Exception e) {
            response.put('status', 'error');
            response.put('message', e.getMessage());
        }
        return response;
    }
}