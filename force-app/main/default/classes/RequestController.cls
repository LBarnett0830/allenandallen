public class RequestController {
    @AuraEnabled
    public static litify_pm__Request__c switchOrderedStatusForRequest(String requestId){
        litify_pm__Request__c request =
            (litify_pm__Request__c)[SELECT Id,ordered__c,litify_pm__Request_Type__c,litify_pm__Facility__c FROM litify_pm__Request__c WHERE Id = :requestId];
        if(request.litify_pm__Request_Type__c==null){
            AuraHandledException e = new AuraHandledException('You must specify the request type before ordering');
            e.setMessage('You must specify the request type before ordering');
            throw e;
        }
        if(request.litify_pm__Facility__c==null){
            AuraHandledException e = new AuraHandledException('You must select a Facility before you can order.');
            e.setMessage('You must select a Facility before you can order.');
            throw e;
        }
        request.ordered__c = !request.ordered__c;
        request.cancelled__c = false;
        update request;
        return request;
    }

    @AuraEnabled
    public static litify_pm__Request__c cancelOrderingForRequest(String requestId){
        litify_pm__Request__c request =
            (litify_pm__Request__c)[SELECT Id,cancelled__c FROM litify_pm__Request__c WHERE Id = :requestId];
        request.cancelled__c = true;
        update request;
        return request;
    }

    @AuraEnabled
    public static litify_pm__Request__c receivedByLegalFirm(String requestId){
        litify_pm__Request__c request =
            (litify_pm__Request__c)[SELECT Id, Lexitas_Received_By_Legal_Firm__c FROM litify_pm__Request__c WHERE Id = :requestId];
		request.Lexitas_Received_By_Legal_Firm__c = true;
        update request;
        return request;
    }
}