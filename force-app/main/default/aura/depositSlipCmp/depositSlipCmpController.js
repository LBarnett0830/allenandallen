({
    init : function(component, event, helper) {
        if(document.referrer.indexOf(".lightning.force.com") > 0){
            component.set("v.recordUrlBase",'/one/one.app?#/sObject/');
            component.set("v.recordUrlBaseEnd",'/view');
        }
        else if(document.URL.indexOf(".lightning.force.com") > 0){
            component.set("v.recordUrlBase",'/one/one.app?#/sObject/');
            component.set("v.recordUrlBaseEnd",'/view');
        }
        helper.getDepositWrapper(component);
    },
    handleCancel : function(component, event, helper) {
        var homeEvt = $A.get("e.force:navigateToObjectHome");
        homeEvt.setParams({
            "scope": "Trust_Deposit__c"
        });
        homeEvt.fire();
        
    },
    
    handleAddCR: function(component, event, helper){
        var objTrustCR=  component.get("v.objDepositWrapper.objTrustCRWrapper");
        var payorId = component.get("v.payorId");
        var matterId = component.get("v.matterId");
        var matterName = component.get("v.matterName");
        var payorName = component.get("v.payorName");
        var objDepositWrapper =  component.get("v.objDepositWrapper");
        
        if(objTrustCR==null || objTrustCR.amount==undefined || objTrustCR.amount==0){
            var CRAmount =component.find('CRAmount');
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Please enter the Trust Amount.",
                "type": 'error'
            });
            toastEvent.fire();
        }else if(objTrustCR.amount<0){
            var CRAmount =component.find('CRAmount');
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Please enter a valid Trust Amount.",
                "type": 'error'
            });
            toastEvent.fire();
        }else  if(payorId==undefined || payorId==''){
            $A.get("e.force:closeQuickAction").fire();
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Please enter the Payor.",
                "type": 'error'
            });
            toastEvent.fire();
        } else  if(matterId==undefined || matterId==''){
            $A.get("e.force:closeQuickAction").fire();
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Please enter the Matter.",
                "type": 'error'
            });
            toastEvent.fire();
        } else if(objTrustCR==null || objTrustCR.depositType==undefined || objTrustCR.depositType=='' || objTrustCR.depositType=='null' || objTrustCR.depositType=='N/A'){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Please select the Deposit Type.",
                "type": 'error'
            });
            toastEvent.fire();
        } else{
            console.log(objTrustCR.amount);
            //alert('============'+objTrustCR.depositType);
            objTrustCR.payorId = payorId;
            objTrustCR.MatterId = matterId;
            objTrustCR.matterName=matterName;
            objTrustCR.payorName= payorName;
            
            var trustTotal =objDepositWrapper.objTrustDeposit.Total__c;
            trustTotal = parseFloat(trustTotal==null||undefined?0:trustTotal);
            var CRTotal =component.get("v.objDepositWrapper.CRTotal"); 
            CRTotal = CRTotal==undefined||null?0:CRTotal;
            CRTotal= parseFloat(CRTotal);
            if(parseFloat((CRTotal+parseFloat(objTrustCR.amount)).toFixed(2))> parseFloat(trustTotal.toFixed(2))){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Cash Receipts Total exceeds Deposit Amount.",
                    "type": 'error'
                });
                toastEvent.fire();
            }else if(parseInt(component.get("v.objDepositWrapper.noOfCR"))+1> parseInt(objDepositWrapper.objTrustDeposit.Number_of_Items__c)){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "No of Cash Receipts exceed Entered No.",
                    "type": 'error'
                });
                toastEvent.fire();
            }else{
                objDepositWrapper.listTrustCRWrapper.push(JSON.parse(JSON.stringify(objTrustCR)));
                component.set("v.objDepositWrapper.listTrustCRWrapper",objDepositWrapper.listTrustCRWrapper);
                console.log( objDepositWrapper.listTrustCRWrapper[0].amount);
                
                
                component.set("v.objDepositWrapper.CRTotal",parseFloat(CRTotal)+parseFloat(objTrustCR.amount));
                
                
                component.set("v.payorId",'');
                component.set("v.matterId",'');
                objTrustCR.amount=null;
                objTrustCR.payorId = '';
                objTrustCR.MatterId = '';
                objTrustCR.matterName='';
                objTrustCR.payorName= '';
                objTrustCR.reference= '';
                objTrustCR.depositType= '';
                component.set("v.objDepositWrapper.objTrustCRWrapper",objTrustCR);
                
                var noOfCR =  component.get("v.objDepositWrapper.noOfCR")==undefined?0:component.get("v.objDepositWrapper.noOfCR");
                component.set("v.objDepositWrapper.noOfCR",parseFloat(noOfCR)+1);
            }
            
        }
        
    },
    
    handleCRDelete: function(component, event, helper){
        var rowIndex =event.getSource().get("v.value");
        var objDepositWrapper=  component.get("v.objDepositWrapper");
        var listTrustCRWrapper = objDepositWrapper.listTrustCRWrapper;
        component.set("v.objDepositWrapper",objDepositWrapper);
        var CRTotal =component.get("v.objDepositWrapper.CRTotal");           
        
        component.set("v.objDepositWrapper.CRTotal",parseFloat(CRTotal)-parseFloat(objDepositWrapper.listTrustCRWrapper[rowIndex].amount));
        
        listTrustCRWrapper.splice(rowIndex,1);  
        var noOfCR =  component.get("v.objDepositWrapper.noOfCR")==undefined?0:component.get("v.objDepositWrapper.noOfCR");
        component.set("v.objDepositWrapper.noOfCR",parseFloat(noOfCR)-1);
        
        component.set("v.objDepositWrapper",objDepositWrapper);
        
    },
    
    handleOnSave: function(component, event, helper){
        var objDepositWrapper=  component.get("v.objDepositWrapper");
        if(objDepositWrapper.objTrustDeposit.Name==undefined || objDepositWrapper.objTrustDeposit.Name==''){
            //$A.get("e.force:closeQuickAction").fire();
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Please enter the Trust Deposit Name.",
                "type": 'error'
            });
            toastEvent.fire();
        }else if(objDepositWrapper.objTrustDeposit.Number_of_Items__c==null || objDepositWrapper.objTrustDeposit.Number_of_Items__c=='' || objDepositWrapper.objTrustDeposit.Number_of_Items__c==0){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Please enter the Number of Items.",
                "type": 'error'
            });
            toastEvent.fire();
        }else if(objDepositWrapper.objTrustDeposit.Number_of_Items__c<0){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Invalid Number of Items.",
                "type": 'error'
            });
            toastEvent.fire();
        }else if(objDepositWrapper.objTrustDeposit.Total__c==null || objDepositWrapper.objTrustDeposit.Total__c==''){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Please enter the Total Amount.",
                "type": 'error'
            });
            toastEvent.fire();
        }else if(objDepositWrapper.objTrustDeposit.Date__c==undefined || objDepositWrapper.objTrustDeposit.Date__c==''){
            $A.get("e.force:closeQuickAction").fire();
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Please enter the Trust Deposit Date.",
                "type": 'error'
            });
            toastEvent.fire();
        } else if(objDepositWrapper.objTrustDeposit.Total__c<0){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Please enter a valid Total Amount.",
                "type": 'error'
            });
            toastEvent.fire();
        } else if(objDepositWrapper.objTrustDeposit.Number_of_Items__c<objDepositWrapper.noOfCR){
            $A.get("e.force:closeQuickAction").fire();
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "No of Cash Receipts exceed Entered No",
                "type": 'error'
            });
            toastEvent.fire();
        }else if(parseFloat(parseFloat(objDepositWrapper.objTrustDeposit.Total__c).toFixed(2))< parseFloat(parseFloat(objDepositWrapper.CRTotal).toFixed(2))){
            $A.get("e.force:closeQuickAction").fire();
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Cash Receipts Total exceeds Deposit Amount.",
                "type": 'error'
            });
            toastEvent.fire();
        }else{
            helper.saveDepositDetails(component);
        }
        
    },
    
    handleOnSaveAndSubmit: function(component, event, helper){
        
        var objDepositWrapper=  component.get("v.objDepositWrapper");
        if(objDepositWrapper.objTrustDeposit.Name==undefined || objDepositWrapper.objTrustDeposit.Name==''){
            $A.get("e.force:closeQuickAction").fire();
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Please enter the Trust Deposit Name.",
                "type": 'error'
            });
            toastEvent.fire();
        }else if(objDepositWrapper.objTrustDeposit.Date__c==undefined || objDepositWrapper.objTrustDeposit.Date__c==''){
            $A.get("e.force:closeQuickAction").fire();
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Please enter the Trust Deposit Date.",
                "type": 'error'
            });
            toastEvent.fire();
        } else if(objDepositWrapper.objTrustDeposit.Number_of_Items__c==null || objDepositWrapper.objTrustDeposit.Number_of_Items__c=='' || objDepositWrapper.objTrustDeposit.Number_of_Items__c==0){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Please enter the Number of Items.",
                "type": 'error'
            });
            toastEvent.fire();
        }else if(objDepositWrapper.objTrustDeposit.Number_of_Items__c<=0){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Invalid Number of Items.",
                "type": 'error'
            });
            toastEvent.fire();
        }else if(objDepositWrapper.objTrustDeposit.Total__c==null || objDepositWrapper.objTrustDeposit.Total__c==''){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Please enter the Total Amount.",
                "type": 'error'
            });
            toastEvent.fire();
        }else if(objDepositWrapper.objTrustDeposit.Total__c<0){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Please enter a valid Total Amount.",
                "type": 'error'
            });
            toastEvent.fire();
        } else if(objDepositWrapper.objTrustDeposit.Number_of_Items__c!=objDepositWrapper.noOfCR){
            $A.get("e.force:closeQuickAction").fire();
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "No of Cash Receipts must be equal to Entered No.",
                "type": 'error'
            });
            toastEvent.fire();
        }else if(parseFloat(parseFloat(objDepositWrapper.objTrustDeposit.Total__c).toFixed(2))!=parseFloat(objDepositWrapper.CRTotal).toFixed(2)){
            $A.get("e.force:closeQuickAction").fire();
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Cash Receipts Total must be equal to Deposit Amount.",
                "type": 'error'
            });
            toastEvent.fire();
        }else{
            component.set('v.showSaveAndSubmitConfirm',true);
        }
        
    },
    
    hideConfirmation: function(component, event, helper){
        component.set('v.showSaveAndSubmitConfirm',false);        
        
    },
    
    processSaveAndSubmit: function(component, event, helper){
        component.set('v.showSaveAndSubmitConfirm',false);
        helper.saveAndSubmitDepositDetails(component);
        
        
    },
    
})