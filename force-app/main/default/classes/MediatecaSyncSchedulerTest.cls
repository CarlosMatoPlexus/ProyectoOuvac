@isTest
public class MediatecaSyncSchedulerTest {
   // Test para el método execute
   @isTest
   static void testExecute() {
       // Simulación del método de servicio
       Test.startTest();
       // Crear una instancia de MediatecaSyncScheduler y ejecutar el método
       MediatecaSyncScheduler scheduler = new MediatecaSyncScheduler();
       scheduler.execute(null);
       Test.stopTest();
   }
   // Test para el método scheduleDailySync
   @isTest
   static void testScheduleDailySync() {
       Test.startTest();
       // Llamar al método para programar el trabajo
       MediatecaSyncScheduler.scheduleDailySync();
       // Verificar que se ha programado una tarea
       CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                         FROM CronTrigger WHERE CronExpression = '0 30 4 * * ?'];
       System.assertEquals('0 30 4 * * ?', ct.CronExpression, 'El cron no se ha programado correctamente.');
       Test.stopTest();
   }
}