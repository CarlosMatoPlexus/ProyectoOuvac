public with sharing class CreateCaseController {
    public Case newCase { get; set; }
    public String contactSearchTerm { get; set; }
    public Contact newContact { get; set; }
    public String contName { get; set; }
    public CreateCaseController() {
        newCase = new Case();
        newContact = new Contact();
    }
    public CreateCaseController(ApexPages.StandardController controller) {
        this();
    }
    public PageReference saveCase() {
        try {
            if (newCase.ContactId == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Por favor, seleccione un contacto.'));
                return null;
            }
            insert newCase;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Caso '+newCase.CaseNumber+' creado con éxito.'));
            PageReference casePage = new PageReference('/' + newCase.Id);
            casePage.setRedirect(true);
            return casePage;
            
        } catch (DmlException e) {
            ApexPages.addMessages(e);
            return null;
        }
    }
    public PageReference cancel() {
        PageReference casePage = new PageReference('/lightning/o/Case/list');
        return casePage;
    }
    @RemoteAction
    public static List<Contact> getFilteredContacts(String searchTerm) {
        String searchPattern = '%' + searchTerm + '%';
        return [SELECT Id, Name, Email, Phone, MobilePhone
                FROM Contact
                WHERE Name LIKE :searchPattern OR Email LIKE :searchPattern
                OR Phone LIKE :searchPattern OR MobilePhone LIKE :searchPattern];
    }
    public PageReference saveNewContact() {
        try {
            insert newContact;
            Contact c = [SELECT Name FROM Contact WHERE Id =: newContact.Id LIMIT 1];
            newCase.ContactId = newContact.Id;
            contName = c.Name;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Contacto creado y asignado con éxito.'));
            return null;
        } catch (Exception e) {
            ApexPages.addMessages(e);
            return null;
        }
    }
 }