@isTest
public class NoticiaServiceToUpdateTest {
    @isTest
    static void testNoticiaServiceUpdateConPublicacionFinal() {
        // Configurar mock
        Test.setMock(HttpCalloutMock.class, new APIGetNoticiaMock());
        // Obtener RecordType válido
        Id recordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Knowledge__kav' AND DeveloperName = 'Noticias' LIMIT 1].Id;
        // Insertar versión inicial en español
        Knowledge__kav knowledgeEsp = new Knowledge__kav(
            Noticia_Id__c = '25',
        fecha_modificacion__c = DateTime.now().addDays(-5),
        Title = 'knowledgeEsp',
        UrlName = 'knowledgeEsp',
        Language = 'es',
        RecordTypeId = recordTypeId,
        ValidationStatus = 'Validated'
            );
        insert knowledgeEsp;
        knowledgeEsp = [
           SELECT Id, KnowledgeArticleId
           FROM Knowledge__kav
           WHERE Id = :knowledgeEsp.Id
           LIMIT 1
       ];
        KbManagement.PublishingService.publishArticle(knowledgeEsp.KnowledgeArticleId, true);
        // Insertar versión inicial en gallego
        Knowledge__kav knowledgeGal = new Knowledge__kav(
            Noticia_Id__c = '25',
        fecha_modificacion__c = DateTime.now().addDays(-5),
        Title = 'knowledgeGal',
        UrlName = 'knowledgeGal',
        Language = 'es_MX',
        RecordTypeId = recordTypeId,
        ValidationStatus = 'Validated'
            );
        insert knowledgeGal;
        knowledgeGal = [
           SELECT Id, KnowledgeArticleId
           FROM Knowledge__kav
           WHERE Id = :knowledgeGal.Id
           LIMIT 1
       ];
        KbManagement.PublishingService.publishArticle(knowledgeGal.KnowledgeArticleId, true);
        // Ejecutar actualización
        Test.startTest();
        List<String> idNoticias = new List<String>{'25'};
        String token = 'mockToken123';
        List<String> detallesJson = APIGetNoticias.obtenerDetallesNoticias(idNoticias, token);
        NoticiaServiceToUpdate.updateNoticia(detallesJson);
        Test.stopTest();
        // Obtener versiones Knowledge para la noticia ID 25
        List<Knowledge__kav> versiones = [
           SELECT Id, Language, PublishStatus, KnowledgeArticleId, fecha_modificacion__c
           FROM Knowledge__kav
           WHERE Noticia_Id__c = '25'
       ];
        // Verificar que haya 2 registros en total
        System.assertEquals(2, versiones.size(), 'Debe haber 2 versiones en total');
        // Determinar la última versión por idioma
        Knowledge__kav nuevaEs;
        Knowledge__kav nuevaGl;
        for (Knowledge__kav v : versiones) {
            if (v.Language == 'es' && (nuevaEs == null || v.fecha_modificacion__c > nuevaEs.fecha_modificacion__c)) {
                nuevaEs = v;
            } else if (v.Language == 'es_MX' && (nuevaGl == null || v.fecha_modificacion__c > nuevaGl.fecha_modificacion__c)) {
                nuevaGl = v;
            }
        }
        // Validaciones por idioma
        System.assertNotEquals(null, nuevaEs, 'No se encontró versión ES');
        System.assertNotEquals(null, nuevaGl, 'No se encontró versión GL');
        System.assertEquals(DateTime.now().date(), nuevaEs.fecha_modificacion__c.date(), 'Fecha ES incorrecta');
        System.assertEquals(DateTime.now().date(), nuevaGl.fecha_modificacion__c.date(), 'Fecha GL incorrecta');
    }
    // Mock de API
    private class APIGetNoticiaMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            if (req.getEndpoint().contains('/noticias/25')) {
                String fechaActual = DateTime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'+\'02:00');
                res.setBody('{' +
                    '"id": 25,' +
                    '"titulo": "Noticia test",' +
                    '"descripcion": "Descripción de prueba",' +
                    '"institucion": {"code": "001", "name": "Test"},' +
                    '"tema": {"code": "002", "name": "General"},' +
                    '"activo": true,' +
                    '"fecha_creacion": "2024-08-06T19:53:37+02:00",' +
                    '"fecha_modificacion": "' + fechaActual + '",' +
                    '"ambito": {"code": "001", "name": "Test"},' +
                    '"data_es_json": {' +
                    '"titulo": "Título ES",' +
                    '"url": "https://test.es",' +
                    '"date": "2023-09-30T00:00:00+02:00",' +
                    '"contenido": "Contenido ES",' +
                    '"categorias": ["uno", "dos"],' +
                    '"imagenes": [{"url": "https://img.png", "titulo": "Img 1"}]' +
                '},' +
                    '"data_gl_json": {' +
                    '"titulo": "Título GL",' +
                    '"url": "https://test.gl",' +
                    '"date": "2023-09-30T00:00:00+02:00",' +
                    '"contenido": "Contenido GL",' +
                    '"categorias": ["tres", "cuatro"],' +
                    '"imagenes": [{"url": "https://img.png", "titulo": "Img 1"}]' +
                '}' +
                    '}');
            }
            return res;
        }
    }
}