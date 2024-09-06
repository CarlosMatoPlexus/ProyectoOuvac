public class APIGetConvocatorias {
    public static void obtenerConvocatorias() {
        // Token de autenticación
        String token = APILoginService.login();
        //String token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJpYXQiOjE3MjU1MzE4MjcsImV4cCI6MTcyNTUzNTQyNywicm9sZXMiOlsiUk9MRV9VU0VSIiwxMF0sInVzZXJuYW1lIjoiZ25vc3MifQ.ZCnBg4OnGwiVPto6hLJj6qivGjOmwEb_YxXAVmMdKrE8V3Ul9z3zaYPqGRHvukrXqTuf7svFQ6oB3uHJStuhUWGd2TeBxI9AmDDOua_ZwRWyesfVazk4BE4NoBwhNcI2bmAGj62eMrxzE5NwZOtAWDQ69kMX7kB6LZOOA2iVK5nzzbBxI-a1BcvBv4OZEtcZe6w0GOB3r82mdmVVt21h50cwRn58DFIsYY330zzt0mWvpjZIRwVbr0C_AZAbff6vc3OLK_lp7EToQ2qD-jyn1kGnHsXEgiYNgMCNxwvdRbggdKBi1gAvcvQCDqIh5QOB46GFlZbLE45b5jIkv-mnBg';
        System.debug('Token: '+ token );
        if (token == null || token == '') {
            System.debug('No se pudo obtener el token');
            return;
        }
        // Configurar la llamada HTTP para obtener las convocatorias
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://apigrafo.depourense.es/api/convocatorias');
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + token);
        req.setHeader('Accept', 'application/json');
        //req.setTimeout(2000);
        Http http = new Http();
        HttpResponse res = http.send(req);
        if(res.getStatusCode() == 200) {
            List<Object> convocatorias = (List<Object>) JSON.deserializeUntyped(res.getBody());
            Set<String> codeBdns = new Set<String>();
            for (Object obj : convocatorias) {
                Map<String, Object> convocatoria = (Map<String, Object>) obj;
                String codeBdn = (String) convocatoria.get('code_bdns');
                //codeBdns.add('773553');
                //codeBdns.add('384926');
                codeBdns.add(codeBdn);
                //break;
            }
            // Procesar en bloques y enviar a la cola
            Integer bloqueSize = 1;
            List<String> codeBdnList = new List<String>(codeBdns);
            List<List<String>> bloques = dividirLista(codeBdnList, bloqueSize);
            for (List<String> bloqueCodeBdns : bloques) {
                // Encolar el trabajo para procesar cada bloque
                System.debug('bloqueCodeBdns: ' + bloqueCodeBdns);
                System.enqueueJob(new ConvocatoriaQueueable(bloqueCodeBdns, token));
                //break;
            }
        } else {
            System.debug('Error al obtener convocatorias: ' + res.getBody());
        }
    }
    // Obtener los detalles de las convocatorias en bloques
    public static List<String> obtenerDetallesConvocatorias(List<String> codeBdns, String token) {
        List<String> detallesJson = new List<String>();
        for (String codeBdn : codeBdns) {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://apigrafo.depourense.es/api/convocatorias/' + codeBdn);
            req.setMethod('GET');
            req.setHeader('Authorization', 'Bearer ' + token);
            req.setHeader('Accept', 'application/json');
            //req.setTimeout(1000);
            Http http = new Http();
            HttpResponse res = http.send(req);
            if (res.getStatusCode() == 200) {
                Blob responseBlob = Blob.valueOf(res.getBody());
                System.debug('Tamaño del archivo: '+responseBlob.size());
                detallesJson.add(res.getBody());
                Integer maxSize = 12000000;
                if (responseBlob.size() > maxSize) {
                    System.debug('Respuesta demasiado grande para procesar: ' + res.getBody().length());
                    continue;
                }else {
                    detallesJson.add(res.getBody());
                }
            } else {
                System.debug('Error al obtener el detalle de la convocatoria: ' + res.getBody());
            }
        }
        return detallesJson;
    }
    // Método para dividir una lista en bloques
    public static List<List<String>> dividirLista(List<String> lista, Integer bloqueSize) {
        List<List<String>> bloques = new List<List<String>>();
        for (Integer i = 0; i < lista.size(); i += bloqueSize) {
            // Crear un bloque para la sublista
            List<String> bloque = new List<String>();
            for (Integer j = i; j < Math.min(i + bloqueSize, lista.size()); j++) {
                bloque.add(lista.get(j));
            }
            bloques.add(bloque);
        }
        return bloques;
    }
}