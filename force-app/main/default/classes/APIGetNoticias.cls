public class APIGetNoticias {
    // Método para obtener noticias y pasarlas a la cola de actualización
    public static void obtenerNoticias() {
        Integer bloqueSize = 1;
        String token = APILoginService.login();
        if (token == null || token == '') {
            System.debug('No se pudo obtener el token');
            return;
        }
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://apigrafo.depourense.es/api/noticias');
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + token);
        req.setHeader('Accept', 'application/json');
        Http http = new Http();
        HttpResponse res;
        Integer retryCount = 0;
        Boolean success = false;
        while (retryCount < 3 && !success) {
            try {
                res = http.send(req);
                if (res.getStatusCode() == 200) {
                    List<Object> noticias = (List<Object>) JSON.deserializeUntyped(res.getBody());
                    Set<String> idNoticias = new Set<String>();
                    Map<String, String> noticiasFechaMap = new Map<String, String>();
                    for (Object obj : noticias) {
                        Map<String, Object> noticia = (Map<String, Object>) obj;
                        String id = String.valueOf(noticia.get('id'));
                        String fechaModificacion = (String) noticia.get('fecha_modificacion');
                        idNoticias.add(id);
                        noticiasFechaMap.put(id, fechaModificacion);
                    }
                    List<String> idNoticiaList = new List<String>(idNoticias);
                    Map<String, Knowledge__kav> existingKnowledgeMap = getExistingKnowledgeRecords(idNoticiaList);
                    List<String> newRecordsToProcess = new List<String>();
                    List<String> existingRecordsToUpdate = new List<String>();
                    for (String idNoticia : idNoticiaList) {
                        if (!existingKnowledgeMap.containsKey(idNoticia)) {
                            newRecordsToProcess.add(idNoticia); // Nuevo registro
                        } else {
                            // Obtener la fecha_modificacion de Salesforce
                            Knowledge__kav existingKnowledge = existingKnowledgeMap.get(idNoticia);
                            String fechaModificacionApi = noticiasFechaMap.get(idNoticia);
                            DateTime fechaModificacionSalesforce = existingKnowledge.fecha_modificacion__c;
                            String fechaModificacionSinOffset = fechaModificacionApi.substring(0, 19).replace('T', ' ');
                            DateTime fechaModificacionApiDateTime = DateTime.valueOf(fechaModificacionSinOffset);
                            // Comparar solo la parte de la fecha
                            if (fechaModificacionApiDateTime.date() > fechaModificacionSalesforce.date()) {
                                existingRecordsToUpdate.add(idNoticia); // Agregar a la lista de actualización si la fecha es mayor
                            }
                        }
                    }
                    // Procesar nuevos registros en un batch job
                    if (!newRecordsToProcess.isEmpty()) {
                        List<String> idNoticiaListDivInsert = new List<String>(newRecordsToProcess);
                        List<List<String>> bloquesInsert = dividirLista(idNoticiaListDivInsert, bloqueSize);
                        for (List<String> bloqueidNoticiaInsert : bloquesInsert) {
                            System.debug('Procesando nuevos registros...');
                            Database.executeBatch(new NoticiaBatchable(bloqueidNoticiaInsert, token), 1);
                        }
                    }
                    // Actualizar registros existentes usando KnowledgeUpdater
                    if (!existingRecordsToUpdate.isEmpty()) {
                        List<String> idNoticiaListDivUpdate = new List<String>(existingRecordsToUpdate);
                        List<List<String>> bloquesUpdate = dividirLista(idNoticiaListDivUpdate, bloqueSize);
                        for (List<String> bloqueidNoticiaUpdate : bloquesUpdate) {
                            System.debug('Actualizando registros existentes...');
                            Database.executeBatch(new NoticiaUpdateBatchable(bloqueidNoticiaUpdate, token), 1);
                        }
                    }
                    success = true; // Marcar como éxito
                }
            } catch (System.CalloutException e) {
                if (e.getMessage().contains('Read timed out') || e.getMessage().contains('Expired JWT Token')) {
                    retryCount++;
                    System.debug('Timeout occurred, retrying: ' + retryCount);
                } else {
                    System.debug('Error al obtener noticias: ' + e.getMessage());
                    break;
                }
            }
        }
    }
    // Obtener los detalles de las noticias en bloques con retry logic
    public static List<String> obtenerDetallesNoticias(List<String> idNoticias, String token) {
        List<String> detallesJson = new List<String>();
        for (String idNoticia : idNoticias) {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://apigrafo.depourense.es/api/noticias/' + String.valueOf(idNoticia)); //Parsear el idNoticia
            //req.setEndpoint('https://apigrafo.depourense.es/api/noticias/80');
                req.setMethod('GET');
            req.setHeader('Authorization', 'Bearer ' + token);
            req.setHeader('Accept', 'application/json');
            Http http = new Http();
            HttpResponse res;
            Integer retryCount = 0;
            Boolean success = false;
            while (retryCount < 3 && !success) {
                try {
                    res = http.send(req);
                    if (res.getStatusCode() == 200) {
                        detallesJson.add(res.getBody());
                        success = true; // Marcar como éxito
                    }
                } catch (System.CalloutException e) {
                    if (e.getMessage().contains('Read timed out') || e.getMessage().contains('Expired JWT Token')) {
                        retryCount++;
                        System.debug('Timeout occurred, retrying: ' + retryCount);
                    } else {
                        System.debug('Error al obtener el detalle de la noticia: ' + e.getMessage());
                        break;
                    }
                }
            }
        }
        return detallesJson;
    }
    // Método para dividir una lista en bloques
    public static List<List<String>> dividirLista(List<String> lista, Integer bloqueSize) {
        List<List<String>> bloques = new List<List<String>>();
        for (Integer i = 0; i < lista.size(); i += bloqueSize) {
            List<String> bloque = new List<String>();
            for (Integer j = i; j < Math.min(i + bloqueSize, lista.size()); j++) {
                bloque.add(lista.get(j));
            }
            bloques.add(bloque);
        }
        return bloques;
    }
    // Método para consultar los registros de Knowledge en Salesforce
    public static Map<String, Knowledge__kav> getExistingKnowledgeRecords(List<String> idNoticias) {
        Map<String, Knowledge__kav> existingKnowledgeMap = new Map<String, Knowledge__kav>();
        // SOQL query para obtener los registros que ya existen en Salesforce
        List<Knowledge__kav> existingKnowledges = [
            SELECT Id, fecha_modificacion__c, Noticia_Id__c
            FROM Knowledge__kav
            WHERE Noticia_Id__c IN :idNoticias
        ];
        for (Knowledge__kav knowledge : existingKnowledges) {
            //Parsear el knowledge.Noticia_Id__c a String
            existingKnowledgeMap.put(knowledge.Noticia_Id__c, knowledge);
        }
        return existingKnowledgeMap;
    }
}