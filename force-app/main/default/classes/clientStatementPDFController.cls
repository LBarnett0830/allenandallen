/*
Author: Cmentor/Sampath Suranji
Date   :06/02/2020
Description: clientStatementPDFController for Cost recovery pdf
*/
public class clientStatementPDFController {
    public string currentDate{get;set;}
    public resolutionExpensesWrapper objWrapper {get;set;}
    
    public clientStatementPDFController(){
        string recId= ApexPages.currentPage().getParameters().get('Id');
        if(!string.isEmpty(recId)){
            getAllRecords(recId);
        }
    }
    
    public  resolutionExpensesWrapper getAllRecords(string resolutionId){
        
        try{
            
            string matterId='';
            List<litify_pm__Resolution__c> listResolution =[select id,name,litify_pm__Matter__c,litify_pm__Matter__r.Name,litify_pm__Matter__r.litify_pm__Client__r.Name,litify_pm__Matter__r.litify_pm__Display_Name__c from litify_pm__Resolution__c where id=:resolutionId];
            if(listResolution.size()>0){
                currentDate = system.now().format('MM/dd/yyyy');
                matterId = listResolution[0].litify_pm__Matter__c;
                
                //consider as Billed/Pre-Billed
                List<litify_pm__Expense__c> listPrebilled = [select id,name,litify_pm__Date__c,litify_pm__Matter__c,litify_pm__Matter__r.Name,litify_pm__Amount__c, Expense_Category__c,Billing_Status__c,Resolution__c,litify_pm__ExpenseType2__c,litify_pm__ExpenseType2__r.Name ,Void__c
                                                             from litify_pm__Expense__c  where litify_pm__Matter__c=:matterId and (Billing_Status__c='Pre-Billed' OR Billing_Status__c='Billed' )  and Resolution__c= :resolutionId   order by name];
                
                List<litify_pm__Expense__c> listUnbilled = [select id,name,litify_pm__Date__c,litify_pm__Matter__c,litify_pm__Matter__r.Name,litify_pm__Amount__c,Expense_Category__c,Billing_Status__c,Resolution__c,litify_pm__ExpenseType2__c,litify_pm__ExpenseType2__r.Name,Void__c 
                                                            from litify_pm__Expense__c where litify_pm__Matter__c=:matterId and (Billing_Status__c='Unbilled' OR Billing_Status__c='') AND (Stage__c='Approved' OR Stage__c='N/A' OR Stage__c='N/A-SoftCost' OR Stage__c='N/A-File')   order by name];
                
                List<litify_pm__Expense__c> listBilled = [select id,name,litify_pm__Date__c,litify_pm__Matter__c,litify_pm__Matter__r.Name,litify_pm__Amount__c,Expense_Category__c,Billing_Status__c,Resolution__c,litify_pm__ExpenseType2__c ,litify_pm__ExpenseType2__r.Name,Void__c
                                                          from litify_pm__Expense__c where litify_pm__Matter__c=:matterId and Billing_Status__c='Billed'   and Resolution__c= :resolutionId   order by Name];
                
                
                
                AggregateResult ARPreBilled = [select sum(litify_pm__Amount__c)totalAmount from litify_pm__Expense__c where Resolution__c=:resolutionId and ( Billing_Status__c='Pre-Billed' OR Billing_Status__c='Billed' )];
                
                List<List<litify_pm__Expense__c>> listPreBilledExpenses = new List<List<litify_pm__Expense__c>>();
                
                list<litify_pm__Expense__c>prebilledTousands = new  list<litify_pm__Expense__c>();
                for(litify_pm__Expense__c exp:listPrebilled){
                    if(prebilledTousands.size()==1000){
                        listPreBilledExpenses.add(prebilledTousands);
                        prebilledTousands = new  list<litify_pm__Expense__c>();
                    }
                    else{
                        prebilledTousands.add(exp);
                    }
                }
                if(prebilledTousands.size()>0){
                    listPreBilledExpenses.add(prebilledTousands);
                }
                system.debug('listPreBilledExpenses '+listPreBilledExpenses.size());
                
                objWrapper = new resolutionExpensesWrapper(listUnbilled,listPrebilled);
                
                objWrapper.listPreBilledExpenses = listPreBilledExpenses;
                
                if(listResolution.size()>0){
                    objWrapper.objResolution = listResolution[0];
                }
                objWrapper.totalPreBilledAmount =  (decimal) ARPreBilled.get('totalAmount')==null? 0 : ((decimal) ARPreBilled.get('totalAmount')).setScale(2) ;
                
                objWrapper.balanceAmount =  ((decimal) ARPreBilled.get('totalAmount'))==null? 0 : ((decimal) ARPreBilled.get('totalAmount')).setScale(2) ;
                
                
                system.debug('objWrapper '+objWrapper);
                return objWrapper;
            }
            
        }
        catch(Exception ex){}
        return null;
    }
    
    
}