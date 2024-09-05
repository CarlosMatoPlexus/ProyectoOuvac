public class APIGetConvocatorias {
    public static void obtenerConvocatorias() {
        // Token de autenticación
        String token = APILoginService.login();
        //String token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJpYXQiOjE3MjU0NTEwMjksImV4cCI6MTcyNTQ1NDYyOSwicm9sZXMiOlsiUk9MRV9VU0VSIiwxMF0sInVzZXJuYW1lIjoiZ25vc3MifQ.tApPX9xirySkSjTx3uVcPKMsTUe22r0cSq6pl0q8vuJ2laBHcH4NfAtGJu9SmaF51tvhRGQB0zbNAOuscSuUf-WlTzhf__AMiDyJx7HVA46bD2Prf_kJLUBjN5p_nRMpd8i01ZCLV6UzfoKQ54A28V5a4KDdD-H1lJEg8K1R0hR6GEFYlMgbtdlnPwosQ4g5zBWxwrVjhNO_ebKB6y4kFag8m8eyIvacwZysQmIf2FkZqEE7h_ics0VFI6CA2Wy0AH_R20mxKkfGsT6a_ZYbGDTJv1sOJ4qK9fqOnRymfP4mBsz0b8nHdwWpT9saZfoYlYssQXWttRJ9Hwb9SDJvgA';
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
                System.debug(responseBlob.size());
                detallesJson.add(res.getBody());
                //Integer maxSize = 120000;
                // if (responseBlob.size() > maxSize) {
                //     System.debug('Respuesta demasiado grande para procesar: ' + res.getBody().length());
                //     continue;
                // }else {
                //     detallesJson.add(res.getBody());
                // }
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