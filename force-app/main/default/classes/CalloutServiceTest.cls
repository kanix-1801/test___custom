/**
 * Created by chana.landau on 08/03/2022.
 */

@IsTest
private class CalloutServiceTest {

    @isTest static void calloutServiceTest() {
        Test.setMock(HttpCalloutMock.class, new CalloutServiceCalloutMock());
        CalloutService services = CalloutService.getInstance();
        services.getOrgName();
        services.isActive();
        CalloutService.ServiceSetting srv = services.getServiceSetting('Priority','PRIT_LOADDOC');
        System.debug(srv);
        String payload = '?results=5';
        services.calloutService(srv, payload);
    }

    @isTest static void calloutServiceOneStepTest() {
        Test.setMock(HttpCalloutMock.class, new CalloutServiceCalloutMock());
        CalloutService services = CalloutService.getInstance();
        services.getOrgName();
        services.isActive();
        String payload = '?results=5';
        services.calloutService('Priority', 'PRIT_LOADDOC', payload);
    }

    public class CalloutServiceCalloutMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"foo":"bar"}');
            res.setStatusCode(200);
            return res;
        }
    }
}