public class payableTriggerHandler {
    
    public static List<AcctSeed__Account_Payable__c> newList {get; set;}
    public static List<AcctSeed__Account_Payable__c> oldList {get; set;}
    public static Map<Id, AcctSeed__Account_Payable__c> newMap {get; set;}
    public static Map<Id, AcctSeed__Account_Payable__c> oldMap {get; set;}
    
    public static Boolean hasFiredFromExpenseTrigger = false;
    
    public static void beforeDelete(list<AcctSeed__Account_Payable__c>newRecords){
        try{
            system.debug('newRecords '+newRecords);
            if(!hasFiredFromExpenseTrigger){
                
                set<id>expenseIds = new set<id>();
                for(AcctSeed__Account_Payable_Line__c  payableLine:[select Expense__c,AcctSeed__Account_Payable__r.AcctSeed__Status__c from  AcctSeed__Account_Payable_Line__c where AcctSeed__Account_Payable__c in:newRecords]){
                    expenseIds.add(payableLine.Expense__c);
                }
                if(expenseIds.size()>0){
                    List<litify_pm__Expense__c>listExpense=  [select id  from litify_pm__Expense__c where id in:expenseIds];
                    /*expenseTriggerHandler.hasFiredFromPayableTrigger=true;*/
                    delete listExpense;
                }
            }
        }
        catch(Exception ex){}
        
        
    }
    
    public static void afterUpdateOperation(){
        try{
            Set<Id> payableIdSet = new Set<Id>();
            
            for(AcctSeed__Account_Payable__c  payableRec : newList){
                if(payableRec.AcctSeed__Status__c!='Posted' && (payableRec.AcctSeed__Vendor__c != oldMap.get(payableRec.Id).AcctSeed__Vendor__c || payableRec.AcctSeed__Payee_Reference__c!=oldMap.get(payableRec.Id).AcctSeed__Payee_Reference__c || payableRec.AcctSeed__Date__c!=oldMap.get(payableRec.Id).AcctSeed__Date__c))
                    payableIdSet.add(payableRec.Id);
            }
            
            if(payableIdSet.size() > 0){
                List<litify_pm__Expense__c> expenseRecList = new List<litify_pm__Expense__c>();
                List<AcctSeed__Account_Payable_Line__c> payableLineRecList = [Select Id,AcctSeed__Account_Payable__c, AcctSeed__Account_Payable__r.AcctSeed__Vendor__c,AcctSeed__Account_Payable__r.AcctSeed__Payee_Reference__c ,AcctSeed__Account_Payable__r.AcctSeed__Date__c,
                                                                              (Select Id,Vendor__c from Expenses__r) FROM AcctSeed__Account_Payable_Line__c
                                                                              WHERE AcctSeed__Account_Payable__c IN: payableIdSet];
                for(AcctSeed__Account_Payable_Line__c paybaleLineRec : payableLineRecList){
                    for(litify_pm__Expense__c expenseRec : paybaleLineRec.Expenses__r){
                        expenseRec.Vendor__c = paybaleLineRec.AcctSeed__Account_Payable__r.AcctSeed__Vendor__c;
                        expenseRec.litify_pm__lit_Invoice__c = paybaleLineRec.AcctSeed__Account_Payable__r.AcctSeed__Payee_Reference__c ;
                         expenseRec.litify_pm__Date__c = paybaleLineRec.AcctSeed__Account_Payable__r.AcctSeed__Date__c;
                        expenseRecList.add(expenseRec);
                    }
                }
                
                if(expenseRecList.size() > 0){
                    update expenseRecList;
                }
            }
        }
        catch(Exception ex){}
        
    }
    
    public static void beforeDeleteOperation(){
        map<id,string>mapPayableWithExpenseStage = new  map<id,string>();
        set<id>payableIds = new set<id>();
        set<id>expenseIdsToBeDelete = new set<id>();
        set<id>payableIdsForExpDelete = new set<id>();
        for(AcctSeed__Account_Payable__c  payableRec : oldList){
            payableIds.add(payableRec.id);
        }
        for(AcctSeed__Account_Payable_Line__c  payableLine : [select  id,AcctSeed__Account_Payable__c,Expense__c,Expense__r.Stage__c from AcctSeed__Account_Payable_Line__c where AcctSeed__Account_Payable__c in:payableIds]){
            if(!mapPayableWithExpenseStage.containsKey(payableLine.AcctSeed__Account_Payable__c)){
                mapPayableWithExpenseStage.put(payableLine.AcctSeed__Account_Payable__c,payableLine.Expense__r.Stage__c);
            }
        }
        for(AcctSeed__Account_Payable__c  payableRec : oldList){
            if(payableRec.Origin__c == 'Litify' && !(mapPayableWithExpenseStage.get(payableRec.Id)=='Rejected' || mapPayableWithExpenseStage.get(payableRec.Id)=='In-Process' || mapPayableWithExpenseStage.get(payableRec.Id)=='Cancelled' ))
                payableRec.adderror('Payable Record having origin Litify cannot be deleted');
            
            else
                payableIdsForExpDelete.add(payableRec.Id);
        }
        
        //Delete related expense records
        if(!hasFiredFromExpenseTrigger){
            
            
            for(AcctSeed__Account_Payable_Line__c  payableLine:[select Expense__c,AcctSeed__Account_Payable__r.AcctSeed__Status__c from  AcctSeed__Account_Payable_Line__c where AcctSeed__Account_Payable__c in:payableIdsForExpDelete]){
                expenseIdsToBeDelete.add(payableLine.Expense__c);
            }
            if(expenseIdsToBeDelete.size()>0){
                List<litify_pm__Expense__c>listExpense=  [select id  from litify_pm__Expense__c where id in:expenseIdsToBeDelete];
                /*expenseTriggerHandler.hasFiredFromPayableTrigger=true;*/
                delete listExpense;
            }
        }
        
    }
}