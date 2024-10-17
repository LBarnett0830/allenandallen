({
	generateStatement : function(cmp) {
        cmp.set("v.showError",false);
        cmp.set("v.showSpinner",true);
        var recordId =cmp.get("v.recordId");
        var statementType = cmp.get("v.statementType");
        var action = cmp.get('c.generateStatement');
        action.setParams({             
            resolutionId : recordId,
            statementType :statementType
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS") {
                console.log( response.getReturnValue());
                var msgMap = response.getReturnValue();                
                
                if(msgMap.invalidStage!=undefined){
                    $A.get("e.force:closeQuickAction").fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "The selected Resolutionis not in a valid stage.",
                        "type": 'error'
                    });
                    toastEvent.fire();
                    
                }
                else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success",
                        "message": "Statement generated successfully.",
                        "type": 'success'
                    });
                    toastEvent.fire();
                    
                    $A.get("e.force:closeQuickAction").fire();
                }
                cmp.set("v.showSpinner",false);
            }
            
        });
        $A.enqueueAction(action);
    },
    
})