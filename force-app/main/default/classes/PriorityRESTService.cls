/**
 * Created by chana.landau on 02/03/2022.
 */

public with sharing class PriorityRESTService {
///CHANGEגג
    public static PriorityRESTObjects.UpdateResponse updateAccount (String request){
        HttpResponse res = CalloutService.getInstance().calloutService('Priority', 'PRIT_LOADDOC', request);
        PriorityRESTObjects.UpdateResponse result = (PriorityRESTObjects.UpdateResponse)JSON.deserialize(res.getBody(),PriorityRESTObjects.UpdateResponse.class);
        return result;
    }

    public static PriorityRESTObjects.UpdateResponse updateContact(String request){
        HttpResponse res = CalloutService.getInstance().calloutService('Priority', 'PRIT_LOADDOC', request);
        PriorityRESTObjects.UpdateResponse result = (PriorityRESTObjects.UpdateResponse)JSON.deserialize(res.getBody(),PriorityRESTObjects.UpdateResponse.class);
        return result;
    }

    public static PriorityRESTObjects.UpdateResponse updateOrder(String request){
        HttpResponse res = CalloutService.getInstance().calloutService('Priority', 'PRIT_LOADDOC', request);
        PriorityRESTObjects.UpdateResponse result = (PriorityRESTObjects.UpdateResponse)JSON.deserialize(res.getBody(),PriorityRESTObjects.UpdateResponse.class);
        return result;
    }

}