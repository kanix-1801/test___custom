/**
 * Created by chana.landau on 16/05/2022.
 */

@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {


        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"ZIP":"6713300","WARHSNAME":"8","UPDDOCNO":"sss78","TYPECODE":"03","STATDES":"Draft","PRIT_XIIMONTHFREE":"Y","PRIT_STCODE":"65456","PRIT_SHIPREMARK":"fgh","PRIT_SFORDNAME":"8017Z000003DjSrQAK","PRIT_OYEARDISCOUNT":"Y","PRIT_INTERFACE_SUBFORM":[{"EXECUTE":"Y"}],"PRIT_DOCLINE_SUBFORM":[{"REMARK":"XCVBN","QUANT":4.000,"PRIT_MONCHARGECONST":"Y","PRIT_BILLINGENDDATE":"2022-06-07","PDES":"SDFGH","PARTNAME":"789","DUEDATE":"2022-06-06","DISCOUNT":45.00},{"REMARK":"fdgg","QUANT":1,"PRIT_MONCHARGECONST":"Y","PRIT_BILLINGENDDATE":"2022-05-02","PRICE":78.000,"PDES":"ghjk","PARTNAME":"158","DUEDATE":"2022-05-01","DISCOUNT":7.00},{"REMARK":"fdgg","QUANT":1,"PRIT_MONCHARGECONST":"Y","PRIT_BILLINGENDDATE":"2022-05-02","PRICE":78.000,"PDES":"ghjk","PARTNAME":"158","DUEDATE":"2022-05-01","DISCOUNT":7.00}],"PRIT_DETAILS":"ertyu","PRIT_CUSTPERSONNEL_SUBFORM":[{"STATDES":"פעיל","PRIT_EXTERNALPHONE":"0037Z00001NYr1iQAD","NAME":"CHANA LANDAU","EMAIL":"c0583202@gmail.com","CELLPHONE":"052-8533766"}],"PRIT_BILLFREQUENCY":"חודשי","PRIT_AGENTPHONE2":"0502474747","PHONE3":"0528466312","PHONE2":"035674382","PHONE1":"0528466312","PDATE":"2022-05-04","LOADCODE":"200","ID":"4531shira","EXTCUST":"0017Z00001derRyQAI","EMAIL":"shira.hai43@allcloud.io","DETAILS":"dfghj","CUSTSTATDES":"פעיל","CUSTNAME":"4531shira","CUSTDES":"shira100322_3","CITY":"holon","ADDRESS":"tehon"}');
        res.setStatusCode(200);
        return res;
    }
}