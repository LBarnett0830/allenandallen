/**
 * Created by barne on 10/21/2024.
 */

@IsTest
private class resolutionExpensesWrapperTest {
    @IsTest
    static void testBehavior() {
        Decimal defaultDecimal = 0.0;
        resolutionExpensesWrapper wrapper = new resolutionExpensesWrapper();
        wrapper.expensesOnOtherResolutions = new List<litify_pm__Expense__c>();
        wrapper.noOfUnBilledWriteOff = defaultDecimal;
        wrapper.noOfUnBilled = defaultDecimal;
        wrapper.noOfBilled = defaultDecimal;
        wrapper.noOfVoidBilled = defaultDecimal;
        wrapper.noOfUnBilledWriteOff = defaultDecimal;
        wrapper.noOfPreBilledWriteOff = defaultDecimal;
        wrapper.billedWriteOffAmount = defaultDecimal;
        wrapper.writeOffAmount = defaultDecimal;
        wrapper.billedAndPreBilledExpenses = new List<litify_pm__Expense__c>();
        wrapper.billedExpenses = new List<litify_pm__Expense__c>();
        wrapper.listPreBilledExpenses = new List<List<litify_pm__Expense__c>>();
        wrapper.objResolution = new litify_pm__Resolution__c();
        wrapper.emptyExpenses = new List<litify_pm__Expense__c>();
        wrapper.unbilledExpenses = new List<litify_pm__Expense__c>();
        wrapper.preBilledExpenses = new List<litify_pm__Expense__c>();
        wrapper.noOfPreBilled = defaultDecimal;
        wrapper.balanceAmount = defaultDecimal;
        wrapper.noOfUnapproved = defaultDecimal;
        wrapper.noOfVoidUnBilled = defaultDecimal;
        wrapper.totalDamagedAmount = 00.00;
        wrapper.totalVoidedAmount = 00.00;
        wrapper.totalBilledAmount = 00.00;
        wrapper.totalPreBilledAmount = 00.00;


    }
}