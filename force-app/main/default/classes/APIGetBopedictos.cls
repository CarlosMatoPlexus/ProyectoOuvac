public class APIGetBopedictos {
    // Método para obtener Bopedictos y pasarlas a la cola de actualización
    public static void obtenerBopedictos() {
        Integer bloqueSize = 1;
        String token = APILoginService.login();
        if (token == null || token == '') {
            System.debug('No se pudo obtener el token');
            return;
        }
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://apigrafo.depourense.es/api/bop_edictos');
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
                    List<Object> bopedictos = (List<Object>) JSON.deserializeUntyped(res.getBody());
                    Set<String> idBopedictos = new Set<String>();
                    Map<String, String> BopedictosFechaMap = new Map<String, String>();
                    for (Object obj : bopedictos) {
                        Map<String, Object> bopedicto = (Map<String, Object>) obj;
                        String id = String.valueOf(bopedicto.get('id'));
                        String fechaModificacion = (String) bopedicto.get('fecha_modificacion');
                        idBopedictos.add(id);
                        BopedictosFechaMap.put(id, fechaModificacion);
                    }
                    List<String> idBopedictoList = new List<String>(idBopedictos);
                    Map<String, Knowledge__kav> existingKnowledgeMap = getExistingKnowledgeRecords(idBopedictoList);
                    List<String> newRecordsToProcess = new List<String>();
                    List<String> existingRecordsToUpdate = new List<String>();
                    for (String idBopedicto : idBopedictoList) {
                        if (!existingKnowledgeMap.containsKey(idBopedicto)) {
                            newRecordsToProcess.add(idBopedicto); // Nuevo registro
                        } else {
                            // Obtener la fecha_modificacion de Salesforce
                            Knowledge__kav existingKnowledge = existingKnowledgeMap.get(idBopedicto);
                            String fechaModificacionApi = BopedictosFechaMap.get(idBopedicto);
                            DateTime fechaModificacionSalesforce = existingKnowledge.fecha_modificacion__c;
                            String fechaModificacionSinOffset = fechaModificacionApi.substring(0, 19).replace('T', ' ');
                            DateTime fechaModificacionApiDateTime = DateTime.valueOf(fechaModificacionSinOffset);
                            // Comparar solo la parte de la fecha
                            if (fechaModificacionApiDateTime.date() > fechaModificacionSalesforce.date()) {
                                existingRecordsToUpdate.add(idBopedicto); // Agregar a la lista de actualización si la fecha es mayor
                            }
                        }
                    }
                    // Procesar nuevos registros en un batch job
                    if (!newRecordsToProcess.isEmpty()) {
                        List<String> idBopedictoListDivInsert = new List<String>(newRecordsToProcess);
                        List<List<String>> bloquesInsert = dividirLista(idBopedictoListDivInsert, bloqueSize);
                        for (List<String> bloqueidBopedictoInsert : bloquesInsert) {
                            System.debug('Procesando nuevos registros...');
                            //Database.executeBatch(new NoticiaBatchable(bloqueidBopedictoInsert, token), 1);
                        }
                    }
                    // Actualizar registros existentes usando KnowledgeUpdater
                    if (!existingRecordsToUpdate.isEmpty()) {
                        List<String> idBopedictoListDivUpdate = new List<String>(existingRecordsToUpdate);
                        List<List<String>> bloquesUpdate = dividirLista(idBopedictoListDivUpdate, bloqueSize);
                        for (List<String> bloqueidBopedictoUpdate : bloquesUpdate) {
                            System.debug('Actualizando registros existentes...');
                            //Database.executeBatch(new NoticiaUpdateBatchable(bloqueidBopedictoUpdate, token), 1);
                        }
                    }
                    success = true; // Marcar como éxito
                }
            } catch (System.CalloutException e) {
                if (e.getMessage().contains('Read timed out') || e.getMessage().contains('Expired JWT Token')) {
                    retryCount++;
                    System.debug('Timeout occurred, retrying: ' + retryCount);
                } else {
                    System.debug('Error al obtener bopedictos: ' + e.getMessage());
                    break;
                }
            }
        }
    }
    // Obtener los detalles de las bopedictos en bloques con retry logic
    public static List<String> obtenerDetallesBopedictos(List<String> idBopedictos, String token) {
        List<String> detallesJson = new List<String>();
        for (String idBopedicto : idBopedictos) {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://apigrafo.depourense.es/api/bop_edictos/' + String.valueOf(idBopedicto)); //Parsear el idBopedicto
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
                        System.debug('Error al obtener el detalle de la bopedicto: ' + e.getMessage());
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
    public static Map<String, Knowledge__kav> getExistingKnowledgeRecords(List<String> idBopedictos) {
        Map<String, Knowledge__kav> existingKnowledgeMap = new Map<String, Knowledge__kav>();
        // SOQL query para obtener los registros que ya existen en Salesforce
        List<Knowledge__kav> existingKnowledges = [
            SELECT Id, fecha_modificacion__c, Bopedicto_Id__c
            FROM Knowledge__kav
            WHERE Bopedicto_Id__c IN :idBopedictos
        ];
        for (Knowledge__kav knowledge : existingKnowledges) {
            existingKnowledgeMap.put(knowledge.Bopedicto_Id__c, knowledge);
        }
        return existingKnowledgeMap;
    }
}