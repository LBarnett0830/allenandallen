({
    init : function(component, event, helper) {
        if(document.referrer.indexOf(".lightning.force.com") > 0){
            component.set("v.recordUrlBase",'/one/one.app?#/sObject/');
            component.set("v.recordUrlBaseEnd",'/view');
        }
        else{
            component.set("v.recordUrlBase",'/');
            component.set("v.recordUrlBaseEnd",'');
        }
        console.log('called');
        helper.getResolutionWrapper(component);
        var defaultFooter = document.getElementsByClassName('modal-footer');
        
    },    
    
    handleAvailableDamageSelect : function(component, event, helper) { 
        component.set("v.showSpinner",true);
        
        //helper.updateExpenseBillingStatus(component,'Unbilled',event);
        var objAvailableDamageList= component.get("v.resolutionWrapper.availableDamages");
        var expenseId =event.getSource().get('v.value');
        var writeOffAmount = component.get("v.resolutionWrapper.writeOffAmount");
        
        var objExpense;
        var invalidDamage=false;
        for(var i=0;i<objAvailableDamageList.length;i++){
            if(objAvailableDamageList[i].Id==expenseId){
                objExpense = objAvailableDamageList[i];
                if(objExpense.Balance_Due__c<0){
                    invalidDamage=true;
                }
                else{
                    objAvailableDamageList.splice(i,1);
                    component.set("v.resolutionWrapper.availableDamages",objAvailableDamageList);
                }
                
                break;
            }
        }
        if(invalidDamage){
            event.getSource().set('v.checked',false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Amount Due cannot be negative in selected Damage.",
                "type": 'error'
            });
            toastEvent.fire();
            component.set("v.showSpinner",false);
            //component.set("v.resolutionWrapper.selectedDamages",component.get("v.resolutionWrapper.emptyDamages"));
        }
        else{
            var objSelectedList = component.get("v.resolutionWrapper.selectedDamages");
            objSelectedList.push(objExpense);
            
            objSelectedList.sort(function(a,b){
                return new Date(b.Due_Date__c) - new Date(a.Due_Date__c);
            });
            
            component.set("v.resolutionWrapper.selectedDamages",objSelectedList);
            
            var totalDamagesAmount = component.get("v.resolutionWrapper.totalDamagesAmount");
            totalDamagesAmount = parseFloat(totalDamagesAmount) + objExpense.Balance_Due__c;
            if(totalDamagesAmount!=null){
                component.set("v.resolutionWrapper.totalDamagesAmount",parseFloat(totalDamagesAmount).toFixed(2));
                
            }
            
            component.set("v.resolutionWrapper.balanceAmount",parseFloat(totalDamagesAmount-writeOffAmount).toFixed(2));
            component.set("v.showSave",true);
            component.set("v.showSpinner",false);
            
        }
        
        
    },
    
    handleAllAvailableDamageSelect : function(component, event, helper) {  
        component.set("v.showSpinner",true);
        
        var objAvailableDamageList= component.get("v.resolutionWrapper.availableDamages");     
        var emptyUnbilledList = component.get("v.resolutionWrapper.availableDamages"); 
        var invalidDamage=false;
        if(objAvailableDamageList.length>0){
            var writeOffAmount = component.get("v.resolutionWrapper.writeOffAmount");        
            let objSelectedList = component.get("v.resolutionWrapper.selectedDamages");
            var selectedUnbilledTotalAmount=0;
            var noOfSelectedItems = objAvailableDamageList.length;
            for(var i=0;i<objAvailableDamageList.length;i++){
                var expense = objAvailableDamageList[i];                
                if(expense.Balance_Due__c<0){
                    invalidDamage=true;
                    break;
                }
            }
            
            if(invalidDamage){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Amount Due cannot be negative in selected Damage.",
                    "type": 'error'
                });
                toastEvent.fire();
                component.set("v.showSpinner",false);
                //component.set("v.resolutionWrapper.selectedDamages",component.get("v.resolutionWrapper.emptyDamages"));
            }else{
                component.set("v.showSave",true);
                for(var i=0;i<objAvailableDamageList.length;i++){
                    var expense = objAvailableDamageList[i];
                    console.log('Escrow Value: ', expense.Escrow__c);
                    selectedUnbilledTotalAmount = selectedUnbilledTotalAmount+ parseFloat(expense.Balance_Due__c);
                    if(expense.Escrow__c == true){
                            selectedUnbilledTotalAmount = 0.0;
                        }
                    objSelectedList.push(JSON.parse(JSON.stringify(expense)));
                    
                }
                objSelectedList.sort(function(a,b){
                    return new Date(b.Due_Date__c) - new Date(a.Due_Date__c);
                });
                
                component.set("v.resolutionWrapper.availableDamages",component.get("v.resolutionWrapper.emptyDamages"));        
                component.set("v.resolutionWrapper.selectedDamages",objSelectedList);
                
                var totalDamagesAmount = component.get("v.resolutionWrapper.totalDamagesAmount");
                totalDamagesAmount = parseFloat(totalDamagesAmount) + selectedUnbilledTotalAmount;
                if(totalDamagesAmount!=null){
                    console.log(parseFloat(totalDamagesAmount).toFixed(2));            
                    component.set("v.resolutionWrapper.totalDamagesAmount",parseFloat(totalDamagesAmount).toFixed(2));
                    
                }
                
                component.set("v.resolutionWrapper.balanceAmount",parseFloat(totalDamagesAmount-writeOffAmount).toFixed(2));
                component.set("v.showSpinner",false);            
                
            }
            
        }
        var chkBox = document.getElementById('selectUnbilledAll');
        chkBox.checked = false;  
        component.set("v.showSpinner",false);
        var objSelectedListFinal = component.get("v.resolutionWrapper.selectedDamages");
        
        
    },    
    
    handleSelectedDamageSelect : function(component, event, helper) {
        component.set("v.showSpinner",true);
        component.set("v.showSave",true);
        var objAvailableDamageList= component.get("v.resolutionWrapper.availableDamages");   
        var objSelectedList = component.get("v.resolutionWrapper.selectedDamages");
        var expenseId =event.getSource().get('v.value');
        var writeOffAmount = component.get("v.resolutionWrapper.writeOffAmount");
        
        var objExpense;
        for(var i=0;i<objSelectedList.length;i++){
            if(objSelectedList[i].Id==expenseId){
                objExpense = objSelectedList[i];
                //console.log('Escrow Value: ', objExpense.Escrow__c);
                objSelectedList.splice(i,1);
                component.set("v.resolutionWrapper.selectedDamages",objSelectedList);
                break;
            }
        }
        
        objAvailableDamageList.push(objExpense);
        objAvailableDamageList.sort(function(a,b){
            return new Date(b.Due_Date__c) - new Date(a.Due_Date__c);
        });
        
        component.set("v.resolutionWrapper.availableDamages",objAvailableDamageList);
        var totalDamagesAmount = component.get("v.resolutionWrapper.totalDamagesAmount");
        if(objExpense.Escrow__c == false){
                totalDamagesAmount = parseFloat(totalDamagesAmount) - objExpense.Balance_Due__c;
            }

        
        component.set("v.resolutionWrapper.totalDamagesAmount", parseFloat(totalDamagesAmount).toFixed(2));
        var balance = parseFloat(totalDamagesAmount)-parseFloat(writeOffAmount);
        component.set("v.resolutionWrapper.balanceAmount",balance.toFixed(2));        
        component.set("v.showSpinner",false);        
        var chkBox = document.getElementById('selectUnbilledAll');
        chkBox.checked = false;
    },
    
    
    handleAvailableLienSelect : function(component, event, helper) { 
        component.set("v.showSpinner",true);
        var targetElement = event.target;
        //helper.updateExpenseBillingStatus(component,'Unbilled',event);
        var objUnbilledWriteOffList= component.get("v.resolutionWrapper.availableLienes");
        var expenseId =event.getSource().get('v.value');
        var writeOffAmount = component.get("v.resolutionWrapper.writeOffAmount");
        
        var objWriteOff;
        var invalidLien=false;
        
        for(var i=0;i<objUnbilledWriteOffList.length;i++){
            if(objUnbilledWriteOffList[i].Id==expenseId){
                objWriteOff = objUnbilledWriteOffList[i];
                //console.log('Escrow Value: ', objWriteOff.Escrow__c);
                if(objWriteOff.litify_pm__lit_Amount_Due__c<0){
                    invalidLien =true;
                    break;
                }else{
                    objUnbilledWriteOffList.splice(i,1);
                    component.set("v.resolutionWrapper.availableLienes",objUnbilledWriteOffList);
                    break;
                }
            }
        }
        if(invalidLien){
            
            event.getSource().set('v.checked',false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Amount Due cannot be negative in selected Lien.",
                "type": 'error'
            });
            toastEvent.fire();
            component.set("v.showSpinner",false);
            // component.set("v.resolutionWrapper.selectedLienes",component.get("v.resolutionWrapper.emptyLienes"));
        }else{
            component.set("v.showSave",true);
            
            writeOffAmount = parseFloat(writeOffAmount) + parseFloat(objWriteOff.litify_pm__lit_Amount_Due__c);
            component.set("v.resolutionWrapper.writeOffAmount",writeOffAmount.toFixed(2));
            
            var objPrebilledWriteOffList = component.get("v.resolutionWrapper.selectedLienes");
            objPrebilledWriteOffList.push(objWriteOff);
            
            objPrebilledWriteOffList.sort(function(a,b){
                return new Date(b.Date_Issued__c) - new Date(a.Date_Issued__c);
            });
            
            component.set("v.resolutionWrapper.selectedLienes",objPrebilledWriteOffList);
            
            var totalLienesAmount = component.get("v.resolutionWrapper.totalLienesAmount");
            if(objWriteOff.Escrow__c == false){
                totalLienesAmount = totalLienesAmount + parseFloat(objWriteOff.litify_pm__lit_Amount_Due__c);
            }
            component.set("v.resolutionWrapper.totalLienesAmount",totalLienesAmount);
            component.set("v.resolutionWrapper.balanceAmount",parseFloat(totalLienesAmount-writeOffAmount).toFixed(2));
            component.set("v.showSpinner",false);
        }
        
        
        
    },
    
    handleAllAvailableLienSelect : function(component, event, helper) {  
        component.set("v.showSpinner",true);
        
        var objAvailableList= component.get("v.resolutionWrapper.availableLienes");     
        var emptyUnbilledList = component.get("v.resolutionWrapper.availableLienes");
        if(objAvailableList.length>0){
            var invalidLien=false;
            
            var writeOffAmount = component.get("v.resolutionWrapper.writeOffAmount");        
            var objSelectedList = component.get("v.resolutionWrapper.selectedLienes");
            var selectedUnbilledTotalAmount=0;
            var noOfSelectedItems = objAvailableList.length;
            
            for(var i=0;i<objAvailableList.length;i++){
                var expense = objAvailableList[i];
                if(expense.litify_pm__lit_Amount_Due__c<0){
                    invalidLien =true;
                    break;
                }
            }           
            
            if(invalidLien){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Amount Due cannot be negative in selected Lien.",
                    "type": 'error'
                });
                toastEvent.fire();
                component.set("v.showSpinner",false);
                // component.set("v.resolutionWrapper.selectedLienes",component.get("v.resolutionWrapper.emptyLienes"));
            }else{
                component.set("v.showSave",true);
                for(var i=0;i<objAvailableList.length;i++){
                    var expense = objAvailableList[i];
                    console.log('Is Escrow', expense.Escrow__c);
                    selectedUnbilledTotalAmount = selectedUnbilledTotalAmount+ parseFloat(expense.litify_pm__lit_Amount_Due__c);
                    objSelectedList.push(expense);
                    
                }
                objSelectedList.sort(function(a,b){
                    return new Date(b.Date_Issued__c) - new Date(a.Date_Issued__c);
                });
                
                component.set("v.resolutionWrapper.availableLienes",component.get("v.resolutionWrapper.emptyLienes"));        
                component.set("v.resolutionWrapper.selectedLienes",objSelectedList);
                
                var totalLienesAmount = component.get("v.resolutionWrapper.totalLienesAmount");
                totalLienesAmount = totalLienesAmount+selectedUnbilledTotalAmount;
                component.set("v.resolutionWrapper.totalLienesAmount",totalLienesAmount);
                writeOffAmount = parseFloat(writeOffAmount) + selectedUnbilledTotalAmount;
                component.set("v.resolutionWrapper.writeOffAmount",parseFloat(writeOffAmount).toFixed(2));
                component.set("v.resolutionWrapper.balanceAmount",parseFloat(totalLienesAmount-writeOffAmount).toFixed(2));
                component.set("v.showSpinner",false);
                
            }
            
        }
        
        component.set("v.showSpinner",false);
        var chkBox = document.getElementById('selectUnbilledWriteOffAll');
        chkBox.checked = false;
        
        
    },   
    
    handleSelectedLienSelect : function(component, event, helper) {
        component.set("v.showSpinner",true);
        component.set("v.showSave",true);
        var objAvailableList= component.get("v.resolutionWrapper.availableLienes");   
        var objSelectedList = component.get("v.resolutionWrapper.selectedLienes");
        var expenseId =event.getSource().get('v.value');
        var writeOffAmount = component.get("v.resolutionWrapper.writeOffAmount");
        
        var objWriteOff;
        for(var i=0;i<objSelectedList.length;i++){
            if(objSelectedList[i].Id==expenseId){
                objWriteOff = objSelectedList[i];
                console.log('Escrow Value ', objWriteOff.Escrow__c);
                objSelectedList.splice(i,1);
                component.set("v.resolutionWrapper.selectedLienes",objSelectedList);
                break;
            }
        }
        
        objAvailableList.push(objWriteOff);
        objAvailableList.sort(function(a,b){
            return new Date(b.Date_Issued__c) - new Date(a.Date_Issued__c);
        });
        
        component.set("v.resolutionWrapper.availableLienes",objAvailableList);
        writeOffAmount = parseFloat(writeOffAmount) - objWriteOff.litify_pm__lit_Amount_Due__c;
        
        var totalLienesAmount =  component.get("v.resolutionWrapper.totalLienesAmount");
        if(objWriteOff.Escrow__c == false){
                totalLienesAmount = totalLienesAmount - parseFloat(objWriteOff.litify_pm__lit_Amount_Due__c);
        }
        component.set("v.resolutionWrapper.totalLienesAmount",totalLienesAmount);
        component.set("v.resolutionWrapper.writeOffAmount", parseFloat(writeOffAmount).toFixed(2));
        var balance = parseFloat(totalLienesAmount)-parseFloat(writeOffAmount);
        component.set("v.resolutionWrapper.balanceAmount",balance.toFixed(2));
        
        component.set("v.showSpinner",false);        
        var chkBox = document.getElementById('selectUnbilledWriteOffAll');
        chkBox.checked = false;
        
    },
    
    
    handleWriteOnKeyPress : function(component, event, helper) {
        console.log(event.code);
        if(event.code=='Minus' || event.code=='NumpadSubtract'){
            event.preventDefault();
        }
        else{
            var objSelectedList = component.get("v.resolutionWrapper.preBilledExpenses");
            if(objSelectedList.length>0){
                component.set("v.showSave",true);
            }
            
        }
    },
    
    handleWriteOffChange : function(component, event, helper) {
        
        if(component.get("v.resolutionWrapper")!=null && event.which != 45){
            var writeOffAmount = component.get("v.resolutionWrapper.writeOffAmount");
            var totalPreBillAmount = component.get("v.resolutionWrapper.totalPreBilledAmount");
            console.log(writeOffAmount);
            if(writeOffAmount!=null && writeOffAmount<0){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Invalid Amount.",
                    "type": 'error'
                });
                toastEvent.fire();
            }else if(parseFloat(writeOffAmount)> parseFloat(totalPreBillAmount)){
                var status= component.get("v.resolutionWrapper.objResolution.Statement_Status__c");
                if(status!='Final'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Amount written-off cannot be greater than total prebilled amount",
                        "type": 'error'
                    });
                    toastEvent.fire();
                }
                
            }else{
                if(component.get("v.resolutionWrapper.objResolution.Statement_Status__c")!='Final'){
                    var balance = parseFloat(totalPreBillAmount)-parseFloat(writeOffAmount);
                    component.set("v.resolutionWrapper.balanceAmount",balance.toFixed(2));
                }
                
                
            }
            
            
        }
        else{
            event.preventDefault();
        }
    },
    
    handleCancel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        
    },
    handleSave : function(component, event, helper){
        component.set("v.showConfirm",false);
        helper.saveResolution(component);
    },
    hideConfirmation : function(component, event, helper){
        component.set("v.showConfirm",false);
        component.set("v.showConfirmToSaveAndPrint",false);
    },
    showConfirmation : function(component, event, helper){
        var writeOffAmount = component.get("v.resolutionWrapper.writeOffAmount");
        var totalPreBillAmount = component.get("v.resolutionWrapper.totalPreBilledAmount");
        if(parseFloat(writeOffAmount)> parseFloat(totalPreBillAmount)){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Amount written-off cannot be greater than total prebilled amount",
                "type": 'error'
            });
            toastEvent.fire();
        }
        else{
            component.set("v.showConfirm",true);
        }
        
        
    },
    handlePrint : function(component, event, helper){
        var writeOffAmount = component.get("v.resolutionWrapper.writeOffAmount");
        var totalPreBillAmount = component.get("v.resolutionWrapper.totalPreBilledAmount");
        if(parseFloat(writeOffAmount)> parseFloat(totalPreBillAmount)){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Amount written-off cannot be greater than total prebilled amount",
                "type": 'error'
            });
            toastEvent.fire();
        }
        else if(component.get("v.showSave")==true){
            component.set("v.showConfirmToSaveAndPrint",true);            
        }else{            
            helper.saveAsPDF(component);            
            
        }
        
    },
    handleSaveAndPrint : function(component, event, helper){
        component.set("v.showConfirmToSaveAndPrint",false);
        helper.saveAndPrintResolution(component);
    },
    
})