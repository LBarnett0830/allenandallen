({
   checkValidations : function(cmp) {
        console.log('resolutionId '+resolutionId);       
        cmp.set("v.showSpinner",true);
        
        var resolutionId =cmp.get("v.recordId");
        
        var action = cmp.get('c.checkValidation');
        action.setParams({ 
            resolutionId : resolutionId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            cmp.set("v.showSpinner",false);
            
            if(state == "SUCCESS") {
                var mapMsg = response.getReturnValue();
                var msg='';
                var showError=false;
                
                if(mapMsg.isClosed !=undefined){
                    showError=true;
                    msg="Resolution is already Closed";
                    
                }else if(mapMsg.invalidStatus !=undefined){
                    showError=true;
                    msg="The Resolution is not Approved";
                    
                }else if(mapMsg.invalidClintDistAmt!=undefined){
                    showError=true;
                    msg="There is No Client Distribution Amount present for the Resolution";
                    
                }else  if(mapMsg.clientDstAPAlreadyCreated!=undefined){
                    showError=true;
                    msg="The Client Distribution Payable is already created";
                    
                }
                if(showError){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": msg,
                        "type": 'error',
                        "duration": '7000'
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                    
                }else{
                    cmp.set("v.showConfirm",true);
                    
                }
                
                
                
            }
            
            
        });
        $A.enqueueAction(action);
        
    },
    
    createPayable : function(cmp) {
        console.log('resolutionId '+resolutionId);       
        cmp.set("v.showSpinner",true);
        
        var resolutionId =cmp.get("v.recordId");
        var confirmTrustBalance = cmp.get("v.confirmTrustBalance");
        
        var action = cmp.get('c.createClientDistAP');
        action.setParams({ 
            resolutionId : resolutionId,
            confirmTrustBalance :confirmTrustBalance
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            cmp.set("v.showSpinner",false);
            
            if(state == "SUCCESS") {
                var mapMsg = response.getReturnValue();
                var msg='';
                var showError=false;
                
                if(mapMsg.isClosed !=undefined){
                    showError=true;
                    msg="Resolution is already Closed";
                    
                } else if(mapMsg.invalidStatus !=undefined){
                    showError=true;
                    msg="The Resolution is not Approved";
                    
                }else if(mapMsg.invalidClintDistAmt!=undefined){
                    showError=true;
                    msg="There is No Client Distribution Amount present for the Resolution";
                    
                }else  if(mapMsg.clientDstAPAlreadyCreated!=undefined){
                    showError=true;
                    msg="The Client Distribution Payable is already created";
                    
                }else  if(mapMsg.clientIsRequired!=undefined){
                    showError=true;
                    msg="Either 'Alternate Payee' or the 'Client' in the related Matter must be populated.";
                    
                }else  if(mapMsg.resDateIsNull!=undefined){
                    showError=true;
                    msg="Resolution Date is required.";
                    
                }else  if(mapMsg.error!=undefined){
                    showError=true;
                    msg="Error occured.";
                    
                }
                if(showError){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": msg,
                        "type": 'error',
                        "duration": '7000'
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                    
                }else if(mapMsg.insufficientTrustBalance!=undefined){
                    cmp.set('v.showConfirmTrustBalance',true);                   
                    
                }else  if(mapMsg.success!=undefined){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "success!",
                        "message": 'Successfully Created.',
                        "type": 'success',
                        "duration": '7000'
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                    
                    $A.get('e.force:refreshView').fire();
                }
                
                
                
            }
            
            
        });
        $A.enqueueAction(action);
        
    },
    
})