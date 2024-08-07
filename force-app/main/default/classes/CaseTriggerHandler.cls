public class CaseTriggerHandler {
    
    public static void findEmailSubjectEmpty(List<Case> emailCases) {
        List<Case> casesToProcess = new List<Case>();

        for (Case c : emailCases) {
            if (c.Origin == 'Email' && String.isBlank(c.Subject)) {
                casesToProcess.add(c);
            }
        }
        if (!casesToProcess.isEmpty()) {
            handleEmailToCaseWithoutSubject(casesToProcess);
        }
    }

    public static void handleEmailToCaseWithoutSubject(List<Case> casesToProcess) {

        EmailTemplate template;
        try {
            template = [SELECT Id, Body, Subject 
                        FROM EmailTemplate 
                        WHERE DeveloperName = 'Notificacion_Caso_Descartado' 
                        LIMIT 1];
        } catch (Exception e) {
            System.debug('Error fetching template: ' + e.getMessage());
            return;
        }
        System.debug('Template: ' + template);
    
        Map<String, Contact> emailToContactMap = new Map<String, Contact>();
        Set<String> emailSet = new Set<String>();

        for (Case c : casesToProcess) {
            if (String.isNotBlank(c.SuppliedEmail)) {
                emailSet.add(c.SuppliedEmail);
            }
        }
    
        List<Contact> existingContacts = [SELECT Id, Email FROM Contact WHERE Email IN :emailSet];
        for (Contact contact : existingContacts) {
            emailToContactMap.put(contact.Email, contact);
        }
    
        List<Contact> contactsToInsert = new List<Contact>();
        for (String email : emailSet) {
            if (!emailToContactMap.containsKey(email)) {
                Contact tempContact = new Contact(
                    LastName = email,
                    Email = email
                );
                contactsToInsert.add(tempContact);
                emailToContactMap.put(email, tempContact);
            }
        }
    
        if (!contactsToInsert.isEmpty()) {
            try {
                insert contactsToInsert;
            } catch (DmlException e) {
                System.debug('Error inserting contacts: ' + e.getMessage());
                return;
            }
        }
        System.debug('Provisional contacts: ' + emailToContactMap.values());
    
        List<CaseTriggerHandler.EmailMessageData> emailDataList = new List<CaseTriggerHandler.EmailMessageData>();
    
        for (Case c : casesToProcess) {
            String senderEmail = c.SuppliedEmail;
    
            if (String.isNotBlank(senderEmail)) {
                Contact tempContact = emailToContactMap.get(senderEmail);
    
                CaseTriggerHandler.EmailMessageData emailData = new CaseTriggerHandler.EmailMessageData(
                    senderEmail,
                    template.Id,
                    tempContact.Id
                );
    
                emailDataList.add(emailData);
                System.debug('Email data: ' + emailData);
            } else {
                System.debug('No valid email to send mail: ' + c.SuppliedEmail);
            }
        }
    
        if (!emailDataList.isEmpty()) {
            System.enqueueJob(new SendEmailQueueable(emailDataList));
        } else {
            System.debug('No emails to send');
        }
    }

    public static void handleEmailToCaseToDelete(List<Case> casesToProcessDelete) {
       
            List<Id> caseIdsToDelete = new List<Id>();
            
            for (Case c : casesToProcessDelete) {
                if (c.Origin == 'Email' && String.isBlank(c.Subject)) {
                    caseIdsToDelete.add(c.Id);
                }
            }
            System.debug('Cases to delete: ' + caseIdsToDelete);
            
            if (!caseIdsToDelete.isEmpty()) {
                System.enqueueJob(new DeleteCasesQueueable(caseIdsToDelete));
            } else {
                System.debug('No se han encontrado casos para borrar');
            }
    }   

    public class EmailMessageData {
        public String toAddress;
        public String templateId;
        public String targetObjectId;
    
        public EmailMessageData(String toAddress, String templateId, String targetObjectId) {
            this.toAddress = toAddress;
            this.templateId = templateId;
            this.targetObjectId = targetObjectId;
        }
    }

    public static void getLargeAttachments(List<Case> cases) {
        Set<Id> caseIds = new Set<Id>();
        for (Case c : cases) {
            caseIds.add(c.Id);
        }
        CaseTriggerHandler.deleteLargeAttachments(caseIds);
    }
    
    @future
    public static void deleteLargeAttachments(Set<Id> caseIds) {
        if (caseIds == null || caseIds.isEmpty()) {
            return;
        }
    
        try {
            List<EmailMessage> emailMessages = [
                SELECT Id, ParentId 
                FROM EmailMessage 
                WHERE ParentId IN :caseIds
            ];
    
            if (emailMessages.isEmpty()) {
                return;
            }
    
            Set<Id> emailMessageIds = new Set<Id>();
            Map<Id, Id> emailMessageToCaseMap = new Map<Id, Id>();
            for (EmailMessage em : emailMessages) {
                emailMessageIds.add(em.Id);
                emailMessageToCaseMap.put(em.Id, em.ParentId);
            }
    
            List<ContentDocumentLink> contentDocumentLinks = [
                SELECT ContentDocumentId, LinkedEntityId 
                FROM ContentDocumentLink 
                WHERE LinkedEntityId IN :emailMessageIds
            ];
    
            if (contentDocumentLinks.isEmpty()) {
                return;
            }
    
            Set<Id> contentDocumentIds = new Set<Id>();
            for (ContentDocumentLink cdl : contentDocumentLinks) {
                contentDocumentIds.add(cdl.ContentDocumentId);
            }
    
            List<ContentVersion> contentVersions = [
                SELECT ContentDocumentId, ContentSize 
                FROM ContentVersion 
                WHERE ContentDocumentId IN :contentDocumentIds 
                AND ContentSize > 1048576
            ];
    
            Set<Id> contentDocumentIdsToDelete = new Set<Id>();
            Map<Id, Long> contentDocumentSizeMap = new Map<Id, Long>();
            for (ContentVersion cv : contentVersions) {
                contentDocumentIdsToDelete.add(cv.ContentDocumentId);
                contentDocumentSizeMap.put(cv.ContentDocumentId, cv.ContentSize);
            }
    
            if (contentDocumentIdsToDelete.isEmpty()) {
                return;
            }
            List<ContentDocument> contentDocumentsToDelete = [
                SELECT Id 
                FROM ContentDocument 
                WHERE Id IN :contentDocumentIdsToDelete
            ];
    
            if (!contentDocumentsToDelete.isEmpty()) {
                delete contentDocumentsToDelete;
    
                List<CaseComment> caseCommentsToInsert = new List<CaseComment>();
                for (ContentDocument cd : contentDocumentsToDelete) {
                    Long contentSize = contentDocumentSizeMap.get(cd.Id);
                    
                    Id emailMessageId = null;
                    for (ContentDocumentLink cdl : contentDocumentLinks) {
                        if (cdl.ContentDocumentId == cd.Id) {
                            emailMessageId = cdl.LinkedEntityId;
                            break;
                        }
                    }
                    
                    Id caseId = emailMessageToCaseMap.get(emailMessageId);
                    
                    if (caseId != null && contentSize != null) {
                        CaseComment cc = new CaseComment();
                        cc.ParentId = caseId;
                        cc.CommentBody = 'El adjunto no cumple con los requisitos para poder adjuntarlo porque su tamaño es: ' + contentSize + ' bytes.';
                        cc.IsPublished = true;
                        caseCommentsToInsert.add(cc);
                    }
                }

                if (!caseCommentsToInsert.isEmpty()) {
                    insert caseCommentsToInsert;
                }
            }
        } catch (Exception e) {
            System.debug('Error al eliminar grandes adjuntos: ' + e.getMessage());
        }
    }
}