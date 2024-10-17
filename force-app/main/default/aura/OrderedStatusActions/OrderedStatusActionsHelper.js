({
    cancelOrder: function (component) {
        this.executeUpdateRequestAndHandleResponse(component, 'cancelOrderingForRequest');
    },
    orderRequest: function (component) {
        this.executeUpdateRequestAndHandleResponse(component, 'switchOrderedStatusForRequest');
    },
    setReceivedByLegalFirm: function (component) {
        this.executeUpdateRequestAndHandleResponse(component, 'receivedByLegalFirm')
    },
    executeApexRequest: function (component, apexAction, params) {
        var p = new Promise($A.getCallback(function (resolve, reject) {
            var action = component.get("c." + apexAction + "");
            action.setParams(params);
            action.setCallback(this, function (callbackResult) {
                if (callbackResult.getState() == 'SUCCESS') {
                    resolve(callbackResult.getReturnValue());
                }
                if (callbackResult.getState() == 'ERROR') {
                    reject( callbackResult.getError() );
                }
            });
            $A.enqueueAction( action );
        }));
        return p;
    },
    executeUpdateRequestAndHandleResponse:function(component,apexFunctionName){
        var requestId = component.get("v.recordId");
        var listAction = component.get("v.listAction");
        var matterId = component.get("v.request.litify_pm__Matter__c");
        this.executeApexRequest(component, apexFunctionName, {requestId:requestId})
            .then(function(response){
                if(listAction == "true"){
                    location.reload();
                }

                var resultToast = $A.get("e.force:showToast");
                resultToast.setParams({
                    "title": "Success!",
                    "message": "Record Saved Successfully"
                });
                resultToast.fire();

                var homeEvent = $A.get("e.force:navigateToSObject");
                homeEvent.setParams({
                    "recordId": matterId
                });
                homeEvent.fire();
            }, function(response){
                let toastParams = {
                    title: "Error",
                    message: response[0].message, // Default error message
                    type: "error"
                };
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams(toastParams);
                toastEvent.fire();
            }).catch(function(error){
            console.log("Error: " + error);
        });
    }
})