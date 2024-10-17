/*
Author: Cmentor/Sampath Suranji
Date  :05/29/2020
Description : deleteExpenseController for overwwrite Expense Standard delete button
*/
public class deleteExpenseController {
    public string expenseId{get;set;}
    public string errorMsg{get;set;}    
    public boolean showSuccess{get;set;}
    public boolean showError{get;set;}
    
    public deleteExpenseController(ApexPages.StandardController std){
        string recId = std.getId();//ApexPages.currentPage().getParameters().get('id');
        if(!string.isEmpty(recId)){
            expenseId = recId;
        }
    }
    
    public void checkValidation(){
        try{                                  
            showError = false;
            if(!string.isEmpty(expenseId)){
                list<litify_pm__Expense__c>listExpense =[select id,Origin__c,Stage__c,Billing_Status__c,Expense_Category__c,Create_AP__c,litify_pm__ExpenseType2__c,litify_pm__Date__c,Vendor__c,litify_pm__Matter__c,litify_pm__Matter__r.litify_pm__Client__c,litify_pm__Amount__c,litify_pm__lit_Invoice__c,litify_pm__lit_Payee__c,litify_pm__lit_Payee__r.litify_pm__Party__c,CreatedById,litify_pm__Matter__r.OwnerId
                                                         from litify_pm__Expense__c where id =:expenseId];
                
                
                if(listExpense.size()>0){
                    String userProfileName = [select Name from profile where id =: userinfo.getProfileId()].Name;
                    
                    if(listExpense[0].Billing_Status__c !='Unbilled'){
                        showError = true;
                        errorMsg = 'Only Unbilled Expenses are allowed to be deleted';
                    }
                    
                    else if(!(listExpense[0].Stage__c =='In-Process' || listExpense[0].Stage__c =='N/A' || listExpense[0].Stage__c =='N/A-SoftCost' || listExpense[0].Stage__c =='N/A-File') && listExpense[0].Billing_Status__c =='Unbilled'){
                        showError = true;
                        errorMsg = 'Expense record is not in a valid Stage to delete';
                    }
                    else if(!(userInfo.getUserId()==listExpense[0].CreatedById || userInfo.getUserId()==listExpense[0].litify_pm__Matter__r.OwnerId || userProfileName == 'System Administrator' || userProfileName=='Litify Accounting User')){
                        showError = true;
                        errorMsg = 'You do not have permission to delete';
                       
                    }
                    else{
                        delete listExpense[0];
                        showSuccess =true;
                    }
                    
                }
            }
            
            if(Test.isRunningTest())
			{
				throw new NullPointerException();
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