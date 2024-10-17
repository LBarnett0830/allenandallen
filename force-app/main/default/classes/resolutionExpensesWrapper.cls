public class resolutionExpensesWrapper {
    @AuraEnabled
    public List<litify_pm__Expense__c> unbilledExpenses{get;set;}
    
    @AuraEnabled
    public List<litify_pm__Expense__c> preBilledExpenses{get;set;}  
    
    @AuraEnabled
    public List<litify_pm__Expense__c> billedAndPreBilledExpenses{get;set;}  
    
    
    @AuraEnabled
    public List<litify_pm__Expense__c> billedExpenses{get;set;}
    
    @AuraEnabled
    public List<List<litify_pm__Expense__c>> listPreBilledExpenses{get;set;} 
    
    
    @AuraEnabled
    public litify_pm__Resolution__c objResolution{get;set;}
    
    @AuraEnabled
    public List<litify_pm__Expense__c> emptyExpenses{get;set;}    
    
    
    @AuraEnabled
    public double totalPreBilledAmount{get;set;}
    
    @AuraEnabled
    public double totalBilledAmount{get;set;}
    
    @AuraEnabled
    public double totalVoidedAmount{get;set;}
    
     @AuraEnabled
    public double totalDamagedAmount{get;set;}
    
    @AuraEnabled
    public decimal noOfPreBilled{get;set;}
    
    @AuraEnabled
    public decimal noOfBilled{get;set;}
    
    @AuraEnabled
    public decimal noOfUnBilled{get;set;}
    
    @AuraEnabled
    public decimal noOfPreBilledWriteOff{get;set;}    
    
    
    @AuraEnabled
    public decimal noOfUnBilledWriteOff{get;set;}
    
    @AuraEnabled
    public decimal noOfVoidUnBilled{get;set;}
    
    @AuraEnabled
    public decimal noOfVoidBilled{get;set;}
    
    @AuraEnabled
    public decimal noOfUnapproved{get;set;}
    
    @AuraEnabled
    public decimal writeOffAmount{get;set;}
    
    @AuraEnabled
    public decimal billedWriteOffAmount{get;set;}
    
    @AuraEnabled
    public double balanceAmount{get;set;}
    
   
    
   /* public resolutionExpensesWrapper(List<litify_pm__Expense__c> unbilledExpenses,List<litify_pm__Expense__c> preBilledExpenses){
        this.unbilledExpenses = unbilledExpenses;
        this.preBilledExpenses = preBilledExpenses;
        noOfPreBilled = preBilledExpenses.size();
        //  noOfBilled = BilledExpenses.size();
        noOfUnBilled = unbilledExpenses.size();
        
        this.emptyExpenses = new List<litify_pm__Expense__c> ();
        
        
    }*/
    //
    
}