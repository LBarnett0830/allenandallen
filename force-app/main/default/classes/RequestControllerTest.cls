@isTest(SeeAllData=true)
public class RequestControllerTest {

    @isTest(SeeAllData=true) static void switchOrderedStatusForRequest_requestTypeIsNull_properExceptionIsThrown(){
        //ACT
        litify_pm__Request__c request = new litify_pm__Request__c();
        insert request;
        String message = null;

        //ACT
        try{
        	RequestController.switchOrderedStatusForRequest(request.Id);
        } catch(AuraHandledException e){
            message = e.getMessage();
        }

        //VERIFY
        System.assertEquals('You must specify the request type before ordering', message);
    }

    @isTest(SeeAllData=true) static void switchOrderedStatusForRequest_facilityIsNull_properExceptionIsThrown(){
        //SETUP
        litify_pm__Request__c request = new litify_pm__Request__c();
        request.litify_pm__Request_Type__c = 'Medical Bills';
        insert request;
        String message = null;

        //ACT
        try{
        	RequestController.switchOrderedStatusForRequest(request.Id);
        } catch(AuraHandledException e){
            message = e.getMessage();
        }

        //VERIFY
        System.assertEquals('You must select a Facility before you can order.', message);
    }

    @isTest(SeeAllData=true) static void switchOrderedStatusForRequest_orderedIsSwitched(){
        //SETUP
        Account clientAccount = new Account();
        clientAccount.litify_pm__First_Name__c = 'Client FN';
        clientAccount.litify_pm__Last_Name__c = 'Client LN';
        insert clientAccount;

        litify_pm__Matter__c matter = new litify_pm__Matter__c();
        matter.litify_pm__Client__c = clientAccount.Id;
        insert matter;

        Account providerAccount = new Account();
        providerAccount.litify_pm__First_Name__c = 'Provider FN';
        providerAccount.litify_pm__Last_Name__c = 'Provider LN';

        insert providerAccount;

        litify_pm__Role__c providerRole = new litify_pm__Role__c();
        providerRole.litify_pm__Role__c = 'Medical Provider';
        providerRole.litify_pm__Party__c = providerAccount.Id;
        providerRole.litify_pm__Matter__c = matter.Id;

        insert providerRole;

        litify_pm__Request__c request = new litify_pm__Request__c();
        request.litify_pm__Request_Type__c = 'Medical Bills';
        request.litify_pm__Facility__c = providerRole.Id;
        request.litify_pm__Matter__c = matter.Id;

        request.ordered__c = false;
        insert request;

        //ACT
        litify_pm__Request__c result = RequestController.switchOrderedStatusForRequest(request.Id);

        //VERIFY
        System.assert(result.ordered__c == true);
    }

    @isTest(SeeAllData=true) static void switchOrderedStatusForRequest_cancelledIsFalse(){
        //SETUP
        Account clientAccount = new Account();
        clientAccount.litify_pm__First_Name__c = 'Client FN';
        clientAccount.litify_pm__Last_Name__c = 'Client LN';
        insert clientAccount;

        litify_pm__Matter__c matter = new litify_pm__Matter__c();
        matter.litify_pm__Client__c = clientAccount.Id;
        insert matter;

        Account providerAccount = new Account();
        providerAccount.litify_pm__First_Name__c = 'Provider FN';
        providerAccount.litify_pm__Last_Name__c = 'Provider LN';

        insert providerAccount;

        litify_pm__Role__c providerRole = new litify_pm__Role__c();
        providerRole.litify_pm__Role__c = 'Medical Provider';
        providerRole.litify_pm__Party__c = providerAccount.Id;
        providerRole.litify_pm__Matter__c = matter.Id;

        insert providerRole;

        litify_pm__Request__c request = new litify_pm__Request__c();
        request.litify_pm__Request_Type__c = 'Medical Bills';
        request.litify_pm__Facility__c = providerRole.Id;
        request.litify_pm__Matter__c = matter.Id;
        request.cancelled__c = true;
        insert request;

        //ACT
        litify_pm__Request__c result = RequestController.switchOrderedStatusForRequest(request.Id);

        //VERIFY
        System.assert(result.cancelled__c == false);
    }

    @isTest(SeeAllData=true) static void cancelOrderingForRequest_cancelledIsSetToFalse_checkResult(){
        //SETUP
        litify_pm__Request__c request = new litify_pm__Request__c();
        request.cancelled__c = false;
        insert request;

        //ACT
        litify_pm__Request__c result = RequestController.cancelOrderingForRequest(request.Id);

        //VERIFY
        System.assert(result.cancelled__c == true);
    }

    @isTest(SeeAllData=true) static void receivedByLegalFirm_checkResult(){
        //SETUP
        litify_pm__Request__c request = new litify_pm__Request__c();
        insert request;


        //ACT
        litify_pm__Request__c result = RequestController.receivedByLegalFirm(request.Id);

        //VERIFY
        System.assertEquals(result.Lexitas_Received_By_Legal_Firm__c, true);
    }


}