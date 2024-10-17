({
    doInit : function(component, event, helper) {
        var matterId= component.get("v.recordId");
        var filter = "litify_pm__Matter__c="+'\''+matterId+'\' AND Amount_after_Reductions__c>0  AND (Stage__c='+'\''+ "Approved"+'\' OR Stage__c='+'\''+ "N/A"+'\' )';
        component.set("v.expenseFilter",filter);
    },
    handleCancel : function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
    
    showConfirmation: function(component, event, helper) {
        var amount= component.get("v.amount");
        var expenseId = component.get("v.expenseId");
        var matterId =component.get("v.recordId");
        var showError=false;
        var errorMsg='';
        var objExpense= component.get("v.objExpense");
        if(amount!=undefined){
            if(amount.split('.').length>1){
                if(amount.split('.')[1].length>2){
                    showError =true;
                    errorMsg ="Please enter a valid Amount.";
                }
            }
        }
        if(expenseId==undefined || expenseId=='' || expenseId==null){
            showError =true;
            errorMsg ="Please select the Expense.";
        }else if(amount==undefined || amount=='' || amount==null ){
            showError =true;
            errorMsg ="Please enter the Refund Amount.";
        }else  if( amount<=0){
            showError =true;
            errorMsg ="Please enter a valid Refund Amount.";
        }else if(objExpense.Amount_after_Reductions__c < amount){
            showError =true;
            errorMsg ="Refund amount cannot exceed the expense amount.";
        }else if(objExpense.litify_pm__Matter__c!=matterId){
            errorMsg= "Selected Expense doesn't belong to the Matter";
            showError =true;
        }else if(objExpense.Amount_after_Reductions__c<0){
            errorMsg= "Amount must be positive in selected Expense";
            showError =true;
        }
        if(showError){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": errorMsg,
                "type": 'error'
            });
            toastEvent.fire();
        }else{
            component.set("v.showSaveConfirm",true);
        }
        
    },
    
    hideSaveConfirm: function(component, event, helper) {
        component.set("v.showSaveConfirm",false);
    },
    
    handleSave: function(component, event, helper) {
        helper.saveExpense(component, event);        
    },
    
    bindExpenseDetails: function(component, event, helper) {
       var expenseId= component.get('v.expenseId');
        if(expenseId!=null && expenseId!='' && expenseId!=undefined){
             helper.getExpenseDetails(component, event);   
        }
            
    },
    
})