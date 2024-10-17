public class cancelExpenseController {
    public string expenseId{get;set;}
    public string errorMsg{get;set;}    
    public boolean showSuccess{get;set;}
    public boolean showError{get;set;}
    
    public cancelExpenseController(ApexPages.StandardController std){
        string recId = ApexPages.currentPage().getParameters().get('id');
        if(!string.isEmpty(recId)){
            expenseId = recId;
        }
    }
    
    public void checkValidation(){
        try{
            showError = false;
            if(!string.isEmpty(expenseId)){
                list<AcctSeed__Account_Payable__c>listPayablesToDelete = new  list<AcctSeed__Account_Payable__c>();
                list<litify_pm__Expense__c>listExpense =[select id,Origin__c,Stage__c,Billing_Status__c,Expense_Category__c,Create_AP__c,litify_pm__ExpenseType2__c,litify_pm__Date__c,Vendor__c,litify_pm__Matter__c,litify_pm__Matter__r.litify_pm__Client__c,litify_pm__Amount__c,litify_pm__lit_Invoice__c,litify_pm__lit_Payee__c,litify_pm__lit_Payee__r.litify_pm__Party__c
                                                         from litify_pm__Expense__c where id =:expenseId];
                               
                if(listExpense.size()>0){
                    set<id>payableIds = new set<id>();
                    for(AcctSeed__Account_Payable_Line__c payableLine : [select id,AcctSeed__Account_Payable__c from AcctSeed__Account_Payable_Line__c where Expense__c=: listExpense[0].id]){
                        if(!payableIds.contains(payableLine.AcctSeed__Account_Payable__c)){
                            payableIds.add(payableLine.AcctSeed__Account_Payable__c);
                        }
                        
                    }
                    if(payableIds.size()>0){
                        for(AcctSeed__Account_Payable__c objPayable :[select id,AcctSeed__Status__c from AcctSeed__Account_Payable__c where id in:payableIds ]){
                            if(objPayable.AcctSeed__Status__c=='Posted'){
                                showError = true;
                                errorMsg = 'Cannot cancel the Expense record when related payable was posted';
                            }
                            listPayablesToDelete.add(objPayable);
                        }
                   
                    } 
                       
                    if(!showError){
                        if(listExpense[0].Stage__c !='Approved'){
                            showError = true;
                            errorMsg = 'Only Approved expenses are allowed to be canceled';
                        }
                        else if(listExpense[0].Origin__c !='Litify'){
                            showError = true;
                            errorMsg = 'Only Litify source expenses are allowed to be canceled.';
                        }
                        
                        else{
                            listExpense[0].Stage__c='Cancelled';
                            update listExpense[0];
                             payableTriggerHandler.hasFiredFromExpenseTrigger=true;
                            delete listPayablesToDelete;
                            showSuccess =true;
                        }
                    }
                    
                    
                }
            }
        }
        catch(Exception ex){
            showError = true;
            errorMsg = 'Error occured, Please contact the salesforce Administrator.';
        }
    }
    
    public PageReference redirectToDetail(){
        PageReference pg ;
        try
        {
            if(!string.isEmpty(expenseId)){
                system.debug('recordId '+expenseId);
                pg= new PageReference('/'+expenseId);
                pg.setRedirect(true);
                return pg;
            }
            
        }
        catch(Exception ex){}
        return pg;
        
    }
    public PageReference redirectToList(){
        try
        {
            return new ApexPages.Action('{!List}').invoke();
            
        }
        catch(Exception ex){}
        return null;
        
    }
    
    
}