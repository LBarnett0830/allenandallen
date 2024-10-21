/*
For costRecoveryController and resolutionExpensesWrapper

Updated By: Lamar Barnett
Date      : 10/21/2024
Description: Updated TestSetup method to use TestDataFactory.
*/
@istest
public class costRecoveryControllerTest {

    @TestSetup
    static void setup(){
        ConnectApi.FormField formField = new ConnectApi.FormField();
        TestDataFactory.resolutionDamageAndLiensControllerTestSetup();
    }
    
    public static testmethod void getAllRecordsTest(){
        list<litify_pm__Resolution__c>listResolution = [select id from litify_pm__Resolution__c];        
        costRecoveryController.getAllRecords(listResolution[0].id);
    }
    
    public static testmethod void saveResolutionTest(){
        test.startTest();
        list<litify_pm__Resolution__c>listResolution = [select id from litify_pm__Resolution__c];  
        List<litify_pm__Expense__c> listExp = [select id,name,litify_pm__Date__c,litify_pm__Matter__c,litify_pm__Matter__r.Name,litify_pm__Amount__c,Amount_after_Reductions__c, Expense_Category__c,Billing_Status__c,Resolution__c,litify_pm__ExpenseType2__c,litify_pm__ExpenseType2__r.Name ,Void__c
                                               from litify_pm__Expense__c    order by name];
        listExp[1].Billing_Status__c='Pre-Billed';  
        update  listExp[1];
        resolutionExpensesWrapper objWrp = new resolutionExpensesWrapper();
        objWrp.billedAndPreBilledExpenses = new list<litify_pm__Expense__c>{listExp[0],listExp[2]};
        objWrp.unbilledExpenses = new list<litify_pm__Expense__c>{listExp[1]};
        costRecoveryController.saveResolution(listResolution[0].id,objWrp);
        
        test.stopTest();
    }
    
    public static testmethod void saveResolutionAndPdfTest(){
        test.startTest();
        list<litify_pm__Resolution__c>listResolution = [select id,name from litify_pm__Resolution__c];  
        List<litify_pm__Expense__c> listExp = [select id,name,litify_pm__Date__c,litify_pm__Matter__c,litify_pm__Matter__r.Name,litify_pm__Amount__c,Amount_after_Reductions__c, Expense_Category__c,Billing_Status__c,Resolution__c,litify_pm__ExpenseType2__c,litify_pm__ExpenseType2__r.Name ,Void__c
                                               from litify_pm__Expense__c  ];
        listExp[1].Billing_Status__c='Pre-Billed';  
        update  listExp[1];
        resolutionExpensesWrapper objWrp = new resolutionExpensesWrapper();
        objWrp.billedAndPreBilledExpenses = new list<litify_pm__Expense__c>{listExp[0],listExp[2]};
        objWrp.unbilledExpenses = new list<litify_pm__Expense__c>{listExp[1]};
        costRecoveryController.saveResolutionAndPdf(listResolution[0].id,objWrp);
        
        test.stopTest();
    }
    
    public static testmethod void attchPdfTest(){
        list<litify_pm__Resolution__c>listResolution = [select id,name from litify_pm__Resolution__c];        
        costRecoveryController.attchPdf(listResolution[0].id);
    }
    public static testmethod void savePdfTest(){
        list<litify_pm__Resolution__c>listResolution = [select id,name from litify_pm__Resolution__c];        
        costRecoveryController.savePdf(listResolution[0].id);
    }
    public static testmethod void resolutionExpensesWrapperTest(){
        resolutionExpensesWrapper objWrp = new resolutionExpensesWrapper();
        decimal noOfBilled= objWrp.noOfBilled;
        decimal noOfPreBilledWriteOff= objWrp.noOfPreBilledWriteOff;
        decimal noOfUnBilledWriteOff= objWrp.noOfUnBilledWriteOff;
        decimal writeOffAmount= objWrp.writeOffAmount;
        decimal balanceAmount= objWrp.balanceAmount;
        decimal billedWriteOffAmount= objWrp.billedWriteOffAmount;
    }
}