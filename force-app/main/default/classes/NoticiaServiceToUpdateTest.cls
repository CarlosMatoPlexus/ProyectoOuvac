@isTest
public class NoticiaServiceToUpdateTest {
    @isTest
    static void testNoticiaServiceToUpdateTest() {
        // Configurar el mock para simular la llamada HTTP
        Test.setMock(HttpCalloutMock.class, new APIGetNoticiaMock());
        // Simular algunos datos existentes de Knowledge en Salesforce
        Knowledge__kav knowledgeEsp = new Knowledge__kav(
            Noticia_Id__c = '25',
        fecha_modificacion__c = DateTime.now().addDays(-2), // Fecha anterior para forzar actualización
        Title = 'knowledgeEsp',
        UrlName = 'knowledgeEsp',
        Language = 'es'
            );
        insert knowledgeEsp;
        Knowledge__kav knowledgeGal = new Knowledge__kav(
            Noticia_Id__c = '25',
        fecha_modificacion__c = DateTime.now().addDays(-2), // Fecha anterior para forzar actualización
        Title = 'knowledgeGal',
        UrlName = 'knowledgeGal',
        Language = 'es_MX'
            );
        insert knowledgeGal;
        // Ejecutar los métodos
        Test.startTest();
        List<String> detallesJson = new List<String>();
        List<String>  idNoticias = new List<String>();
        idNoticias.add('25');
        String token = 'mockToken123';
        detallesJson = APIGetNoticias.obtenerDetallesNoticias(idNoticias, token);
        NoticiaServiceToUpdate.updateNoticia(detallesJson);
        Test.stopTest();
        Knowledge__kav assignKnowEsp;
        Knowledge__kav assignKnowGal;
        List<Knowledge__kav> knowLst = [SELECT Id, fecha_modificacion__c, Language, Noticia_Id__c FROM Knowledge__kav WHERE Noticia_Id__c = '25'];
        
        for(Knowledge__kav k : knowLst){
            if(k.Language =='es'){
                assignKnowEsp = k;
            }else if (k.Language == 'es_MX') {
                assignKnowGal = k;
            }
        }
        //System.assertEquals(Datetime.now().date(), assignKnowEsp.fecha_modificacion__c.date(), 'La fecha de modificacion del registro Knowledge en esapñol debe ser igual que'+' '+ Datetime.now().date());
        System.assertEquals(Datetime.now().date(), assignKnowGal.fecha_modificacion__c.date(), 'La fecha de modificacion del registro Knowledge en galego debe ser igual que'+' '+ Datetime.now().date());
        System.assert(assignKnowEsp.fecha_modificacion__c.date() > knowledgeEsp.fecha_modificacion__c.date(), 'La fecha de modificacion del registro Knowledge en esapñol debe ser mayor.');
        System.assert(assignKnowGal.fecha_modificacion__c.date() > knowledgeGal.fecha_modificacion__c.date(), 'La fecha de modificacion del registro Knowledge en galego debe ser mayor.');
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
            // Simulación de la respuesta JSON de la API para noticia
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
            
            return res;
        }
    }
}