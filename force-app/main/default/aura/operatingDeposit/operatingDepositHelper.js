({
    getDepositWrapper : function(component) {
        component.set("v.showError",false);
        component.set("v.showSpinner",true);
        var recordId =component.get("v.recordId");
        var action = component.get('c.getDepositDetailsFromTab');
        action.setParams({             
            
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS") {
                console.log(response.getReturnValue());
                var objWrapper = response.getReturnValue();
                component.set("v.objDepositWrapper",response.getReturnValue());
                component.set("v.GlId",objWrapper.GlId);
                component.set("v.GlName",objWrapper.GlName);
                component.set("v.showSpinner",false);
                if(objWrapper.objDeposit.Status__c!='In-Process' && objWrapper.objDeposit.Status__c!=null){
                    component.set("v.disableInput",true);
                }
            }
            else {
                component.set("v.showSpinner",false);
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        this.showErrorToast(component,event,errors[0].message);
                    }
                } else {
                    this.showErrorToast(component,event,'Unknown error');
                    
                }
            }
            
        });
        $A.enqueueAction(action);
    },
    
    getMatterRelatedProjects : function(component,event) {
        
        var recordId = component.get("v.matterId");
        var action = component.get('c.getRelatedProjects');
        action.setParams({             
            "matterId" : recordId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS") {
                var projectList = response.getReturnValue();
                if(projectList.length > 1) {
                    this.showErrorToast(component,event,'This matter has multiple projects');
                }
            }
            else {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        this.showErrorToast(component,event,errors[0].message);
                    }
                } else {
                    this.showErrorToast(component,event,'Unknown error');
                    
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    handleSaveRow: function(component){
        var objDepositWrapper = component.get("v.objDepositWrapper");
        var listJELineWrapper = component.get("v.objDepositWrapper.listJELineWrapper");
        var rowIndex = listJELineWrapper.length;
        var hasError = false;
        var amount = 0;
        var noOfLinesAdded = 0;
        var expTotal = objDepositWrapper.objDeposit.Total__c;
            
        for(var i=0; i<rowIndex; i++) {
            var objExp=  listJELineWrapper[i];
            var errorMsg;
            var rowHasError = false;
            var payorId = objExp.payorId;
            var matterId = objExp.matterId;
            var matterName = objExp.matterName;
            var payorName = objExp.payorName;
            var CreditGlAccId = objExp.CreditGlAccId;
            var CreditGlAccName = objExp.CreditGlAccName;
            var expenseTypeId = objExp.expenseTypeId;
            var expenseTypeName = objExp.expenseTypeName;
            var createExpense = objExp.createExpense;
            var expenseStatus = objExp.expenseStatus;
            var objDepositDate = objDepositWrapper.objDeposit.Date__c;
            var objExpDate = objExp.jeLineDate;        
            var depositDate = new Date(objDepositDate.toString());
            if(objExpDate != undefined) {
                var jeLineDate = new Date(objExpDate.toString());
            }
            var objDepositName = objDepositWrapper.objDeposit.Name;
            var noOfItems = objDepositWrapper.objDeposit.Number_of_Items__c;
            
            console.log('rowHasError'+rowHasError);
            console.log('matterId'+matterId);
            
            if(objExp==null || objExp.amount==undefined || objExp.amount==0){
                rowHasError = true;
                errorMsg = 'Please enter Cash Receipt Amount for Row '+(i+1);
                this.showErrorToast(component, event, errorMsg);
                
            }else if(objExp.amount<0){
                rowHasError = true;
                errorMsg = 'Please enter a valid Cash Receipt Amount for Row '+(i+1);
                this.showErrorToast(component, event, errorMsg);
                
            }else if(payorName==undefined || payorName==''){
                rowHasError = true;
                errorMsg = 'Please enter the Payor for Row '+(i+1);
                this.showErrorToast(component, event, errorMsg);
                
            }else if(CreditGlAccId==undefined || CreditGlAccId==null){
                rowHasError = true;
                errorMsg = 'Please enter the Credit GL Account for Row '+(i+1);
                this.showErrorToast(component, event, errorMsg);
                
            }else if(objExp.jeLineDate==undefined || objExp.jeLineDate==null){
                rowHasError = true;
                errorMsg = 'Please enter the Date for Row '+(i+1);
                this.showErrorToast(component, event, errorMsg);
                
            }else if(depositDate.getMonth()!==jeLineDate.getMonth()){
                rowHasError = true;
                errorMsg = 'Please use the same Accounting Period for Row '+(i+1);
                this.showErrorToast(component, event, errorMsg);
                
            }else if((createExpense == 'Negative'|| createExpense == 'Positive') && (matterId==undefined || matterId==null)){
                console.log(createExpense + matterId);
                rowHasError = true;
                errorMsg = 'Please enter the Matter for Row '+(i+1);
                this.showErrorToast(component, event, errorMsg);
                
            }else if((createExpense == 'Negative'|| createExpense == 'Positive') && (expenseTypeId==undefined || expenseTypeId==null)){
                rowHasError = true;
                errorMsg = 'Please enter the Expense Type for Row '+(i+1);
                this.showErrorToast(component, event, errorMsg);
                
            }else if((createExpense == 'Negative'|| createExpense == 'Positive') && (expenseStatus==undefined || expenseStatus==null || expenseStatus=='' || expenseStatus=='N/A')){
                rowHasError = true;
                errorMsg = 'Please enter the Expense Billing Status for Row '+(i+1);
                this.showErrorToast(component, event, errorMsg);
                
            }
            if(rowHasError == true) {
                hasError = true;
            }
            if(hasError == false && rowHasError == false && i==rowIndex-1) {
                hasError = false;
            }
        }   
        
        component.set("v.hasError",hasError);
        console.log('hasError'+hasError);
    },
    
    saveDepositDetails : function(component) {
        var objDepositWrapper= component.get("v.objDepositWrapper");
        var GLAccId = component.get("v.GlId");
        component.set("v.showError",false);
        component.set("v.showSpinner",true);
        var action = component.get('c.saveDepositDetails');
        action.setParams({             
            objDepositWrapper : objDepositWrapper,
            GLAccId : GLAccId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS") {
                component.set("v.showSpinner",false);
                this.showSuccessToast(component,event,"Successfully saved.");
                this.redirectHome(component);
                
            }
            else {
                component.set("v.showSpinner",false);
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        this.showErrorToast(component,event,errors[0].message);
                    }
                } else {
                    this.showErrorToast(component,event,'Unknown error');
                    
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    saveAndSubmitDepositDetails : function(component) {
        var objDepositWrapper= component.get("v.objDepositWrapper");
        var GLAccId = component.get("v.GlId");
        component.set("v.showError",false);
        component.set("v.showSpinner",true);
        var action = component.get('c.saveAndSubmitDepositDetails');
        action.setParams({             
            objDepositWrapper : objDepositWrapper,
            GLAccId : GLAccId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS") {
                component.set("v.showSpinner",false);
                this.showSuccessToast(component,event,"Successfully saved.");
                this.redirectHome(component);
                
            }
            else {
                component.set("v.showSpinner",false);
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        this.showErrorToast(component,event,errors[0].message);
                    }
                } else {
                    this.showErrorToast(component,event,'Unknown error');
                    
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    showSuccessToast : function(component,event, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success',
            message: message,
            duration:' 5000',
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
        });
        toastEvent.fire();
        
    },
    
    showErrorToast : function(component,event, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error',
            message: message,
            duration:' 5000',
            key: 'info_alt',
            type: 'error',
            mode: 'pester'
        });
        toastEvent.fire();
    },
    
    redirectHome : function(component) {
        var homeEvt = $A.get("e.force:navigateToObjectHome");
        homeEvt.setParams({
            "scope": "Trust_Deposit__c"
        });
        homeEvt.fire();
        
    }
})