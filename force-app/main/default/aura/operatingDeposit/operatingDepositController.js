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
        component.set("v.BankNameFilter","AcctSeed__Bank__c=true AND Name IN "+$A.get("$Label.c.Operating_Deposit_Banks"));
    },
    
    validateMatter : function(component, event, helper) {
        helper.getMatterRelatedProjects(component,event);
    },
    
    handleCancel : function(component, event, helper) {
        var homeEvt = $A.get("e.force:navigateToObjectHome");
        homeEvt.setParams({
            "scope": "Trust_Deposit__c"
        });
        homeEvt.fire();
    },
    
    handleLineAmountChange: function(component, event, helper){
        var jeLineTotal = component.get("v.objDepositWrapper.jeLineTotal");
        var objDepositWrapper = component.get("v.objDepositWrapper");
        var listJELineWrapper = objDepositWrapper.listJELineWrapper;
        var totalLinesAdded = listJELineWrapper.length;
        var amountChanged = 0;
        var expTotal = objDepositWrapper.objDeposit.Total__c;
        
        for(var i=0; i<totalLinesAdded; i++) {
          var objExp=  listJELineWrapper[i];
            if(objExp.amount!=undefined || objExp.amount>0) {
                amountChanged = parseFloat(amountChanged)+parseFloat(objExp.amount);
            }
        }
        component.set("v.objDepositWrapper.jeLineTotal",amountChanged);
        if(amountChanged > parseFloat(expTotal)){
            helper.showErrorToast(component, event, 'Cash receipts total exceeds deposit amount');
        }
    },
    
    handleAddCR: function(component, event, helper){
        var GLAccId = component.get("v.GlId");
        var objDepositWrapper = component.get("v.objDepositWrapper");
        var accPeriodId = component.get("v.objDepositWrapper.accPeriodId");
        var objExp=  component.get("v.objDepositWrapper.objJELineWrapper");
        var payorId = component.get("v.objDepositWrapper.objJELineWrapper.payorId");
        var matterId = component.get("v.objDepositWrapper.objJELineWrapper.matterId");
        var matterName = component.get("v.objDepositWrapper.objJELineWrapper.matterName");
        var payorName = component.get("v.objDepositWrapper.objJELineWrapper.payorName");
        var CreditGlAccId = component.get("v.objDepositWrapper.objJELineWrapper.CreditGlAccId");
        var CreditGlAccName = component.get("v.objDepositWrapper.objJELineWrapper.CreditGlAccName");
        var createExpense = component.get("v.objDepositWrapper.objJELineWrapper.createExpense");
        var expenseStatus = component.get("v.objDepositWrapper.objJELineWrapper.expenseStatus");
        var expTotal = objDepositWrapper.objDeposit.Total__c;
        var objDepositDate = objDepositWrapper.objDeposit.Date__c;
        var expenseTypeId = component.get("v.objDepositWrapper.objJELineWrapper.expenseTypeId");
        var expenseTypeName = component.get("v.objDepositWrapper.objJELineWrapper.expenseTypeName");
        var objExpDate = component.get("v.objDepositWrapper.objJELineWrapper.jeLineDate");        
        var depositDate = new Date(objDepositDate.toString());
        if(objExpDate != undefined) {
        var jeLineDate = new Date(objExpDate.toString());
        }
        var objDepositName = objDepositWrapper.objDeposit.Name;
        var noOfItems = objDepositWrapper.objDeposit.Number_of_Items__c;
        
        if(GLAccId==undefined || GLAccId==''){
            helper.showErrorToast(component, event, 'Please enter the bank account');
            
        }else if(accPeriodId==undefined || accPeriodId==''){
            helper.showErrorToast(component, event, 'Please enter the accounting period');
            
        }else if(objDepositName==undefined || objDepositName==null || objDepositName===''){
            helper.showErrorToast(component, event, 'Please enter deposit name');
            
        }else if(expTotal==undefined || expTotal==null){
            helper.showErrorToast(component, event, 'Please enter deposit total amount');
            
        }else if(expTotal<=0){
            helper.showErrorToast(component, event, 'Please enter a valid deposit total amount');
            
        }else if(noOfItems==undefined || noOfItems==null){
            helper.showErrorToast(component, event, 'Please enter deposit number of items');
            
        }else if(objExp==null || objExp.amount==undefined || objExp.amount==0){
            helper.showErrorToast(component, event, 'Please enter cash receipt amount');
            
        }else if(objExp.amount<0){
            helper.showErrorToast(component, event, 'Please enter a valid cash receipt amount');
            
        }else if(payorName==undefined || payorName==''){
            helper.showErrorToast(component, event, 'Please enter the payor');
            
        }else if(CreditGlAccId==undefined || CreditGlAccId==null){
            helper.showErrorToast(component, event, 'Please enter the credit GL account');
            
        }else if(objExp.jeLineDate==undefined || objExp.jeLineDate==null){
            helper.showErrorToast(component, event, 'Please enter the date');
            
        }else if(depositDate.getMonth()!==jeLineDate.getMonth()){
            helper.showErrorToast(component, event, 'Please use the same accounting period');
            
        }else if((createExpense == 'Negative'|| createExpense == 'Positive') && (matterId==undefined || matterId==null)){
            helper.showErrorToast(component, event, 'Please enter the matter');
            
        }else if((createExpense == 'Negative'|| createExpense == 'Positive') && (expenseTypeId==undefined || expenseTypeId==null)){
            helper.showErrorToast(component, event, 'Please enter the expense type');
            
        }else if((createExpense == 'Negative'|| createExpense == 'Positive') && (expenseStatus==undefined || expenseStatus==null || expenseStatus=='' || expenseStatus=='N/A')){
            helper.showErrorToast(component, event, 'Please enter the expense billing status');
        }
        else{
            objExp.payorId = payorId;
            objExp.MatterId = matterId;
            objExp.matterName=matterName;
            objExp.payorName= payorName;
            objExp.CreditGlAccId =CreditGlAccId;
            objExp.CreditGlAccName =CreditGlAccName;
            objExp.createExpense = createExpense;
            objExp.expenseStatus = expenseStatus;
            objExp.expenseTypeId = expenseTypeId;
            objExp.expenseTypeName = expenseTypeName;
            
            expTotal = parseFloat(expTotal==null||undefined?0:expTotal);
            var jeLineTotal =component.get("v.objDepositWrapper.jeLineTotal"); 
            jeLineTotal = jeLineTotal==undefined||null?0:jeLineTotal;
            jeLineTotal= parseFloat(jeLineTotal);
            
            
            if(parseFloat((jeLineTotal+parseFloat(objExp.amount)).toFixed(2))> parseFloat(expTotal.toFixed(2))){
                helper.showErrorToast(component, event, 'Cash receipts total exceeds deposit amount');
                
            }else if(parseInt(component.get("v.objDepositWrapper.noOfJELines"))+1> parseInt(objDepositWrapper.objDeposit.Number_of_Items__c)){
                helper.showErrorToast(component, event, 'No. of cash receipts exceed entered no.');
                
            }else{
                objDepositWrapper.listJELineWrapper.push(JSON.parse(JSON.stringify(objExp)));
                component.set("v.objDepositWrapper.listJELineWrapper",objDepositWrapper.listJELineWrapper); 
                component.set("v.objDepositWrapper.jeLineTotal",parseFloat(jeLineTotal)+parseFloat(objExp.amount));                
                objExp.amount=null;
                objExp.payorId = '';
                objExp.matterId = '';
                objExp.matterName='';
                objExp.payorName= '';
                objExp.narrative= '';
                objExp.jeLineDate= null;
                objExp.CreditGlAccId= '';
                objExp.CreditGlAccName= '';
                objExp.createExpense = '';
                objExp.expenseStatus = '';
                objExp.expenseTypeId = '';
                objExp.expenseTypeName = '';
                component.set("v.objDepositWrapper.objJELineWrapper",objExp);
                
                var noOfJELines =  component.get("v.objDepositWrapper.noOfJELines")==undefined?0:component.get("v.objDepositWrapper.noOfJELines");
                component.set("v.objDepositWrapper.noOfJELines",parseFloat(noOfJELines)+1);
            }
            
        }
        
    },
    
    handleCRDelete: function(component, event, helper){
        var rowIndex =event.getSource().get("v.value");
        var objDepositWrapper=  component.get("v.objDepositWrapper");
        var listJELineWrapper = objDepositWrapper.listJELineWrapper;
        component.set("v.objDepositWrapper",objDepositWrapper);
        var jeLineTotal =component.get("v.objDepositWrapper.jeLineTotal");           
        
        component.set("v.objDepositWrapper.jeLineTotal",parseFloat(jeLineTotal)-parseFloat(objDepositWrapper.listJELineWrapper[rowIndex].amount));
        listJELineWrapper.splice(rowIndex,1);  
        var noOfJELines =  component.get("v.objDepositWrapper.noOfJELines")==undefined?0:component.get("v.objDepositWrapper.noOfJELines");
        component.set("v.objDepositWrapper.noOfJELines",parseFloat(noOfJELines)-1);
        
        component.set("v.objDepositWrapper",objDepositWrapper);
    },
    
    handleOnSave: function(component, event, helper){
        var objDepositWrapper=  component.get("v.objDepositWrapper");
        var GLAccId=  component.get("v.GlId");
        if(objDepositWrapper.objDeposit.Name==undefined || objDepositWrapper.objDeposit.Name==''){
            helper.showErrorToast(component, event, 'Please enter the deposit name');
            
        }else if(objDepositWrapper.objDeposit.Number_of_Items__c==null || objDepositWrapper.objDeposit.Number_of_Items__c=='' || objDepositWrapper.objDeposit.Number_of_Items__c==0){
            helper.showErrorToast(component, event, 'Please enter the number of items');
            
        }else if(objDepositWrapper.objDeposit.Number_of_Items__c<0){
            helper.showErrorToast(component, event, 'Invalid number of items');
            
        }else if(objDepositWrapper.objDeposit.Total__c==null || objDepositWrapper.objDeposit.Total__c==''){
            helper.showErrorToast(component, event, 'Please enter the total amount');
            
        }else if(objDepositWrapper.objDeposit.Date__c==undefined || objDepositWrapper.objDeposit.Date__c==''){
            helper.showErrorToast(component, event, 'Please enter the deposit date');
            
        } else if(objDepositWrapper.objDeposit.Total__c<0){
            helper.showErrorToast(component, event, 'Please enter a valid total amount');
            
        } else if(objDepositWrapper.objDeposit.Number_of_Items__c<objDepositWrapper.noOfJELines){
            helper.showErrorToast(component, event, 'No. of cash receipts exceed entered no.');
            
        }else if(parseFloat(parseFloat(objDepositWrapper.objDeposit.Total__c).toFixed(2))< parseFloat(parseFloat(objDepositWrapper.jeLineTotal).toFixed(2))){
            helper.showErrorToast(component, event, 'Cash receipts total exceeds deposit amount');
            
        }else if(GLAccId==undefined || GLAccId==''){
            helper.showErrorToast(component, event, 'Please enter the bank account');
            
        }else{
            helper.handleSaveRow(component);
            var hasError = component.get("v.hasError");
            if(hasError == false) {
                helper.saveDepositDetails(component);
            }
        }
        
    },
    
    handleOnSaveAndSubmit: function(component, event, helper){
        var GLAccId=  component.get("v.GlId");
        var objDepositWrapper=  component.get("v.objDepositWrapper");
        if(objDepositWrapper.objDeposit.Name==undefined || objDepositWrapper.objDeposit.Name==''){
            helper.showErrorToast(component, event, 'Please enter the deposit name');
            
        }else if(objDepositWrapper.objDeposit.Date__c==undefined || objDepositWrapper.objDeposit.Date__c==''){
            helper.showErrorToast(component, event, 'Please enter the deposit date');
            
        } else if(objDepositWrapper.objDeposit.Number_of_Items__c==null || objDepositWrapper.objDeposit.Number_of_Items__c=='' || objDepositWrapper.objDeposit.Number_of_Items__c==0){
            helper.showErrorToast(component, event, 'Please enter the number of items');
            
        }else if(objDepositWrapper.objDeposit.Number_of_Items__c<=0){
            helper.showErrorToast(component, event, 'Invalid number of items');
            
        }else if(objDepositWrapper.objDeposit.Total__c==null || objDepositWrapper.objDeposit.Total__c==''){
            helper.showErrorToast(component, event, 'Please enter the total amount');
            
        }else if(objDepositWrapper.objDeposit.Total__c<0){
            helper.showErrorToast(component, event, 'Please enter a valid total amount');
            
        } else if(objDepositWrapper.objDeposit.Number_of_Items__c!=objDepositWrapper.noOfJELines){
            helper.showErrorToast(component, event, 'No. of cash receipts must be equal to entered no.');
            
        }else if(parseFloat(parseFloat(objDepositWrapper.objDeposit.Total__c).toFixed(2))!=parseFloat(objDepositWrapper.jeLineTotal).toFixed(2)){
            helper.showErrorToast(component, event, 'Cash receipts total must be equal to deposit amount');
            
        }else if(GLAccId==undefined || GLAccId==''){
            helper.showErrorToast(component, event, 'Please enter the bank account');
            
        }else{
            helper.handleSaveRow(component);
            var hasError = component.get("v.hasError");
            if(hasError == false) {
            component.set('v.showSaveAndSubmitConfirm',true);
            }
        }
    },
    
    hideConfirmation: function(component, event, helper){
        component.set('v.showSaveAndSubmitConfirm',false);       
    },
    
    processSaveAndSubmit: function(component, event, helper){
        component.set('v.showSaveAndSubmitConfirm',false);
        helper.saveAndSubmitDepositDetails(component);
    }
})