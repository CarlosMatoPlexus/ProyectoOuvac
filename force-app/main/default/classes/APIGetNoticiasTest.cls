@isTest
public class APIGetNoticiasTest {
    @isTest
    static void testObtenerNoticias() {
        // Configurar el mock para simular la llamada HTTP
        Test.setMock(HttpCalloutMock.class, new APIGetNoticiaMock());
        Test.startTest();
        APIGetNoticias.obtenerNoticias();
        Test.stopTest();
        // Verificar que se programaron batch jobs para procesar registros
        List<AsyncApexJob> jobs = [SELECT Id, Status FROM AsyncApexJob WHERE JobType = 'BatchApex' LIMIT 10];
        System.assert(!jobs.isEmpty(), 'Debe haber al menos un batch job programado.');
        System.assertEquals('Completed', jobs[0].Status, 'El primer batch job debería estar completado.');
    }
    
    @isTest
    static void testObtenerNoticiasCompareDate() {
        // Configurar el mock para simular la llamada HTTP
        Test.setMock(HttpCalloutMock.class, new APIGetNoticiaMock());
        // Simular algunos datos existentes de Knowledge en Salesforce
        Knowledge__kav knowledgeExisting = new Knowledge__kav(
            Noticia_Id__c = '25',
        fecha_modificacion__c = DateTime.now().addDays(-2), // Fecha anterior para forzar actualización
        Title = 'knowledgeExisting',
        UrlName = 'knowledgeExisting'
            );
        insert knowledgeExisting;
        // Ejecutar el método a probar
        Test.startTest();
        APIGetNoticias.obtenerNoticias();
        Test.stopTest();
        // Verificar que se programaron batch jobs para procesar registros
        List<AsyncApexJob> jobs = [SELECT Id, Status FROM AsyncApexJob WHERE JobType = 'BatchApex' LIMIT 10];
        System.assert(!jobs.isEmpty(), 'Debe haber al menos un batch job programado.');
        System.assertEquals('Completed', jobs[0].Status, 'El primer batch job debería estar completado.');
    }
    
    @isTest
    static void testObtenerNoticiasNew() {
        // Configurar el mock para simular la llamada HTTP
        Test.setMock(HttpCalloutMock.class, new APIGetNoticiaMock());
        // Ejecutar el método a probar
        Test.startTest();
        List<String> idNoticias = new List<String>();
        idNoticias.add('25');
        String token = 'mockToken123';
        List<String> detallesJson = APIGetNoticias.obtenerDetallesNoticias(idNoticias, token);
        NoticiaService.procesarNoticia(detallesJson);
        Test.stopTest();
        //Verificar si el registro de Knowledge fue insertado correctamente
        Knowledge__kav newKnowledge = [SELECT Id, Noticia_Id__c FROM Knowledge__kav WHERE Noticia_Id__c = '25' LIMIT 1];
        System.Assert(newKnowledge != null, 'El nuevo registro de Knowledge deberia haber sido insertado.');
        System.assertEquals('25', newKnowledge.Noticia_Id__c, 'El id de la noticia del nuevo Knowledge deberia ser "25"');
    }
    
    @isTest
    static void testObtenerDetallesNoticias() {
        // Configurar el mock para simular la llamada HTTP
        Test.setMock(HttpCalloutMock.class, new APIGetNoticiaMock());
        // Simular algunos id de noticia para la prueba
        List<String> idNoticias = new List<String>{ '25' };
        String token = 'mockToken123';
        // Ejecutar el método que obtiene los detalles de las noticias.
        Test.startTest();
        List<String> detalles = APIGetNoticias.obtenerDetallesNoticias(idNoticias, token);
        Test.stopTest();
        // Verificar que los detalles se obtuvieron correctamente
        System.assert(!detalles.isEmpty(), 'Debe haberse recuperado al menos un detalle de las noticias.');
        System.assert(detalles[0].contains('"id": 25'), 'El detalle debe contener la noticia con id "25".');
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
            // Simulación de la respuesta JSON de la API para noticias
            else if (req.getEndpoint().contains('/noticias/25')) {
                // Usar DateTime.now() para simular la fecha actual y asegurar la actualización
                String fechaActual = DateTime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'+\'02:00');
                res.setBody('{' +
                    '   "id": 25,' +
                    '   "titulo": "Campaña informativa \\"INFOCONSUMO\\" en Amoeiro",' +
                    '   "descripcion": "Prueba Json Noticia",' +
                    '   "institucion": {' +
                    '       "code": "002",' +
                    '       "name": "Amoeiro"' +
                    '   },' +
                    '   "tema": {' +
                    '       "code": "012",' +
                    '       "name": "Otras"' +
                    '   },' +
                    '   "activo": true,' +
                    '   "fecha_creacion": "2024-08-06T19:53:37+02:00",' +
                    '   "fecha_modificacion": "' + fechaActual + '",' +
                    '   "ambito": {' +
                    '       "code": "002",' +
                    '       "name": "Amoeiro"' +
                    '   },' +
                    '   "data_es_json": {' +
                    '       "titulo": "Campaña informativa \\"INFOCONSUMO\\" en Amoeiro",' +
                    '       "url": "https://www.amoeiro.gal/arquivos/3673",' +
                    '       "date": "2023-09-30T00:00:00+02:00",' +
                    '       "contenido": "Prueba Json Noticia data_es_json",' +
                    '       "categorias": [' +
                    '           "consumo",' +
                    '           "dereitos",' +
                    '           "información",' +
                    '           "charlas",' +
                    '           "Escola Galega de consumo"' +
                    '       ],' +
                    '       "imagenes": [' +
                    '           {' +
                    '               "url": "https://static.xx.fbcdn.net/images/emoji.php/v9/t40/1/16/25b6.png",' +
                    '               "titulo": "Img 1"' +
                    '           },' +
                    '           {' +
                    '               "url": "https://static.xx.fbcdn.net/images/emoji.php/v9/t40/1/16/25b6.png",' +
                    '               "titulo": "Img 2"' +
                    '           },' +
                    '           {' +
                    '               "url": "https://static.xx.fbcdn.net/images/emoji.php/v9/t40/1/16/25b6.png",' +
                    '               "titulo": "Img 3"' +
                    '           },' +
                    '           {' +
                    '               "url": "http://www.amoeiro.gal/wp-content/uploads/2023/09/banca-300x216.png",' +
                    '               "titulo": "Img 4"' +
                    '           },' +
                    '           {' +
                    '               "url": "http://www.amoeiro.gal/wp-content/uploads/2023/09/compra-300x216.png",' +
                    '               "titulo": "Img 5"' +
                    '           },' +
                    '           {' +
                    '               "url": "http://www.amoeiro.gal/wp-content/uploads/2023/09/consumo-300x216.png",' +
                    '               "titulo": "Img 6"' +
                    '           },' +
                    '           {' +
                    '               "url": "http://www.amoeiro.gal/wp-content/uploads/2023/09/luz-e-gas-300x217.png",' +
                    '               "titulo": "Img 7"' +
                    '           }' +
                    '       ]' +
                    '   },' +
                    '   "data_gl_json": {' +
                    '       "titulo": "Campaña informativa \\"INFOCONSUMO\\" en Amoeiro",' +
                    '       "url": "https://www.amoeiro.gal/arquivos/3673",' +
                    '       "date": "2023-09-30T00:00:00+02:00",' +
                    '       "contenido": "Prueba Json Noticia data_gl_json",' +
                    '       "categorias": [' +
                    '           "consumo",' +
                    '           "dereitos",' +
                    '           "información",' +
                    '           "charlas",' +
                    '           "Escola Galega de consumo"' +
                    '       ],' +
                    '       "imagenes": [' +
                    '           {' +
                    '               "url": "https://static.xx.fbcdn.net/images/emoji.php/v9/t40/1/16/25b6.png",' +
                    '               "titulo": "Img 1"' +
                    '           },' +
                    '           {' +
                    '               "url": "https://static.xx.fbcdn.net/images/emoji.php/v9/t40/1/16/25b6.png",' +
                    '               "titulo": "Img 2"' +
                    '           },' +
                    '           {' +
                    '               "url": "https://static.xx.fbcdn.net/images/emoji.php/v9/t40/1/16/25b6.png",' +
                    '               "titulo": "Img 3"' +
                    '           },' +
                    '           {' +
                    '               "url": "http://www.amoeiro.gal/wp-content/uploads/2023/09/banca-300x216.png",' +
                    '               "titulo": "Img 4"' +
                    '           },' +
                    '           {' +
                    '               "url": "http://www.amoeiro.gal/wp-content/uploads/2023/09/compra-300x216.png",' +
                    '               "titulo": "Img 5"' +
                    '           },' +
                    '           {' +
                    '               "url": "http://www.amoeiro.gal/wp-content/uploads/2023/09/consumo-300x216.png",' +
                    '               "titulo": "Img 6"' +
                    '           },' +
                    '           {' +
                    '               "url": "http://www.amoeiro.gal/wp-content/uploads/2023/09/luz-e-gas-300x217.png",' +
                    '               "titulo": "Img 7"' +
                    '           }' +
                    '       ]' +
                    '   }' +
                    '}');
            }
            // Simulación de la respuesta JSON de la API para obtener detalles de las noticias
            else if (req.getEndpoint().contains('/noticias')) {
                // Usar DateTime.now() para simular la fecha actual en los detalles
                String fechaActual = DateTime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'+\'02:00');
                res.setBody('['+
                    '    {'+
                    '        "id": 25,'+
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