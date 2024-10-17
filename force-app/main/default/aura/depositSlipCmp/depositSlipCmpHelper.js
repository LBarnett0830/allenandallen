({
    getDepositWrapper : function(cmp) {
        cmp.set("v.showError",false);
        cmp.set("v.showSpinner",true);
        var recordId =cmp.get("v.recordId");
        var action = cmp.get('c.getDepositDetails');
        action.setParams({             
            trustDepositId : recordId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS") {
                console.log( response.getReturnValue());
                var objWrapper = response.getReturnValue();
                
                cmp.set("v.objDepositWrapper",response.getReturnValue());
                cmp.set("v.showSpinner",false);
                
                if(objWrapper.objTrustDeposit.Status__c!='In-Process' && objWrapper.objTrustDeposit.Status__c!=null){
                     cmp.set("v.disableInput",true);
                }
                
                /* if(cmp.get("v.resolutionWrapper.objResolution.litify_pm__Matter__r.Name")==null){
                    $A.get("e.force:closeQuickAction").fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "The selected Resolution does not have a Matter associated.",
                        "type": 'error'
                    });
                    toastEvent.fire();
                    
                }*/
            }
            
        });
        $A.enqueueAction(action);
    },
    
    saveDepositDetails : function(cmp) {
        var objDepositWrapper= cmp.get("v.objDepositWrapper");
        console.log(objDepositWrapper.listTrustCR);
        cmp.set("v.showError",false);
        cmp.set("v.showSpinner",true);
        var action = cmp.get('c.saveDepositDetails');
        action.setParams({             
            objDepositWrapper : objDepositWrapper
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS") {
                cmp.set("v.showSpinner",false);
                
                console.log( response.getReturnValue());
                var msgMap = response.getReturnValue();
                if(msgMap.success=='true'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Successfully saved.",
                        "type": 'success'
                    });
                    toastEvent.fire();
                    this.redirectHome(cmp);
                    
                } else if(msgMap.error=='true'){
                    $A.get("e.force:closeQuickAction").fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Error occured.",
                        "type": 'error'
                    });
                    toastEvent.fire();
                    
                }
                
            }
            
        });
        $A.enqueueAction(action);
    },
    
    saveAndSubmitDepositDetails : function(cmp) {
        var objDepositWrapper= cmp.get("v.objDepositWrapper");
        console.log(objDepositWrapper.listTrustCR);
        cmp.set("v.showError",false);
        cmp.set("v.showSpinner",true);
        var action = cmp.get('c.saveAndSubmitDepositDetails');
        action.setParams({             
            objDepositWrapper : objDepositWrapper
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS") {
                cmp.set("v.showSpinner",false);
                
                console.log( response.getReturnValue());
                var msgMap = response.getReturnValue();
                if(msgMap.success=='true'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Successfully saved.",
                        "type": 'success'
                    });
                    toastEvent.fire();
                    this.redirectHome(cmp);
                    
                } else if(msgMap.error=='true'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Error occured.",
                        "type": 'error'
                    });
                    toastEvent.fire();
                    
                }else if(msgMap.invalidCustomSettings=='true'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Invalid data in 'Trust GL Accounts' custom setting.",
                        "type": 'error'
                    });
                    toastEvent.fire();
                    
                }else if(msgMap.invalidProjectTask=='true'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Default Project task is missing in related Project of "+msgMap.invalidProjectName,
                        "type": 'error'
                    });
                    toastEvent.fire();
                    
                }else if(msgMap.invalidLedger=='true'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Couldn't find the TRUST Ledger",
                        "type": 'error'
                    });
                    toastEvent.fire();
                    
                }else if(msgMap.invalidAccPeriod=='true'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Invalid Accounting period for the selected date",
                        "type": 'error'
                    });
                    toastEvent.fire();
                    
                }
                
            }
            
        });
        $A.enqueueAction(action);
    },
    
    redirectHome : function(component) {
        var homeEvt = $A.get("e.force:navigateToObjectHome");
        homeEvt.setParams({
            "scope": "Trust_Deposit__c"
        });
        homeEvt.fire();
        
    },
    
    
})