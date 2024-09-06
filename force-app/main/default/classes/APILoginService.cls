public class APILoginService {
    public class LoginResponse {
        public String token;
        public String refresh_token;
        public Long refresh_token_expiration;
    }

    public static String login() {
        APICredentials__mdt credentials = APICredentials__mdt.getInstance('Default_Credentials');
        if (credentials == null) {
            System.debug('No se encontraron las credenciales en el Custom Metadata');
            return null;
        }
        String endpoint = '/api/private/login_check';
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:APILogin' + endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('accept', 'application/json');
        //req.setTimeout(1500);
        Map<String, String> credentialsMap = new Map<String, String>{
            'username' => credentials.Username__c,
            'password' => credentials.Password__c
        };
        req.setBody(JSON.serialize(credentialsMap));
        Http http = new Http();
        HttpResponse res;
        try {
            res = http.send(req);
        } catch(CalloutException e) {
            System.debug('Callout error: ' + e);
            return null;
        }
        if (res.getStatusCode() == 200) {
            LoginResponse loginResponse = (LoginResponse) JSON.deserialize(res.getBody(), LoginResponse.class);
            System.debug('loginResponse.token: ' + loginResponse.token);
            return loginResponse.token;
        } else {
            System.debug('Failed with status code: ' + res.getStatusCode());
            System.debug('Response: ' + res.getBody());
            return null;
        }
    }
    @future
    public static void saveTokens(String token, String refreshToken, Long refreshTokenExpiration) {
        List<TokenStorage__c> tokenStorageList = [SELECT Id, Token__c, TokenExpiration__c, RefreshToken__c FROM TokenStorage__c LIMIT 1];
        TokenStorage__c tokenStorage;
        if (!tokenStorageList.isEmpty()) {
            tokenStorage = tokenStorageList[0];
        } else {
            tokenStorage = new TokenStorage__c();
        }
        tokenStorage.Token__c = token;
        tokenStorage.RefreshToken__c = refreshToken;
        tokenStorage.TokenExpiration__c = DateTime.newInstance(refreshTokenExpiration * 1000);
        upsert tokenStorage;
    }
    public static String getToken() {
        TokenStorage__c tokenStorage = [SELECT Token__c, TokenExpiration__c, RefreshToken__c FROM TokenStorage__c LIMIT 1];
        if (tokenStorage != null) {
            String response =  (tokenStorage.Token__c);
            if (response.contains('"code": 401') && response.contains('"message": "Expired JWT Token"')) {
                return refreshAccessToken(tokenStorage.RefreshToken__c);
            } else {
                return tokenStorage.Token__c;
            }
        } else {
            return login();
        }
    }
    public static String refreshAccessToken(String refreshToken) {
        String endpoint = '/api/token/refresh';
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:APILogin' + endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('accept', 'application/json');
        Map<String, String> refreshTokenMap = new Map<String, String>{
            'refresh_token' => refreshToken
        };
        req.setBody(JSON.serialize(refreshTokenMap));
        Http http = new Http();
        HttpResponse res;
        try {
            res = http.send(req);
            if (res.getStatusCode() == 200) {
                LoginResponse loginResponse = (LoginResponse) JSON.deserialize(res.getBody(), LoginResponse.class);
                saveTokens(loginResponse.token, loginResponse.refresh_token, loginResponse.refresh_token_expiration);
                return loginResponse.token;
            } else {
                System.debug('Failed to refresh token with status code: ' + res.getStatusCode());
                System.debug('Response: ' + res.getBody());
                return null;
            }
        } catch(CalloutException e) {
            System.debug('Callout error: ' + e);
            return null;
        }
    }
}