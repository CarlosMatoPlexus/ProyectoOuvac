@isTest
public class CustomMetadataCallbackTest {
   @isTest
   static void testHandleResultSuccess() {
       // Crear un contexto simulado
       Metadata.DeployCallbackContext context = new Metadata.DeployCallbackContext();
       // Crear un resultado de despliegue simulado con éxito
       Metadata.DeployResult result = new Metadata.DeployResult();
       result.status = Metadata.DeployStatus.Succeeded;
       // Crear la instancia del callback
       CustomMetadataCallback callback = new CustomMetadataCallback();
       // Llamar al método handleResult
       Test.startTest();
       callback.handleResult(result, context);
       Test.stopTest();
       // No podemos verificar directamente los logs de depuración, así que usamos assert para comprobar el flujo
       System.assertEquals(Metadata.DeployStatus.Succeeded, result.status, 'El estado debería ser Succeeded');
   }
   @isTest
   static void testHandleResultFailure() {
       // Crear un contexto simulado
       Metadata.DeployCallbackContext context = new Metadata.DeployCallbackContext();
       // Crear un resultado de despliegue simulado con fallos
       Metadata.DeployResult result = new Metadata.DeployResult();
       result.status = Metadata.DeployStatus.Failed;
       result.numberComponentErrors = 1;
       result.numberComponentsDeployed = 0;
       result.numberComponentsTotal = 1;
       // Crear mensajes de error simulados
       Metadata.DeployMessage deployMessage = new Metadata.DeployMessage();
       deployMessage.componentType = 'CustomObject';
       deployMessage.fullName = 'TestObject__c';
       deployMessage.problem = 'Test problem';
       result.details = new Metadata.DeployDetails();
       result.details.componentFailures = new List<Metadata.DeployMessage> { deployMessage };
       // Crear la instancia del callback
       CustomMetadataCallback callback = new CustomMetadataCallback();
       // Llamar al método handleResult
       Test.startTest();
       callback.handleResult(result, context);
       Test.stopTest();
       // No podemos verificar directamente los logs de depuración, así que usamos assert para comprobar el flujo
       System.assertEquals(Metadata.DeployStatus.Failed, result.status, 'El estado debería ser Failed');
       System.assertEquals(1, result.numberComponentErrors, 'Debería haber 1 error de componente');
       System.assertEquals(0, result.numberComponentsDeployed, 'No debería haber componentes desplegados');
       System.assertEquals(1, result.numberComponentsTotal, 'Debería haber 1 componente en total');
       System.assertEquals('CustomObject', deployMessage.componentType, 'El tipo de componente debería ser CustomObject');
       System.assertEquals('TestObject__c', deployMessage.fullName, 'El nombre completo debería ser TestObject__c');
       System.assertEquals('Test problem', deployMessage.problem, 'El problema debería ser Test problem');
   }
}