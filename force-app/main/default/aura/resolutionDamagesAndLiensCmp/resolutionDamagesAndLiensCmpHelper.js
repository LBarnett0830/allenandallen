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
                cmp.set("v.resolutionWrapper",response.getReturnValue());                
                cmp.set("v.showSpinner",false);
                
                if(objWrapper.objResolution.Status__c=='Final' || objWrapper.objResolution.Status__c=='Approved' || objWrapper.objResolution.Status__c=='Closed'){
                    cmp.set("v.disableInput",true);
                }


                objWrapper.totalDamagesAmount == objWrapper.objResolution.litify_pm__Total_Damages__c;
                console.log('Total Damage Amount on Init: ', objWrapper.totalDamagesAmount);


                objWrapper.totalLienesAmount == objWrapper.objResolution.Total_Liens__c;
                console.log('Total Lien Amount on Init: ', objWrapper.totalLienesAmount);

                
                if(cmp.get("v.resolutionWrapper.objResolution.litify_pm__Matter__r.Name")==null){
                    $A.get("e.force:closeQuickAction").fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "The selected Resolution does not have a Matter associated.",
                        "type": 'error'
                    });
                    toastEvent.fire();
                    
                }else{
                    if(objWrapper.selectedDamages.length>0){
                        var amount=0;
                        for(var i=0;i<objWrapper.selectedDamages.length;i++){
                            if(objWrapper.selectedDamages[i].litify_pm__Amount_Due__c!=undefined && objWrapper.selectedDamages[i].litify_pm__Amount_Due__c!=null){
                                amount = amount + parseFloat(objWrapper.selectedDamages[i].litify_pm__Amount_Due__c);
                            }
                        }
                        //cmp.set("v.resolutionWrapper.totalDamagesAmount",amount);
                    }
                    if(objWrapper.selectedLienes.length>0){
                        var amount=0;
                        for(var i=0;i<objWrapper.selectedLienes.length;i++){
                            if(objWrapper.selectedLienes[i].litify_pm__lit_Amount_Due__c!=undefined && objWrapper.selectedLienes[i].litify_pm__lit_Amount_Due__c!=null){
                                amount = amount + parseFloat(objWrapper.selectedLienes[i].litify_pm__lit_Amount_Due__c);
                            }
                        }
                        //cmp.set("v.resolutionWrapper.totalLienesAmount",amount);
                    }
                }
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
                cmp.set("v.showSpinner",false);
                var msgMap = response.getReturnValue();
                if(msgMap.success=='true'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Successfully saved.",
                        "type": 'success'
                    });
                    toastEvent.fire();
                }else if(msgMap.error=='true'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Error occured.",
                        "type": 'error'
                    });
                    toastEvent.fire();
                }
                
                
                
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