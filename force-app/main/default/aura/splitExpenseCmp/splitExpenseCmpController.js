({
    init : function(component, event, helper) {
        if(document.referrer.indexOf(".lightning.force.com") > 0){
            component.set("v.recordUrlBase",'/one/one.app?#/sObject/');
            component.set("v.recordUrlBaseEnd",'/view');
        }
        else{
            component.set("v.isClassic",true);
            component.set("v.recordUrlBase",'/');
            component.set("v.recordUrlBaseEnd",'');
        }
        
        helper.getExpenseWrapper(component);
        var defaultFooter = document.getElementsByClassName('modal-footer');
        
    },
    
    
    handleAddInvoiceLine: function(component, event, helper){
        var objExpenseWrapper = component.get("v.objExpenseWrapper");
        var objInvoiceLine=  component.get("v.objExpenseWrapper.objInvoiceLine");
        var expenseTypeId = component.get("v.invExpenseTypeId");
        var expenseTypeName = component.get("v.invExpenseTypeName");
        var matterId = component.get("v.matterId");
        var matterName = component.get("v.matterName");
        var objWrapper =  component.get("v.objExpenseWrapper");
        var expenseAmount = objExpenseWrapper.objExpense.Amount_after_Reductions__c;
        var remainingAmount =objWrapper.remainingAmount==null||undefined || ''?0:objWrapper.remainingAmount;
        remainingAmount = remainingAmount==''?0:remainingAmount;
        var amountLeft =  component.get("v.objExpenseWrapper.amountLeft");
        var costsAlreadyTransferred = objExpenseWrapper.objExpense.Costs_Already_Transferred__c==null?0:objExpenseWrapper.objExpense.Costs_Already_Transferred__c ;
        
        if(matterId==undefined || matterId==''){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Please select the Matter.",
                "type": 'error'
            });
            toastEvent.fire();
        }else if(matterId==objWrapper.objExpense.litify_pm__Matter__c){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Primary Matter cannot be repeated",
                "type": 'error'
            });
            toastEvent.fire();
        }else  if(objInvoiceLine==null || objInvoiceLine.amount==undefined || objInvoiceLine.amount==0){
            var CRAmount =component.find('CRAmount');
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Please enter the Charge Amount.",
                "type": 'error'
            });
            toastEvent.fire();
        } else if(objInvoiceLine.amount<0){
            var CRAmount =component.find('CRAmount');
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Please enter a valid Trust Amount.",
                "type": 'error'
            });
            toastEvent.fire();
        }else{
            objInvoiceLine.MatterId = matterId;
            objInvoiceLine.matterName=matterName;
            var totalLineAmount = objExpenseWrapper.totalLineAmount==undefined?0:objExpenseWrapper.totalLineAmount;
            totalLineAmount = parseFloat(totalLineAmount) + parseFloat(objInvoiceLine.amount);  
            var duplicateMatter=false;
            
            for(var i=0;i<objExpenseWrapper.listInvoiceLines.length;i++){
                if(objExpenseWrapper.listInvoiceLines[i].MatterId==matterId){
                    duplicateMatter =true;
                    break;
                }
            }
            
            if(duplicateMatter){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Duplicate Matters are not allowed.",
                    "type": 'error'
                });
                toastEvent.fire();
            }else if(parseFloat(parseFloat(objInvoiceLine.amount).toFixed(2))> parseFloat(parseFloat(amountLeft).toFixed(2))){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Invoice lines Total exceeds Amount left to split.",
                    "type": 'error'
                });
                toastEvent.fire();
            }else{
                
                objWrapper.listInvoiceLines.push(JSON.parse(JSON.stringify(objInvoiceLine)));
                component.set("v.objExpenseWrapper.listInvoiceLines",objWrapper.listInvoiceLines);
                
                component.set("v.objExpenseWrapper.totalLineAmount",totalLineAmount);
                
                objExpenseWrapper.objExpense.Costs_Already_Transferred__c = costsAlreadyTransferred+ parseFloat(objExpenseWrapper.objInvoiceLine.amount);
                component.set("v.objExpenseWrapper",objExpenseWrapper);
                
                var amountLeft = parseFloat(amountLeft) - parseFloat(objInvoiceLine.amount);
                component.set("v.objExpenseWrapper.amountLeft",amountLeft);
                
                component.set("v.invExpenseTypeId",'');
                component.set("v.matterId",'');
                objInvoiceLine.amount=null;                
                objInvoiceLine.MatterId = '';
                objInvoiceLine.matterName='';
                objInvoiceLine.comments= '';
                var expenseTypeId= component.get("v.expenseTypeId");
                var expenseTypeName = component.get("v.expenseTypeName");
                
                if(expenseTypeId!=undefined){
                    component.set("v.invExpenseTypeId",expenseTypeId);
                    component.set("v.invExpenseTypeName",expenseTypeName);
                    objInvoiceLine.expenseTypeId =expenseTypeId;
                    objInvoiceLine.expenseTypeName =expenseTypeName;
                }
                component.set("v.objExpenseWrapper.objInvoiceLine",objInvoiceLine);
                
                var totalLines =  component.get("v.objExpenseWrapper.totalLines")==undefined?0:component.get("v.objExpenseWrapper.totalLines");
                component.set("v.objExpenseWrapper.totalLines",parseFloat(totalLines)+1);
                /* if(amountLeft==0){
                    component.set("v.showSubmit",true);
                }else{
                    component.set("v.showSubmit",false);
                }*/
                component.set("v.showSubmit",true);
                
            }
            
        }
        
    },
    
    handleDeleteInvoiceLine: function(component, event, helper){
        var rowIndex =event.getSource().get("v.value");
        var objExpenseWrapper=  component.get("v.objExpenseWrapper");
        var listInvoiceLines = objExpenseWrapper.listInvoiceLines;
        var totalAmount =component.get("v.objExpenseWrapper.totalAmount");
        var invLineAmount = objExpenseWrapper.listInvoiceLines[rowIndex].amount;
         var expenseAmount = objExpenseWrapper.objExpense.Amount_after_Reductions__c;
        var amountLeft =  component.get("v.objExpenseWrapper.amountLeft");
        var costsAlreadyTransferred = objExpenseWrapper.objExpense.Costs_Already_Transferred__c==null?0:objExpenseWrapper.objExpense.Costs_Already_Transferred__c ;
        
        listInvoiceLines.splice(rowIndex,1);  
        var totalLines =  component.get("v.objExpenseWrapper.totalLines")==undefined?0:component.get("v.objExpenseWrapper.totalLines");
        component.set("v.objExpenseWrapper.totalLines",parseFloat(totalLines)-1);
        // component.set("v.objExpenseWrapper.amountLeft", parseFloat(amountLeft)+parseFloat(expenseAmount));
        
        objExpenseWrapper.objExpense.Costs_Already_Transferred__c = costsAlreadyTransferred- parseFloat(invLineAmount);
        var amountLeft = parseFloat(expenseAmount) - parseFloat(objExpenseWrapper.objExpense.Costs_Already_Transferred__c);
        component.set("v.objExpenseWrapper.amountLeft",amountLeft);
        component.set("v.objExpenseWrapper",objExpenseWrapper);
        
        
        var totalLineAmount = objExpenseWrapper.totalLineAmount==undefined?0:objExpenseWrapper.totalLineAmount;
        totalLineAmount = parseFloat(totalLineAmount) - parseFloat(invLineAmount); 
        component.set("v.objExpenseWrapper.totalLineAmount",totalLineAmount);
        component.set("v.objExpenseWrapper.listInvoiceLines",listInvoiceLines);
        
        
        
        amountLeft =component.get("v.objExpenseWrapper.amountLeft");
        /* if(amountLeft==0){
            component.set("v.showSubmit",true);
        }else{
            component.set("v.showSubmit",false);
        }*/
        if(objExpenseWrapper.listInvoiceLines.length>0){
            component.set("v.showSubmit",true);
        }else{
             component.set("v.showSubmit",false);
        }
        
    },    
    
    
    handleWriteOnKeyPress : function(component, event, helper) {
        console.log(event.code);
        if(event.code=='Minus' || event.code=='NumpadSubtract'){
            event.preventDefault();
        }
        else{
            var objPrebilledExpList = component.get("v.objExpenseWrapper.billedAndPreBilledExpenses");
            if(objPrebilledExpList.length>0){
                component.set("v.showSave",true);
            }
            
        }
    },
    
    handleAmountOnChange: function(component, event, helper){
        var objExpenseWrapper= component.get("v.objExpenseWrapper");
        var expenseAmount = objExpenseWrapper.objExpense.Amount_after_Reductions__c;
        var totalLineAmount = objExpenseWrapper.totalLineAmount==undefined?0:objExpenseWrapper.totalLineAmount;
        var remainingAmount= component.get("v.objExpenseWrapper.remainingAmount");
        var amountLeft = component.get("v.objExpenseWrapper.amountLeft");
        
        if(remainingAmount!=undefined && remainingAmount!=null){
            if(remainingAmount=='' ){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Invalid amount.",
                    "type": 'error'
                });
                toastEvent.fire();
            } else if(remainingAmount>expenseAmount ){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Remaining amount cannot be greater than expense amount.",
                    "type": 'error'
                });
                toastEvent.fire();
            }else{
                
                amountLeft = parseFloat(expenseAmount) - parseFloat(remainingAmount) -parseFloat(totalLineAmount);
                if(parseFloat(remainingAmount) + parseFloat(amountLeft==undefined?0:amountLeft)+ parseFloat(totalLineAmount) >objExpenseWrapper.objExpense.Amount_after_Reductions__c ){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Invalid amount.",
                        "type": 'error'
                    });
                    toastEvent.fire();
                } 
                else{
                    component.set("v.objExpenseWrapper.amountLeft",amountLeft);
                    
                    if(amountLeft==0){
                        component.set("v.showSubmit",true);
                    }else{
                        component.set("v.showSubmit",false);
                    }
                }
                
                
            }
        }
        
    },
    
    handleCancel : function(component, event, helper) {
        var isClassic=  component.get("v.isClassic");
        var resolutionId =component.get("v.recordId");
        if(isClassic){
            window.location='/'+resolutionId;
        }
        else{
            $A.get("e.force:closeQuickAction").fire();
        }
        
        
        
    },
    handleSave : function(component, event, helper){
        component.set("v.showConfirm",false);
        helper.saveExpense(component);
    },
    hideConfirmation : function(component, event, helper){
        component.set("v.showConfirm",false);
        component.set("v.showConfirmToSaveAndPrint",false);
    },
    showConfirmation : function(component, event, helper){
        component.set("v.showConfirm",true);        
        
    },
    
    
})