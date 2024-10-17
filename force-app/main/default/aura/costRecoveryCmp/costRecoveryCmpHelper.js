({
    
    getResolutionWrapper : function(cmp) {
        cmp.set("v.showError",false);
        cmp.set("v.showSpinner",true);
        var recordId =cmp.get("v.recordId");
        var action = cmp.get('c.getAllRecords');
        action.setParams({             
            resolutionId : recordId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS") {
                console.log( response.getReturnValue());
                var objWrapper = response.getReturnValue();
                console.log('balance amount=');
                console.log(objWrapper.balanceAmount);
                
                cmp.set("v.resolutionWrapper",response.getReturnValue());
                cmp.set("v.unBilledexpenses",objWrapper.unbilledExpenses);
                cmp.set("v.preBilledexpenses",objWrapper.preBilledExpenses);
                
                cmp.set("v.showSpinner",false);
                
                if(objWrapper.objResolution.Status__c!='In-Process' ){
                     cmp.set("v.disableInput",true);
                }
                
                if(cmp.get("v.resolutionWrapper.objResolution.litify_pm__Matter__r.Name")==null){
                    $A.get("e.force:closeQuickAction").fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "The selected Resolution does not have a Matter associated.",
                        "type": 'error'
                    });
                    toastEvent.fire();
                    
                }else  if(cmp.get("v.resolutionWrapper.noOfUnapproved")>0){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Warning!",
                        "message": "Unapproved Expenses present for Matter.",
                        "type": 'warning'
                    });
                    toastEvent.fire();
                    
                }
            }
            
        });
        $A.enqueueAction(action);
    },
    
    
    updateExpenseBillingStatus : function(cmp,billingStatus,event) {
        cmp.set("v.showError",false);
        cmp.set("v.showSpinner",true);
        console.log(event.getSource().get('v.value'));
        var expenseId =event.getSource().get('v.value');
        var resolutionId =cmp.get("v.recordId");
        
        var action = cmp.get('c.updateExpenseBillingStatus');
        action.setParams({ 
            resolutionId : resolutionId,            
            expenseId : expenseId,
            billingStatus:billingStatus
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS") {
                console.log( response.getReturnValue());
                var objWrapper = response.getReturnValue();
                cmp.set("v.resolutionWrapper",response.getReturnValue());
                cmp.set("v.unBilledexpenses",objWrapper.unbilledExpenses);
                cmp.set("v.preBilledexpenses",objWrapper.preBilledExpenses);
                cmp.set("v.showSpinner",false);           
                
            }
            else{
                cmp.set("v.showSpinner",false);
            }
            
        });
        $A.enqueueAction(action);
    },
    
    saveResolution : function(cmp) {
        cmp.set("v.showError",false);
        cmp.set("v.showSpinner",true);
        
        var resolutionId =cmp.get("v.recordId");
        var resolutionWrapper = cmp.get("v.resolutionWrapper");
        //var unbilledExpenses=  cmp.get("v.unBilledexpenses");
        // var preBilledExpenses =  cmp.get("v.preBilledexpenses");
        
        var action = cmp.get('c.saveResolution');
        action.setParams({ 
            resolutionId : resolutionId,            
            objWrapper : resolutionWrapper
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS") {
                console.log( response.getReturnValue());
                //cmp.set("v.showSuccess",true); 
                cmp.set("v.showSpinner",false); 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Successfully saved.",
                    "type": 'success'
                });
                toastEvent.fire();
                
                //refresh resolution record
                $A.get("e.force:closeQuickAction").fire();
                
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": resolutionId,
                    "slideDevName": "detail"
                    
                });
                navEvt.fire(); 
                
                
            }
            else{
                cmp.set("v.showSpinner",false);
            }
            
        });
        $A.enqueueAction(action);
    },
    
    saveAsPDF : function(cmp) {
        cmp.set("v.showError",false);
        cmp.set("v.showSpinner",true);
        
        var resolutionId =cmp.get("v.recordId");
        
        var action = cmp.get('c.savePdf');
        action.setParams({ 
            resolutionId : resolutionId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS") {
                console.log( response.getReturnValue());
                
                cmp.set("v.showSpinner",false); 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Successfully Created and saved as an attachment.",
                    "type": 'success'
                });
                toastEvent.fire();
                
                $A.get("e.force:closeQuickAction").fire();
                
                //refresh resolution record
                $A.get("e.force:closeQuickAction").fire();
                
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": resolutionId,
                    "slideDevName": "detail"
                    
                });
                navEvt.fire(); 
                
            }
            else{
                cmp.set("v.showSpinner",false);
            }
            
        });
        $A.enqueueAction(action);
    },
    
    saveAndPrintResolution : function(cmp) {
        cmp.set("v.showError",false);
        cmp.set("v.showSpinner",true);
        
        var resolutionId =cmp.get("v.recordId");
        var resolutionWrapper = cmp.get("v.resolutionWrapper");
        //var unbilledExpenses=  cmp.get("v.unBilledexpenses");
        // var preBilledExpenses =  cmp.get("v.preBilledexpenses");
        
        var action = cmp.get('c.saveResolutionAndPdf');
        action.setParams({ 
            resolutionId : resolutionId,            
            objWrapper : resolutionWrapper
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS") {
                console.log( response.getReturnValue());
                //cmp.set("v.showSuccess",true); 
                cmp.set("v.showSpinner",false); 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Successfully Created and saved as an attachment",
                    "type": 'success'
                });
                toastEvent.fire();
                
                $A.get("e.force:closeQuickAction").fire();
                
                //refresh resolution record
                $A.get("e.force:closeQuickAction").fire();
                
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": resolutionId,
                    "slideDevName": "detail"
                    
                });
                navEvt.fire(); 
                
            }
            else{
                cmp.set("v.showSpinner",false);
            }
            
        });
        $A.enqueueAction(action);
    },
    
    
})