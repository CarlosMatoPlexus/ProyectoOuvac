public class CustomMetadataUpdateService {
    @future
    public static void updateLastSyncDateAsync(Datetime today) {
        updateLastSyncDate(today);
    }
    public static void updateLastSyncDate(Datetime today) {
        try {
            Metadata.CustomMetadata customMetadata = new Metadata.CustomMetadata();
            customMetadata.fullName = 'Mediateca_Last_Sync__mdt.LastSyncDate';
            customMetadata.label = 'LastSyncDate'; // Añadir la etiqueta aquí si no está configurada
            Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
            customField.field = 'LastSyncDate__c';
            customField.value = today;
            customMetadata.values.add(customField);
            Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
            mdContainer.addMetadata(customMetadata);
            CustomMetadataCallback callback = new CustomMetadataCallback();
            Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
            System.debug('Metadata deployment enqueued with jobId: ' + jobId);
        } catch (Exception e) {
            System.debug('Error updating LastSyncDate custom metadata: ' + e.getMessage());
        }
    }
 }