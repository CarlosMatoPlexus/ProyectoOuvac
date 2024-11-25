@isTest
public class NoticiaUpdateBatchableTest {
    @isTest
    static void testNoticiaUpdateBatchableTest() {
        // Crear una lista de id de noticias simulada
        List<String> idNoticiaList = new List<String>{ '75', '76' };
        // Simular un token
        String token = 'mockToken123';
        // Insertar datos de Knowledge__kav simulados para la prueba
        Knowledge__kav knowledge1 = new Knowledge__kav(
            Noticia_Id__c = '75',
        Title = 'Noticia Test 1',
        UrlName = 'noticia-test-1'
            );
        Knowledge__kav knowledge2 = new Knowledge__kav(
            Tramite_id__c = '76',
        Title = 'Noticia Test 2',
        UrlName = 'noticia-test-2'
            );
        insert new List<Knowledge__kav>{ knowledge1, knowledge2 };
        // Configurar el mock para simular la llamada HTTP
        Test.setMock(HttpCalloutMock.class, new APIGetNoticiaMock());
        // Ejecutar el batch
        Test.startTest();
        NoticiaUpdateBatchable batchJob = new NoticiaUpdateBatchable(idNoticiaList, token);
        ID batchJobId = Database.executeBatch(batchJob, 2);
        Test.stopTest();
        // Verificar que el trabajo Batchable se ejecutó correctamente
        AsyncApexJob job = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors
                           FROM AsyncApexJob WHERE Id = :batchJobId LIMIT 1];
        System.assertEquals('Completed', job.Status, 'El trabajo Batch debe estar completado.');
        System.assertEquals(1, job.TotalJobItems, 'El número total de items debe ser 1.');
        System.assertEquals(1, job.JobItemsProcessed, 'El número de items procesados debe ser 1.');
        System.assertEquals(0, job.NumberOfErrors, 'No debería haber errores en el procesamiento del batch.');
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
                    '  "fecha_modificacion": "' + fechaActual + '"' +
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