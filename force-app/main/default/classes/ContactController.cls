public with sharing class ContactController {
    @AuraEnabled
    public static Contact saveContact(Contact contact) {
        try {
            upsert contact;
            return contact;
        } catch (Exception e) {
            throw new AuraHandledException('Error al guardar el contacto: ' + e.getMessage());
        }
    }
 }