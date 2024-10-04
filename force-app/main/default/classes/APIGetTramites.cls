public class APIGetTramites {
    // Método para obtener tramites y pasarlas a la cola de actualización
    public static void obtenerTramites() {
        Integer bloqueSize = 1;
        String token = APILoginService.login();
        if (token == null || token == '') {
            System.debug('No se pudo obtener el token');
            return;
        }
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://apigrafo.depourense.es/api/tramites');
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
                    List<Object> tramites = (List<Object>) JSON.deserializeUntyped(res.getBody());
                    Set<String> setIdTramite = new Set<String>();
                    Map<String, String> tramiteFechaMap = new Map<String, String>();
                    for (Object obj : tramites) {
                        Map<String, Object> tramite = (Map<String, Object>) obj;
                        Integer tramiteId = (Integer)tramite.get('id');
                        String stringTramiteId = String.valueOf(tramiteId);
                        String fechaModificacion = (String) tramite.get('fecha_modificacion');
                        setIdTramite.add(stringTramiteId);
                        tramiteFechaMap.put(stringTramiteId, fechaModificacion);
                    }
                    List<String> idTramiteList = new List<String>(setIdTramite);
                    Map<String, Knowledge__kav> existingKnowledgeMap = getExistingKnowledgeRecords(idTramiteList);
                    List<String> newRecordsToProcess = new List<String>();
                    List<String> existingRecordsToUpdate = new List<String>();
                    for (String tramiteId : idTramiteList) {
                        if (!existingKnowledgeMap.containsKey(tramiteId)) {
                            newRecordsToProcess.add(tramiteId);
                        } else {
                            // Obtener la fecha_modificacion de Salesforce
                            Knowledge__kav existingKnowledge = existingKnowledgeMap.get(tramiteId);
                            String fechaModificacionApi = tramiteFechaMap.get(tramiteId);
                            DateTime fechaModificacionSalesforce = existingKnowledge.fecha_modificacion__c;
                            String fechaModificacionSinOffset = fechaModificacionApi.substring(0, 19).replace('T', ' ');
                            DateTime fechaModificacionApiDateTime = DateTime.valueOf(fechaModificacionSinOffset);
                            // Comparar solo la parte de la fecha
                            if (fechaModificacionApiDateTime.date() > fechaModificacionSalesforce.date()) {
                                System.debug('tramite to update: '+' '+ tramiteId);
                                existingRecordsToUpdate.add(tramiteId); // Agregar a la lista de actualización si la fecha es mayor
                            }
                        }
                    }
                    // Procesar nuevos registros en un batch job
                    if (!newRecordsToProcess.isEmpty()) {
                        List<String> idTramiteListDivInsert = new List<String>(newRecordsToProcess);
                        List<List<String>> bloquesInsert = dividirLista(idTramiteListDivInsert, bloqueSize);
                        for (List<String> bloqueIdTramiteInsert : bloquesInsert) {
                            System.debug('Procesando nuevos registros...');
                            System.debug('Procesando nuevos registros...' + bloqueIdTramiteInsert);
                            Database.executeBatch(new TramiteBatchable(bloqueIdTramiteInsert, token), 1);
                        }
                    }
                    // Actualizar registros existentes usando KnowledgeUpdater
                    if (!existingRecordsToUpdate.isEmpty()) {
                        List<String> idTramiteListDivUpdate = new List<String>(existingRecordsToUpdate);
                        List<List<String>> bloquesUpdate = dividirLista(idTramiteListDivUpdate, bloqueSize);
                        for (List<String> bloqueIdTramiteUpdate : bloquesUpdate) {
                            System.debug('Actualizando registros existentes...');
                            System.debug('Actualizando registros existentes...' + bloqueIdTramiteUpdate);
                            Database.executeBatch(new TramiteUpdateBatchable(bloqueIdTramiteUpdate, token), 1);
                        }
                    }
                    success = true; // Marcar como éxito
                }
            } catch (System.CalloutException e) {
                if (e.getMessage().contains('Read timed out') || e.getMessage().contains('Expired JWT Token')) {
                    retryCount++;
                    System.debug('Timeout occurred, retrying: ' + retryCount);
                } else {
                    System.debug('Error al obtener los trámites: ' + e.getMessage());
                    break;
                }
            }
        }
    }
    
    // Obtener los detalles de las tramites en bloques con retry logic
    public static List<String> obtenerDetallesTramites(List<String> idTramites, String token) {
        List<String> detallesJson = new List<String>();
        for (String idTramite : idTramites) {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://apigrafo.depourense.es/api/tramites/' + idTramite);
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
                        System.debug('Error al obtener el detalle del tramite: ' + e.getMessage());
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
    public static Map<String, Knowledge__kav> getExistingKnowledgeRecords(List<String> idTramiteList) {
        Map<String, Knowledge__kav> existingKnowledgeMap = new Map<String, Knowledge__kav>();
        // SOQL query para obtener los registros que ya existen en Salesforce
        List<Knowledge__kav> existingKnowledges = [
            SELECT Id, Tramite_id__c, fecha_modificacion__c, Tramite_codigo__c
            FROM Knowledge__kav
            WHERE Tramite_id__c IN :idTramiteList
        ];
        for (Knowledge__kav knowledge : existingKnowledges) {
            existingKnowledgeMap.put(knowledge.Tramite_id__c, knowledge);
        }
        return existingKnowledgeMap;
    }
    
}