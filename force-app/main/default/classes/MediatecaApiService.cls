public class MediatecaApiService {
    @testVisible
    private static Mediateca_Last_Sync__mdt lastSyncMetadata;
    private static final String Mediateca_Api_EndPoint = Mediateca_Endpoint__mdt.GetInstance('Mediateca_Url').Url__c;
    
    // Wrapper class para parsear JSON
    public class ApiResponse {
        public String version;
        public Header header;
        public Data data;
    }
    public class Header {
        public String timestamp;
        public String timezone;
        public String request;
        public Result result;
    }
    public class Result {
        public Integer status;
        public String message;
    }
    public class Data {
        public ItemList itemList;
    }
    public class ItemList {
        public Summary summary;
        public List<Item> items;
    }
    public class Summary {
        public Integer page;
        public Integer page_records;
        public Integer page_offset;
        public Integer total_records;
        public Integer total_pages;
        public Integer page_size;
    }
    public class Item {
        public String id;
        public String event_at;
        public String created_at;
        public String updated_at;
        public String href;
        public Metadata metadata;
    }
    public class Metadata {
        public String title;
        public String description;
        public String category;
        public String emblem;
    }
    
    // Metodo para obtener el json de la Api
    public static void syncKnowledgeData() {
        if (lastSyncMetadata == null) {
            lastSyncMetadata = [SELECT LastSyncDate__c FROM Mediateca_Last_Sync__mdt WHERE DeveloperName = 'LastSyncDate' LIMIT 1];
        }
        DateTime lastSyncDate = lastSyncMetadata.LastSyncDate__c;
        Datetime today = Date.today();
        // Formatear las fechas según el formato requerido por la API
        String lastSyncDateFormatted = formatDateTimeForApi(lastSyncDate);
        String todayFormatted = formatDateTimeForApi(today);
        // Construir la URL de la API con los parámetros de fecha
        String url = Mediateca_Api_EndPoint + '?date_from=' + lastSyncDateFormatted + '&date_to=' + todayFormatted;
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type','application/json;charset=UTF-8');
        Http http = new Http();
        HttpResponse res;
        try {
            res = http.send(req);
            if (res.getStatusCode() == 200) {
                ApiResponse apiResponse = (ApiResponse) JSON.deserialize(res.getBody(), ApiResponse.class);
                // Extracto manual de 'list' si itemList es nulo
                if (apiResponse.data != null && apiResponse.data.itemList == null) {
                    Map<String, Object> jsonData = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                    if (jsonData.containsKey('data') && ((Map<String, Object>) jsonData.get('data')).containsKey('list')) {
                        String listJson = JSON.serialize(((Map<String, Object>) jsonData.get('data')).get('list'));
                        apiResponse.data.itemList = (ItemList) JSON.deserialize(listJson, ItemList.class);
                    }
                }
                // Procesar items
                if (apiResponse.data != null && apiResponse.data.itemList != null && apiResponse.data.itemList.items != null) {
                    Map<String, Item> itemsMap = new Map<String, Item>();
                    for (Item item : apiResponse.data.itemList.items) {
                        itemsMap.put(item.id, item);
                    }
                    upsertKnowledge(itemsMap);
                    // Llamar a updateLastSyncDate en una transacción futura
                    CustomMetadataUpdateService.updateLastSyncDateAsync(today);
                } else {
                    System.debug('No items found in the response.');
                }
            } else {
                System.debug('HTTP request failed with status code: ' + res.getStatusCode());
            }
        } catch (Exception e) {
            System.debug('Error during API call: ' + e.getMessage());
        }
    }

    public static DateTime parseDateTime(String dateTimeString) {
        try {
            if (dateTimeString.endsWith('Z')) {
                // UTC formato sin zona horaria
                return DateTime.valueOf(dateTimeString.substring(0, 19).replace('T', ' '));
            } else if (dateTimeString.length() > 19 && (dateTimeString.substring(19, 20) == '+' || dateTimeString.substring(19, 20) == '-')) {
                // Zona horaria en formato +hh:mm o -hh:mm
                String dateTimeWithoutOffset = dateTimeString.substring(0, 19).replace('T', ' ');
                String offset = dateTimeString.substring(19);
                DateTime dateTimeUtc = DateTime.valueOf(dateTimeWithoutOffset);
                Integer offsetHours = Integer.valueOf(offset.substring(1, 3));
                Integer offsetMinutes = Integer.valueOf(offset.substring(4, 6));
                if (offset.startsWith('-')) {
                    offsetHours = -offsetHours;
                    offsetMinutes = -offsetMinutes;
                }
                return dateTimeUtc.addHours(-offsetHours).addMinutes(-offsetMinutes);
            } else {
                // Formato de fecha y hora sin zona horaria
                return DateTime.valueOf(dateTimeString.replace('T', ' '));
            }
        } catch (Exception e) {
            // Si el formato es inválido, retorna null
            System.debug('Error parsing date: ' + dateTimeString + ' - ' + e.getMessage());
            return null;
        }
    }
    
    
    public static DateTime convertToSpanishTime(DateTime dateTimeUtc) {
        // Horario estándar de España es UTC+1
        // Horario de verano es UTC+2
        Integer standardOffset = 1;
        Integer summerOffset = 2;
        // Crear las fechas para el último domingo de marzo y octubre
        Date lastSundayOfMarch = getLastSundayOfMonth(dateTimeUtc.year(), 3);
        Date lastSundayOfOctober = getLastSundayOfMonth(dateTimeUtc.year(), 10);
        // Crear DateTime a partir de estas fechas
        DateTime lastSundayOfMarchDateTime = DateTime.newInstance(lastSundayOfMarch.year(), lastSundayOfMarch.month(), lastSundayOfMarch.day(), 2, 0, 0);
        DateTime lastSundayOfOctoberDateTime = DateTime.newInstance(lastSundayOfOctober.year(), lastSundayOfOctober.month(), lastSundayOfOctober.day(), 2, 0, 0);
        // Ajustar el offset basado en el horario de verano
        Integer offset = (dateTimeUtc >= lastSundayOfMarchDateTime && dateTimeUtc < lastSundayOfOctoberDateTime) ? summerOffset : standardOffset;
        // Ajustar el DateTime a la hora de España
        return dateTimeUtc.addHours(offset);
    }
    
    private static Date getLastSundayOfMonth(Integer year, Integer month) {
        // Obtener el último día del mes
        Date lastDayOfMonth = Date.newInstance(year, month, Date.daysInMonth(year, month));
        // Encontrar el último domingo
        // El día de la semana del último día del mes, ajustado para que 1 sea domingo, 7 sea sábado
        Integer lastDayOfMonthDayOfWeek = (lastDayOfMonth.day() / 7);
        // Calcular la diferencia en días para llegar al último domingo
        Integer daysToSubtract = (lastDayOfMonthDayOfWeek == 0) ? 0 : (lastDayOfMonthDayOfWeek - 1);
        // Devolver el último domingo del mes
        return lastDayOfMonth.addDays(-daysToSubtract);
    }
    // Método para formatear DateTime según el formato requerido por la API
    public static String formatDateTimeForApi(Datetime urldateTime) {
        return urldateTime.format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
    }
    // Metodo para actualizar knowledge
    private static void upsertKnowledge(Map<String, Item> itemsMap) {
        Set<String> itemIds = itemsMap.keySet();
        List<Knowledge__kav> knowledgeList = [SELECT Id, Id_externo__c, Fecha_del_evento__c, Fecha_de_creacion__c, Fecha_de_actualizacion__c, Entidades__c, Ambitos__c, Title, Descripcion__c, Url__c, PublishStatus, KnowledgeArticleId FROM Knowledge__kav WHERE Id_externo__c IN :itemIds];
        Map<String, Knowledge__kav> existingKnowledgeMap = new Map<String, Knowledge__kav>();
        String mediatecaRecordTypeID = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('Mediateca').getRecordTypeId();
        for (Knowledge__kav knowledge : knowledgeList) {
            existingKnowledgeMap.put(knowledge.Id_externo__c, knowledge);
        }
        List<Knowledge__kav> toInsert = new List<Knowledge__kav>();
        List<Knowledge__kav> toUpdate = new List<Knowledge__kav>();
        for (Item item : itemsMap.values()) {
            DateTime eventDateTimeUtc = parseDateTime(item.event_at);
            DateTime createdDateTimeUtc = parseDateTime(item.created_at);
            DateTime updatedDateTimeUtc = parseDateTime(item.updated_at);
            DateTime eventDateTime = convertToSpanishTime(eventDateTimeUtc);
            DateTime createdDateTime = convertToSpanishTime(createdDateTimeUtc);
            DateTime updatedDateTime = convertToSpanishTime(updatedDateTimeUtc);
            if (existingKnowledgeMap.containsKey(item.id)) {
                Knowledge__kav knowledge = existingKnowledgeMap.get(item.id);
                if (knowledge.Fecha_de_actualizacion__c < parseDateTime(item.updated_at)) {
                    retractIfPublished(knowledge);
                    // Update existing record
                    knowledge.Fecha_del_evento__c = eventDateTime;
                    knowledge.Fecha_de_creacion__c = createdDateTime;
                    knowledge.Fecha_de_actualizacion__c = updatedDateTime;
                    knowledge.Entidades__c = 'Deputación';
                    if(item.metadata.emblem != ''){
                        knowledge.Ambitos__c = item.metadata.emblem;
                    }else {
                        knowledge.Ambitos__c = 'Transparencia';
                    }
                    knowledge.Title = item.metadata.title;
                    knowledge.Descripcion__c = item.metadata.description;
                    knowledge.Url__c = item.href;
                    toUpdate.add(knowledge);
                }
            } else {
                // Insertar nuevo registro
                Knowledge__kav knowledge = new Knowledge__kav();
                knowledge.RecordTypeId = mediatecaRecordTypeID;
                knowledge.Id_externo__c = item.id;
                knowledge.UrlName = item.id;
                knowledge.Descripcion__c = item.metadata.description;
                knowledge.Url__c = item.href;
                if(eventDateTime.year()>1900){
                    knowledge.Fecha_del_evento__c = eventDateTime;
                }
                if(createdDateTime.year()>1900){
                    knowledge.Fecha_de_creacion__c = createdDateTime;
                }
                if(updatedDateTime.year()>1900){
                    knowledge.Fecha_de_actualizacion__c = updatedDateTime;
                }
                knowledge.ValidationStatus = 'Validated';
                knowledge.Entidades__c = 'Deputación';
                if(item.metadata.emblem != ''){
                    knowledge.Ambitos__c = item.metadata.emblem;
                }else {
                    knowledge.Ambitos__c = 'Transparencia';
                }
                knowledge.Title = item.metadata.title;
                knowledge.UrlName = item.id;
                knowledge.Language = 'es';
                toInsert.add(knowledge);
            }
        }
        if (!toInsert.isEmpty()) {
            insert toInsert;
            System.debug('mediateca to insert: '+ toInsert.size());
        }
        if (!toUpdate.isEmpty()) {
            for(Knowledge__kav k : toUpdate){
                if(k.PublishStatus == 'Online'){
                    retractIfPublished(k);
                }
            }
            update toUpdate;
            System.debug('mediateca to update: '+ toUpdate.size());
        }
        // Publicar artículos
        if(!toInsert.isEmpty() || !toUpdate.isEmpty()){
            List<KnowledgeArticleVersion> lstKnowPublish = new List<KnowledgeArticleVersion>();
            lstKnowPublish = [SELECT Id, KnowledgeArticleId, PublishStatus FROM KnowledgeArticleVersion WHERE PublishStatus = 'Draft'];
            for(KnowledgeArticleVersion know : lstKnowPublish){
                KbManagement.PublishingService.publishArticle(know.KnowledgeArticleId, true);
            }
        }
    }
    private static void retractIfPublished(Knowledge__kav knowledge) {
        if (knowledge.PublishStatus == 'Online') {
            KbManagement.PublishingService.editOnlineArticle(knowledge.KnowledgeArticleId, false);
            System.debug('Retractando artículo con Id: ' + knowledge.Id);
        }
    }
}