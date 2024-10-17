@isTest
public class closingStatementPdfControllerTest {
    @isTest
    static void closingStatementPdf_Test1(){
        test.startTest();
        Account ObjAccount = new Account();        
        ObjAccount.Name = 'Test Account For Project';
        ObjAccount.litify_pm__Last_Name__c ='test name';
        ObjAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Litify Individual').getRecordTypeId();
        ObjAccount.AcctSeed__Accounting_Active__c = True;
        ObjAccount.AcctSeed__Accounting_Type__c = 'Customer and Vendor';
        ObjAccount.Matter_Vendor__c =true;
        insert ObjAccount;
        
        litify_pm__Matter__c objMatter = new litify_pm__Matter__c();
        objMatter.litify_pm__Client__c = ObjAccount.Id;
        objMatter.Invisible_Record__c = true;
        insert objMatter;
        
        
        litify_pm__Resolution__c Resolution = new litify_pm__Resolution__c();
        Resolution.litify_pm__Matter__c =objMatter.id;
        // Resolution.AAAA_Fee_Rate__c =50;
        Resolution.litify_pm__Settlement_Verdict_Amount__c=30;
        insert Resolution;
        
/*   Referral_Fee__c referral = new Referral_Fee__c();
referral.Account__c =ObjAccount.Id;
referral.Amount__c =10;
referral.Effective_Fee_Amount__c =7;
referral.Comments__c ='Testing Comment';
referral.Resolution__c =Resolution.id;
insert referral;
*/
        
        litify_pm__Expense_Type__c expensetype =new litify_pm__Expense_Type__c();
        expensetype.Category__c ='Soft Cost';
        expensetype.Name ='twest';
        expensetype.Merge_on_Statement__c =false;
        insert expensetype;
        
        litify_pm__Expense__c objExpense = new litify_pm__Expense__c();
        objExpense.litify_pm__Date__c = system.today();
        objExpense.litify_pm__Amount__c = 50;
        objExpense.litify_pm__Matter__c = objMatter.Id;
        objExpense.Billing_Status__c = 'Unbilled';  
        objExpense.Stage__c = 'In-Process';
        objExpense.Resolution__c =Resolution.id;
        objExpense.litify_pm__ExpenseType2__c =expensetype.id;
        objExpense.Void__c =false;
        objExpense.Vendor__c =ObjAccount.Id;
        insert objExpense; 
        
        objExpense.Billing_Status__c ='Billed';
        update objExpense;
        
        PageReference pageRef = Page.closingStatementPdf;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',Resolution.Id);
        //ApexPages.currentPage().getParameters().put('type',);
        
        ApexPages.StandardController closingStatementController = new ApexPages.StandardController(Resolution);        
        closingStatementPdfController controller = new closingStatementPdfController();
        controller.getDetails(Resolution.id);
        
        test.stopTest();
    }
    
    @isTest
    static void closingStatementPdf_Test2(){
        test.startTest();
        Account ObjAccount = new Account();        
        ObjAccount.Name = 'Test Account For Project';
        ObjAccount.litify_pm__Last_Name__c ='test name';
        ObjAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Litify Individual').getRecordTypeId();
        ObjAccount.AcctSeed__Accounting_Active__c = True;
        ObjAccount.AcctSeed__Accounting_Type__c = 'Customer and Vendor';
        ObjAccount.Matter_Vendor__c =true;
        insert ObjAccount;
        
        litify_pm__Matter__c objMatter = new litify_pm__Matter__c();
        objMatter.litify_pm__Client__c = ObjAccount.Id;
        objMatter.Invisible_Record__c = true;
        insert objMatter;
        
        
        litify_pm__Resolution__c Resolution = new litify_pm__Resolution__c();
        Resolution.litify_pm__Matter__c =objMatter.id;
        // Resolution.AAAA_Fee_Rate__c =50;
        Resolution.litify_pm__Settlement_Verdict_Amount__c=30;
        insert Resolution;
        
        /*   Referral_Fee__c referral = new Referral_Fee__c();
referral.Account__c =ObjAccount.Id;
referral.Amount__c =10;
referral.Effective_Fee_Amount__c =7;
referral.Comments__c ='Testing Comment';
referral.Resolution__c =Resolution.id;
insert referral;
*/
        
        litify_pm__Expense_Type__c expensetype =new litify_pm__Expense_Type__c();
        expensetype.Category__c ='Soft Cost';
        expensetype.Name ='twest';
        expensetype.Merge_on_Statement__c =true;
        insert expensetype;
        
        litify_pm__Expense__c objExpense = new litify_pm__Expense__c();
        objExpense.litify_pm__Date__c = system.today();
        objExpense.litify_pm__Amount__c = 50;
        objExpense.litify_pm__Matter__c = objMatter.Id;
        objExpense.Billing_Status__c = 'Unbilled';  
        objExpense.Stage__c = 'In-Process';
        objExpense.Resolution__c =Resolution.id;
        objExpense.litify_pm__ExpenseType2__c =expensetype.id;
        objExpense.Void__c =false;
        objExpense.Vendor__c =ObjAccount.Id;
        insert objExpense; 
        
        objExpense.Billing_Status__c ='Billed';
        update objExpense;
        
        PageReference pageRef = Page.closingStatementPdf;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',Resolution.Id);
        ApexPages.currentPage().getParameters().put('type','Rough');
        
        ApexPages.StandardController closingStatementController = new ApexPages.StandardController(Resolution);        
        closingStatementPdfController controller = new closingStatementPdfController();
        controller.getDetails(Resolution.id);
        
        test.stopTest();
    }
    @isTest
    static void closingStatementPdf_Test3(){
        test.startTest();
        Account ObjAccount = new Account();        
        ObjAccount.Name = 'Test Account For Project';
        ObjAccount.litify_pm__Last_Name__c ='test name';
        ObjAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Litify Individual').getRecordTypeId();
        ObjAccount.AcctSeed__Accounting_Active__c = True;
        ObjAccount.AcctSeed__Accounting_Type__c = 'Customer and Vendor';
        ObjAccount.Matter_Vendor__c =true;
        insert ObjAccount;
        
        litify_pm__Matter__c objMatter = new litify_pm__Matter__c();
        objMatter.litify_pm__Client__c = ObjAccount.Id;
        objMatter.Invisible_Record__c = true;
        insert objMatter;
        
        
        litify_pm__Resolution__c Resolution = new litify_pm__Resolution__c();
        Resolution.litify_pm__Matter__c =objMatter.id;
        // Resolution.AAAA_Fee_Rate__c =50;
        Resolution.litify_pm__Settlement_Verdict_Amount__c=30;
        insert Resolution;
        
        /*   Referral_Fee__c referral = new Referral_Fee__c();
referral.Account__c =ObjAccount.Id;
referral.Amount__c =10;
referral.Effective_Fee_Amount__c =7;
referral.Comments__c ='Testing Comment';
referral.Resolution__c =Resolution.id;
insert referral;
*/
        litify_pm__Role__c role =new litify_pm__Role__c();
        role.RecordTypeId = Schema.SObjectType.litify_pm__Role__c.getRecordTypeInfosByName().get('Matter Role').getRecordTypeId();
        role.litify_pm__Party__c =ObjAccount.Id;
        role.litify_pm__Role__c ='Court';
        role.litify_pm__Matter__c=objMatter.id;
        insert role;
        
        litify_pm__Lien__c lien = new litify_pm__Lien__c();
        lien.Resolution__c=Resolution.id;
        lien.litify_pm__lit_Comments__c ='Test Comment';
        lien.litify_pm__lit_Amount__c =10;
        lien.litify_pm__lit_Reductions__c = 5.7;
        lien.Date_Issued__c =system.today();
        lien.litify_pm__lit_Matter__c =objMatter.id;
        lien.Payee_Party__c = objAccount.Id;
        //lien.litify_pm__lit_Payee__c = role.id;
        lien.Type__c ='Lien';
        insert lien;
        
        litify_pm__Damage__c DamageObj = new litify_pm__Damage__c();
        //DamageObj.Resolution__c =Resolution.id;
        DamageObj.litify_pm__Amount_Billed__c =10;
        DamageObj.litify_pm__Amount_Paid__c =7;
        DamageObj.litify_pm__Provider__c = role.id;
        DamageObj.litify_pm__Matter__c = objMatter.id;            
        insert DamageObj;  
        DamageObj.Resolution__c =Resolution.id;
        update  DamageObj;
        
        litify_pm__Expense_Type__c expensetype =new litify_pm__Expense_Type__c();
        expensetype.Category__c ='Soft Cost';
        expensetype.Name ='twest';
        expensetype.Merge_on_Statement__c =false;
        insert expensetype;
        
        litify_pm__Expense__c objExpense = new litify_pm__Expense__c();
        objExpense.litify_pm__Date__c = system.today();
        objExpense.litify_pm__Amount__c = 50;
        objExpense.litify_pm__Matter__c = objMatter.Id;
        objExpense.Billing_Status__c = 'Unbilled';  
        objExpense.Stage__c = 'In-Process';
        objExpense.Resolution__c =Resolution.id;
        objExpense.litify_pm__ExpenseType2__c =expensetype.id;
        objExpense.Void__c =false;
        objExpense.Vendor__c =ObjAccount.Id;
        insert objExpense; 
        
        objExpense.Billing_Status__c ='Billed';
        update objExpense;
        
        PageReference pageRef = Page.closingStatementPdf;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',Resolution.Id);
        ApexPages.currentPage().getParameters().put('type','Final');
        
        //ApexPages.StandardController closingStatementController = new ApexPages.StandardController(Resolution);        
        closingStatementPdfController controller = new closingStatementPdfController();
        controller.getDetails(Resolution.id);
        
        test.stopTest();
    }
       
}