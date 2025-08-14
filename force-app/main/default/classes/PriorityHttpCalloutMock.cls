/**
 * Created by chana.landau on 06/03/2022.
 */

@IsTest
public class PriorityHttpCalloutMock implements HttpCalloutMock {
    public string METHOD_NAME;
    public PriorityHttpCalloutMock(String methodName){
        this.METHOD_NAME = methodName;
    }
    @IsTest
    static void testBehavior() {
    }

    public HttpResponse respond(HttpRequest param1) {
        HttpResponse respon = new HttpResponse();
        respon.setHeader('Content-Type', 'application/json');
        if (METHOD_NAME == 'PRIT_LOADDOC') {
            respon.setBody('{"isSuccess":true,"error":null,"Id":"Abh5mclRnbp5Sdy9mZulmLkV3bsNWPl1WYOR3cvhkJ3ITQzUSMyE0MlIjMrgDMtITMtEjMwITPw1WY0NVZtlGVmkDN3gDNwETPklkclNXV","priorityAccountRes":{"LINE":"1234L","SUCCESS":"Y"}}');
        }
        respon.setStatusCode(200);
        return respon;
    }


}