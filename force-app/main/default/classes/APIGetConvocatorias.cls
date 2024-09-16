public class APIGetConvocatorias {
    public static void obtenerConvocatorias() {
        // Token de autenticación
        String token = APILoginService.login();
        //String token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJpYXQiOjE3MjY0NzE0NzksImV4cCI6MTcyNjQ3NTA3OSwicm9sZXMiOlsiUk9MRV9VU0VSIiwxMF0sInVzZXJuYW1lIjoiZ25vc3MifQ.OqJFqXDlcFrLQM45639d7Six4Wzi3Uw_I6da0RDDv6FH5ucXy_Q454LbE3-_5JIED29L9bJCLLAkPLvSmeOKIboq2iQ1zrlnMdCVH8jKZ9_DNBZmfkO0ixHA-0AS2uicwFHQ1u4TzLoF_HG0SiAawHJe5vwsrMRBuEtYmN7n93xczWbnxS2zWOCKWVrM_zjYpvecMhOggSpHCvG9iDqfpCbqnhLQNZZps9Xqy1WtX6-_ElkJGqzTpD3dCLyvx4EdgDkPNZM4Qdkax8PT2hEHzLll-_93ShfBa1e6nUF2rTOfXNLO99PLDJXZbNcRppjn6KsfmHdST2Ii2KEGHsGfAg';
        System.debug('Token: '+ token );
        if (token == null || token == '') {
            System.debug('No se pudo obtener el token');
            return;
        }
        // Configurar la llamada HTTP para obtener las convocatorias
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://apigrafo.depourense.es/api/convocatorias');
        // req.setCompressed(true);
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
                codeBdns.add('773553');
                //codeBdns.add('384926');
                //codeBdns.add(codeBdn);
                break;
            }
            // Procesar en bloques y enviar a la cola
            Integer bloqueSize = 1;
            List<String> codeBdnList = new List<String>(codeBdns);
            List<List<String>> bloques = dividirLista(codeBdnList, bloqueSize);
            for (List<String> bloqueCodeBdns : bloques) {
                // Encolar el trabajo para procesar cada bloque
                System.debug('bloqueCodeBdns: ' + bloqueCodeBdns);
                System.enqueueJob(new ConvocatoriaQueueable(bloqueCodeBdns, token));
                break;
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