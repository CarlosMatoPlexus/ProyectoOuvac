public class APILoginService {
    public class LoginResponse {
        public String token;
        public String refresh_token;
        public Long refresh_token_expiration;
    }
    public static LoginResponse login() {
        String endpoint = '/api/private/login_check';
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:APILogin' + endpoint);
        //req.setEndpoint('callout:APILogin');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('accept', 'application/json');
        // Crear el cuerpo de la solicitud
        Map<String, String> credentials = new Map<String, String>{
            'username' => 'gnoss',
            'password' => 'o0qf39Gh8I'
        };
        req.setBody(JSON.serialize(credentials));
        Http http = new Http();
        HttpResponse res;
        try {
            res = http.send(req);
        } catch(CalloutException e) {
            System.debug('Callout error: ' + e);
            return null;
        }
        if (res.getStatusCode() == 200) {
            System.debug(res.getBody());
            return (LoginResponse) JSON.deserialize(res.getBody(), LoginResponse.class);
        } else {
            System.debug('Failed with status code: ' + res.getStatusCode());
            System.debug('Response: ' + res.getBody());
            return null;
        }
    }
 }
