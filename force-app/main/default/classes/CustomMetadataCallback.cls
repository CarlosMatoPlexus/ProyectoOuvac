public class CustomMetadataCallback implements Metadata.DeployCallback {
    public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
        if (result.status == Metadata.DeployStatus.Succeeded) {
            System.debug('Metadata deployment succeeded.');
        } else {
            System.debug('Metadata deployment failed with status: ' + result.status);
            System.debug('Number of component errors: ' + result.numberComponentErrors);
            System.debug('Number of components deployed: ' + result.numberComponentsDeployed);
            System.debug('Number of components total: ' + result.numberComponentsTotal);
            if (result.details != null) {
                for (Metadata.DeployMessage message : result.details.componentFailures) {
                    System.debug('Component failure: ' + message.componentType + ' - ' + message.fullName);
                    System.debug('Problem: ' + message.problem);
                }
            }
        }
    }
 }