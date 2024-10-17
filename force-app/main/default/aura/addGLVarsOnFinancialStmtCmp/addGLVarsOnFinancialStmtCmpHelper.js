({
    getStmtWrapper : function(cmp) {
        cmp.set("v.showError",false);
        cmp.set("v.showSpinner",true);
        
        var stmtId =cmp.get("v.recordId");         
        
        var action = cmp.get('c.getWrapperDetails');
        action.setParams({ 
            stmtId : stmtId 
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            cmp.set("v.showSpinner",false);
            if(state == "SUCCESS") {
                var objWrapper= response.getReturnValue();
                cmp.set('v.objWrapper',objWrapper);                
                
                
            }
            else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Error occured.",
                    "type": 'error'
                });
                toastEvent.fire();
            }
            
        });
        $A.enqueueAction(action);
    },
    
    
    updateGLVars : function(cmp) {
        cmp.set("v.showError",false);
        cmp.set("v.showSpinner",true);
        
        var stmtId =cmp.get("v.recordId");
        var objWrapper =cmp.get("v.objWrapper");
        
        
        var action = cmp.get('c.updateGLVars');
        action.setParams({ 
            objWrapper : objWrapper 
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            cmp.set("v.showSpinner",false);
            if(state == "SUCCESS") {
                var msgMap= response.getReturnValue();
                cmp.set("v.showSpinner",false); 
                if(msgMap.success=='true'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Successfully processed.",
                        "type": 'success'
                    });
                    toastEvent.fire();
                    
                    
                    //refresh Expense record
                    // $A.get("e.force:closeQuickAction").fire();
                    $A.get('e.force:refreshView').fire();
                    
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": stmtId,
                        "slideDevName": "detail"
                        
                    });
                    navEvt.fire(); 
                }
                else if(msgMap.error=='true'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Error occured.",
                        "type": 'error'
                    });
                    toastEvent.fire();
                    
                }               
                
                
                
            }
            else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Error occured.",
                    "type": 'error'
                });
                toastEvent.fire();
            }
            
        });
        $A.enqueueAction(action);
    },
    
    
})