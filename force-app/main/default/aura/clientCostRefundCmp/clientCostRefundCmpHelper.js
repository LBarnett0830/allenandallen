({
    saveExpense : function(cmp,event) {
        cmp.set("v.showError",false);
        cmp.set("v.showSpinner",true);
        
        var matterId =cmp.get("v.recordId");
        var amount= cmp.get("v.amount");
        var expenseId = cmp.get("v.expenseId"); 
        var comment = cmp.get("v.comment"); 
        var action = cmp.get('c.saveRefund');
        action.setParams({ 
            matterId:matterId,
            amount:amount,
            expenseId:expenseId,
            comment : comment
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS") {
                
                var msgMap = response.getReturnValue();
                if(msgMap.invalidGL){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Invalid GL Accounts related to the 'ATO Void GL Accounts' custom setting",
                        "type": 'error'
                    });
                    toastEvent.fire();
                }else if(msgMap.invalidProject){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Project is required in the Matter.",
                        "type": 'error'
                    });
                    toastEvent.fire();
                }else if(msgMap.invalidProjectTask){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Default Task is required in the related Project.",
                        "type": 'error'
                    });
                    toastEvent.fire();
                }else if(msgMap.invalidExpenseType){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "'Refund' Expense Type is missing",
                        "type": 'error'
                    });
                    toastEvent.fire();
                }else if(msgMap.invalidClient){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Client is required in Matter",
                        "type": 'error'
                    });
                    toastEvent.fire();
                }else if(msgMap.invalidClientType){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Invalid Accounting Type for Client",
                        "type": 'error'
                    });
                    toastEvent.fire();
                } else if(msgMap.errorOccured){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Error occured.",
                        "type": 'error'
                    });
                    toastEvent.fire();
                    
                }else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Successfully Saved",
                        "type": 'success'
                    });
                    toastEvent.fire();
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                }
                
                
                
            }
            cmp.set("v.showSpinner",false);
            cmp.set("v.showSaveConfirm",false);
            
        });
        $A.enqueueAction(action);
        
    },
    
    getExpenseDetails : function(component, event) {
        component.set("v.showSpinner",true);
        component.set("v.showConfirm",false);
        var matterId =component.get("v.recordId");
        
        var action = component.get('c.getExpenseDetails');
        
        action.setParams({
            "expenseId" : component.get('v.expenseId') 
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS") {                
                var objExpense = response.getReturnValue(); 
                if(objExpense.litify_pm__Matter__c!=matterId){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Selected Expense doesn't belong to the Matter",
                        "type": 'error'
                    });
                    toastEvent.fire();
                }
                component.set("v.objExpense",objExpense);
                
            }
            component.set("v.showSpinner",false);
        });
        $A.enqueueAction(action);
        
        
    },
    
    
})