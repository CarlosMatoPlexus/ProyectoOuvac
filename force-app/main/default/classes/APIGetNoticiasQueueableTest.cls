@isTest
public class APIGetNoticiasQueueableTest {
    @isTest
    static void testQueueableExecution() {
        // Configurar el mock para simular la llamada HTTP
        Test.setMock(HttpCalloutMock.class, new APIGetNoticiaMock());
        // Ejecutar el trabajo Queueable
        Test.startTest();
        System.enqueueJob(new APIGetNoticiasQueueable());
        Test.stopTest();
        // Verificar que no hubo errores en la ejecución del job.
        List<AsyncApexJob> jobs = [SELECT Id, Status FROM AsyncApexJob WHERE JobType = 'Queueable' LIMIT 1];
        System.assertEquals('Completed', jobs[0].Status, 'El trabajo Queueable debe haberse completado.');
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