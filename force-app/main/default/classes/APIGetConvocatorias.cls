public class APIGetConvocatorias {
    // Método para obtener convocatorias y pasarlas a la cola de actualización
    public static void obtenerConvocatorias() {
        Integer bloqueSize = 1;
        String token = APILoginService.login();
        if (token == null || token == '') {
            System.debug('No se pudo obtener el token');
            return;
        }
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://apigrafo.depourense.es/api/convocatorias');
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
                    List<Object> convocatorias = (List<Object>) JSON.deserializeUntyped(res.getBody());
                    Set<String> codeBdns = new Set<String>();
                    Map<String, String> convocatoriaFechaMap = new Map<String, String>();
                    for (Object obj : convocatorias) {
                        Map<String, Object> convocatoria = (Map<String, Object>) obj;
                        String codeBdn = (String) convocatoria.get('code_bdns');
                        String fechaModificacion = (String) convocatoria.get('fecha_modificacion');
                        codeBdns.add(codeBdn);
                        convocatoriaFechaMap.put(codeBdn, fechaModificacion);
                    }
                    List<String> codeBdnList = new List<String>(codeBdns);
                    Map<String, Knowledge__kav> existingKnowledgeMap = getExistingKnowledgeRecords(codeBdnList);
                    List<String> newRecordsToProcess = new List<String>();
                    List<String> existingRecordsToUpdate = new List<String>();
                    for (String codeBdn : codeBdnList) {
                        if (!existingKnowledgeMap.containsKey(codeBdn)) {
                            newRecordsToProcess.add(codeBdn); // Nuevo registro
                        } else {
                            // Obtener la fecha_modificacion de Salesforce
                            Knowledge__kav existingKnowledge = existingKnowledgeMap.get(codeBdn);
                            String fechaModificacionApi = convocatoriaFechaMap.get(codeBdn);
                            DateTime fechaModificacionSalesforce = existingKnowledge.fecha_modificacion__c;
                            String fechaModificacionSinOffset = fechaModificacionApi.substring(0, 19).replace('T', ' ');
                            DateTime fechaModificacionApiDateTime = DateTime.valueOf(fechaModificacionSinOffset);
                            // Comparar solo la parte de la fecha
                            if (fechaModificacionApiDateTime.date() > fechaModificacionSalesforce.date()) {
                                existingRecordsToUpdate.add(codeBdn); // Agregar a la lista de actualización si la fecha es mayor
                            }
                        }
                    }
                    // Procesar nuevos registros en un batch job
                    if (!newRecordsToProcess.isEmpty()) {
                        List<String> codeBdnListDivInsert = new List<String>(newRecordsToProcess);
                        List<List<String>> bloquesInsert = dividirLista(codeBdnListDivInsert, bloqueSize);
                        for (List<String> bloqueCodeBdnsInsert : bloquesInsert) {
                            System.debug('Procesando nuevos registros...');
                            Database.executeBatch(new ConvocatoriaBatchable(bloqueCodeBdnsInsert, token), 1);
                        }
                    }
                    // Actualizar registros existentes usando KnowledgeUpdater
                    if (!existingRecordsToUpdate.isEmpty()) {
                        List<String> codeBdnListDivUpdate = new List<String>(existingRecordsToUpdate);
                        List<List<String>> bloquesUpdate = dividirLista(codeBdnListDivUpdate, bloqueSize);
                        for (List<String> bloqueCodeBdnsUpdate : bloquesUpdate) {
                            System.debug('Actualizando registros existentes...');
                            Database.executeBatch(new ConvocatoriaUpdateBatchable(bloqueCodeBdnsUpdate, token), 1);
                        }
                    }
                    success = true; // Marcar como éxito
                }
            } catch (System.CalloutException e) {
                if (e.getMessage().contains('Read timed out') || e.getMessage().contains('Expired JWT Token')) {
                    retryCount++;
                    System.debug('Timeout occurred, retrying: ' + retryCount);
                } else {
                    System.debug('Error al obtener convocatorias: ' + e.getMessage());
                    break;
                }
            }
        }
    }
    // Obtener los detalles de las convocatorias en bloques con retry logic
    public static List<String> obtenerDetallesConvocatorias(List<String> codeBdns, String token) {
        List<String> detallesJson = new List<String>();
        for (String codeBdn : codeBdns) {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://apigrafo.depourense.es/api/convocatorias/' + codeBdn);
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
                        System.debug('Error al obtener el detalle de la convocatoria: ' + e.getMessage());
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
    public static Map<String, Knowledge__kav> getExistingKnowledgeRecords(List<String> codeBdns) {
        Map<String, Knowledge__kav> existingKnowledgeMap = new Map<String, Knowledge__kav>();
        // SOQL query para obtener los registros que ya existen en Salesforce
        List<Knowledge__kav> existingKnowledges = [
            SELECT Id, code_bdns__c, fecha_modificacion__c
            FROM Knowledge__kav
            WHERE code_bdns__c IN :codeBdns
        ];
        for (Knowledge__kav knowledge : existingKnowledges) {
            existingKnowledgeMap.put(knowledge.code_bdns__c, knowledge);
        }
        return existingKnowledgeMap;
    }
}