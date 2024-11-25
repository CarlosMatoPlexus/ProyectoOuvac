@isTest
public class APIGetNoticiasSchedulerTest {
    @isTest
    static void testScheduleJob() {
        // Simular el mock para el callout
        Test.setMock(HttpCalloutMock.class, new APIGetNoticiaMock());
        // Simular la ejecución del trabajo programado
        Test.startTest();
        String cronExp = '0 35 3 * * ?';
        System.schedule('Test noticia Job', cronExp, new APIGetNoticiasScheduler());
        Test.stopTest();
        // Verificar que el trabajo programado se haya encolado
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                         FROM CronTrigger WHERE CronJobDetail.Name = 'Test noticia Job' LIMIT 1];
        System.assertEquals(cronExp, ct.CronExpression, 'La expresión cron debe ser la misma.');
        System.assert(ct.NextFireTime != null, 'El trabajo programado debe tener una próxima ejecución.');
    }
    // Nuevo método para cubrir el método scheduleDailyJob()
    @isTest
    static void testScheduleDailyJob() {
        // Simular el mock para el callout
        Test.setMock(HttpCalloutMock.class, new APIGetNoticiaMock());
        // Simular la ejecución del método scheduleDailyJob
        Test.startTest();
        APIGetNoticiasScheduler.scheduleDailyJob();
        Test.stopTest();
        // Verificar que el trabajo programado se haya encolado correctamente
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                         FROM CronTrigger WHERE CronJobDetail.Name = 'Daily APIGetNoticias Job' LIMIT 1];
        System.assertEquals('0 35 3 * * ?', ct.CronExpression, 'La expresión cron debe ser la misma.');
        System.assert(ct.NextFireTime != null, 'El trabajo programado debe tener una próxima ejecución.');
    }
    @isTest
    static void testQueueableCallout() {
        // Simular el mock para el callout
        Test.setMock(HttpCalloutMock.class, new APIGetNoticiaMock());
        // Ejecutar el Queueable directamente
        Test.startTest();
        System.enqueueJob(new APIGetNoticiasQueueable());
        Test.stopTest();
    }
    // Mock class para simular las respuestas de las llamadas HTTP
    private class APIGetNoticiaMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            // Simulación de la respuesta de login
            if (req.getEndpoint().contains('/login_check')) {
                res.setBody('{"token": "mockToken123", "refresh_token": "mockRefreshToken123", "refresh_token_expiration": 1729701726}');
            }
            // Simulación de la respuesta JSON de la API para obtener detalles de los noticias
            else if (req.getEndpoint().contains('/noticias')) {
                // Usar DateTime.now() para simular la fecha actual en los detalles
                String fechaActual = DateTime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'+\'02:00');
                res.setBody('['+
                '    {'+
                '        "id": 75,'+
                '        "titulo": "A Deputación colabora coa XXVII edición da Feira do Pemento de Oímbra",'+
                '        "descripcion": "O deputado de Representación Institucional, Rosendo Fernández, participou esta mañá no Centro Cultural Marcos Valcárcel, na presentación da XXVII edición da Feira do Pemento de Oímbra coa que colabora a Deputación de Ourense. Este evento gastronómico, declarado de Interese Turístico de Galicia, celebrarase o vindeiro domingo, 4 de agosto, onde volverán a ser os protagonistas os pementos de Oímbra, que contan con Indicación Xeográfica Protexida. A feira comezará ás 12.00 coa exposición de coches antigos e coa exposición de pratos de cociña que teñen o pemento como ingrediente principal. Posteriormente, publicarán un receitario con todas as propostas dos participantes. A esa mesma hora e ata as 16.00 horas, a festa estará amenizada pola charanga Fuego. Ás 14.00 horas será a comida popular e ás 21.00 horas será o concerto de Luar na Lubre. Durante todo o día haberá stands diversos nos que se expoñerán pementos, maquinaria agrícola e produtos de artesanía.",'+
                '        "institucion": {'+
                '            "code": "099",'+
                '            "name": "Diputación de Ourense"'+
                '        },'+
                '        "tema": {'+
                '            "code": "012",'+
                '            "name": "Otras"'+
                '        },'+
                '        "activo": true,'+
                '        "fecha_creacion": "2024-07-29T20:19:27+02:00",'+
                '        "fecha_modificacion": "' + fechaActual + '",' +
                '        "ambito": {'+
                '            "code": "099",'+
                '            "name": "Diputación de Ourense"'+
                '        }'+
                '    }'+
                ']');
            }
            return res;
        }
    }
}