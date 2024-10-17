({
    
    getExpenseWrapper : function(cmp) {
        cmp.set("v.showError",false);
        cmp.set("v.showSpinner",true);
        var recordId =cmp.get("v.recordId");
        var action = cmp.get('c.getExpenseWrapper');
        action.setParams({             
            expenseId : recordId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS") {
                var objWrapper = response.getReturnValue();
                console.log(objWrapper.balanceAmount);
                var hasError=false;
                cmp.set("v.objExpenseWrapper",objWrapper);                
                cmp.set("v.showSpinner",false);
                var showError=false;
                var message='';
                /*if(objWrapper.objExpense.Split_Parent__c !=undefined && objWrapper.objExpense.Split_Parent__c!=null){
                    message ="Expense record is not eligible for split.";
                    hasError =true;                    
                }else*/
                if(objWrapper.objExpense.litify_pm__Matter__c  =='' || objWrapper.objExpense.litify_pm__Matter__c==undefined){
                    message ="Matter is required.";
                    hasError =true;                    
                }else if(objWrapper.objExpense.Billing_Status__c!='Unbilled'){
                    message ="Expense record is not eligible for split.";
                    hasError =true;
                }else if(objWrapper.objExpense.Void__c){
                    message ="Expense record is not eligible for split.";
                    hasError =true;
                }
                if(objWrapper.amountLeft==0 && !hasError){
                    message ="The selected Expense is fully split.";
                    hasError =true;                    
                }else if(!hasError && (objWrapper.objExpense.Stage__c=='In-Process' || objWrapper.objExpense.Stage__c=='Pending Approval')){
                    message ="Expense is not Approved.";
                    hasError =true;                    
                }
                    
                if(objWrapper.objExpense.Origin__c!='ATO' && objWrapper.objExpense.Expense_Category__c =='Hard Cost' && !hasError ){
                    if(objWrapper.objPayableLine==undefined && objWrapper.objJELine==undefined ){
                        message ="Expense must be linked with either JE Line or AP Line";
                        hasError =true;                    
                    }else if(!hasError && objWrapper.objPayableLine!=undefined){
                        if(objWrapper.objPayableLine.AcctSeed__Account_Payable__r.AcctSeed__Status__c!='Posted'){
                            message ="The related Payable for the Expense is still not Posted";
                            hasError =true;
                        }
                    }if(!hasError && objWrapper.objJELine!=undefined){
                        if(objWrapper.objJELine.AcctSeed__Journal_Entry__r.AcctSeed__Status__c!='Posted'){
                            message ="The related Journal Entry for the Expense is still not Posted";
                            hasError =true;
                        }
                    }
                    
                    
                }    
                
                if(hasError){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": message,
                        "type": 'error'
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                }
                
                
            }
            
        });
        $A.enqueueAction(action);
    },
    
    saveExpense : function(cmp) {
        cmp.set("v.showError",false);
        cmp.set("v.showSpinner",true);
        
        var expenseId =cmp.get("v.recordId");
        var expenseWrapper = cmp.get("v.objExpenseWrapper");
        var action = cmp.get('c.saveExpenseDetails');
        action.setParams({ 
            expenseId : expenseId,            
            objExpenseWrapper : expenseWrapper
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS") {
                var msgMap= response.getReturnValue();
                cmp.set("v.showSpinner",false); 
                if(msgMap.success=='true'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Successfully saved.",
                        "type": 'success'
                    });
                    toastEvent.fire();
                    
                    
                    //refresh Expense record
                    $A.get("e.force:closeQuickAction").fire();
                    
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": resolutionId,
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
                    
                }else if(msgMap.invalidCustomSetting=='true'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Please update the 'Split Expenses GL Accounts ' custom setting.",
                        "type": 'error'
                    });
                    toastEvent.fire();
                    
                }else if(msgMap.invalidGLDefined=='true'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Invalid values defined in 'Split Expenses GL Accounts ' custom setting.",
                        "type": 'error'
                    });
                    toastEvent.fire();
                    
                } else if(msgMap.invalidProject=='true'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Project not defined for Matter '"+msgMap.invalidMatterWithProject +"' ",
                        "type": 'error'
                    });
                    toastEvent.fire();
                    
                }               
                
                
                
            }
            else{
                cmp.set("v.showSpinner",false);
            }
            
        });
        $A.enqueueAction(action);
    },
    
    
    
})