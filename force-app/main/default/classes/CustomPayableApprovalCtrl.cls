/*
Updated by : Sampath Suranji
Date       : 08/10/2020
Description: Fix issues
*/
public without sharing class CustomPayableApprovalCtrl {
    
    public string payableApprovalId {get;set;}
    public string errorMsg {get;set;}  
    public boolean showSuccess {get;set;}
    public boolean showError {get;set;}
    public AcctSeed__Account_Payable__c payable {get;set;}
    
    public CustomPayableApprovalCtrl(){
        showError = false;
        showSuccess =false;
        string recId = ApexPages.currentPage().getParameters().get('Id');
        if(!string.isEmpty(recId)){
            payableApprovalId = recId;
        }
    }
    
    public void submit(){
        
        savepoint sp;
        try{
            sp = database.setSavepoint();
            if(String.isNotBlank(payableApprovalId)){
                
                Approval.ProcessSubmitRequest objAppReq = new Approval.ProcessSubmitRequest();
                objAppReq.setComments('Submitting Request for approval.');
                objAppReq.setObjectId(payableApprovalId);
                objAppReq.setSubmitterId(UserInfo.getUserId());
                
                
                Map<Id,AcctSeed__Account_Payable_Line__c> payableIdPayLineMap = new Map<Id,AcctSeed__Account_Payable_Line__c>();
                List<AcctSeed__Account_Payable__c> payableList = [SELECT Id,Expense_Type__c,AcctSeed__Total__c,AcctSeed__Status__c,AcctSeed__Vendor__r.Matter_Vendor__c,Origin__c,
                                                                  (SELECT Id,AcctSeed__Expense_GL_Account__c,AcctSeed__Expense_GL_Account__r.Department__c,
                                                                   AcctSeed__Expense_GL_Account__r.Department__r.Director__c FROM AcctSeed__Project_Account_Payable_Lines__r 
                                                                   Limit 1) 
                                                                  FROM AcctSeed__Account_Payable__c WHERE Id=: payableApprovalId LIMIT 1];
                for(AcctSeed__Account_Payable__c payable :payableList ){
                    for(AcctSeed__Account_Payable_Line__c payLine : payable.AcctSeed__Project_Account_Payable_Lines__r){
                        if(!payableIdPayLineMap.containsKey(payable.id)){
                            payableIdPayLineMap.put(payable.id, payLine);
                        }
                    }
                }
                if(!payableList.isEmpty()){
                    payable = new AcctSeed__Account_Payable__c();
                    payable = payableList[0];
                     if(payable.AcctSeed__Status__c != 'In Process'){
                         showError = true;
                         errorMsg = 'Payable record is not in a valid stage to submit for approval';
                     }
                    
                    if(!showError){
                        if(payable.Expense_Type__c == 'Operating'){
                            objAppReq.setProcessDefinitionNameOrId('Payables_Operating_Costs');
                            if(payable.AcctSeed__Total__c > 500){
                                
                                if(!payableIdPayLineMap.isEmpty() && payableIdPayLineMap.containskey(payable.id) && payableIdPayLineMap.get(payable.id) != null){
                                    if(payableIdPayLineMap.get(payable.id).AcctSeed__Expense_GL_Account__c==null){
                                        showError = true;
                                        errorMsg = 'Expense GL Account is required in related Payable line record';
                                    }else if( payableIdPayLineMap.get(payable.id).AcctSeed__Expense_GL_Account__r.Department__c == Null){
                                        showError = true;
                                        errorMsg = 'Department is required in Expense GL Account of related Payable line record';
                                    }else if( payableIdPayLineMap.get(payable.id).AcctSeed__Expense_GL_Account__r.Department__r.Director__c == Null){
                                        showError = true;
                                        errorMsg = 'Director is required in Department of Expense GL Account in related Payable line record';
                                    }else{
                                        objAppReq.setNextApproverIds( new id[]{payableIdPayLineMap.get(payable.id).AcctSeed__Expense_GL_Account__r.Department__r.Director__c});
                                    }
                                } else {
                                    showError = true;
                                    errorMsg = 'No Matching Payable Line found';
                                }
                            }
                            if(!showError){
                                Approval.ProcessResult result = Approval.process(objAppReq);
                                if(result.isSuccess()){
                                    showSuccess =true;
                                } 
                            }
                            
                        }else if(payable.Expense_Type__c == 'Matter'){
                            if(payable.Origin__c!='AP'){
                                showError = true;
                                errorMsg = 'Origin should be AP';
                            }
                            else if(!(payable.AcctSeed__Status__c=='In Process' || payable.AcctSeed__Status__c=='Rejected')){
                                showError = true;
                                errorMsg = 'Payable record is not in a valid status to submit for Approval.';
                                
                            }else{
                                system.debug( payable.AcctSeed__Vendor__r.Matter_Vendor__c);
                                objAppReq.setProcessDefinitionNameOrId('Case_Invoices_Created_in_AP');
                                Approval.ProcessResult result = Approval.process(objAppReq);
                                if(result.isSuccess()){
                                    showSuccess =true;
                                } 
                            }
                             
                            
                          
                        }
                    }
                }
            }
        }Catch(Exception ex){
            System.debug('The following exception has occurred: ' + ex.getMessage());
            System.debug('Exception Line '+ex.getLineNumber());
            if(sp!=null){
                database.rollback(sp);
                showError = true;
                errorMsg = ex.getMessage();
            }
        }
    }
    
    public PageReference redirectToDetail(){
        PageReference pg ;
        Try{
            if(!string.isEmpty(payableApprovalId)){
                system.debug('recordId '+payableApprovalId);
                pg= new PageReference('/'+payableApprovalId);
                pg.setRedirect(true);
                return pg;
            }
            
        }Catch(Exception ex){
            
        }
        
        Return pg;
    }
}