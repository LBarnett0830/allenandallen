/*
Author: Cmentor/Sampath Suranji
Date  : 11/04/2020
Description : splitExpenseWrapper for splitExpense lightning component
*/
public class splitExpenseWrapper {
    @auraEnabled
    public decimal remainingAmount{get;set;}
    
    @auraEnabled
    public decimal amountLeft{get;set;}  
    
    @auraEnabled
    public decimal totalAmountSplit{get;set;}  
    
    @auraEnabled
    public decimal totalLineAmount{get;set;}   
    
    @auraEnabled
    public map<string,string>mapMsg{get;set;}
    
    @auraEnabled
    public litify_pm__Expense__c objExpense{get;set;}
    
    @auraEnabled
    public AcctSeed__Journal_Entry_Line__c objJELine{get;set;}
    
    @auraEnabled
    public AcctSeed__Account_Payable_Line__c objPayableLine{get;set;}
    
    @auraEnabled
    public splitExpenseLineWrapper objInvoiceLine{get;set;}
    
    @auraEnabled
    public list<splitExpenseLineWrapper> listInvoiceLines{get;set;}
    
    
    
    public class splitExpenseLineWrapper{
        
        @auraEnabled
        public string matterId{get;set;}
        @auraEnabled
        public string matterName{get;set;}
        @auraEnabled
        public decimal amount{get;set;}
        
    }
    
}