@isTest
public class CustomPayableApprovalCtrlTest {
    
    @TestSetUp
    static void TestData() {
        
        

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        List<User> userList = new List<User>();
        // 0 
        userList.add(
            new User(Alias = 'test0', Email='test0@testorg.com', 
                     EmailEncodingKey='UTF-8', LastName='TestLast0', LanguageLocaleKey='en_US', 
                     LocaleSidKey='en_US', ProfileId = p.Id, 
                     TimeZoneSidKey='America/Los_Angeles', UserName='test0@testorg1.com'
                    )
        );
        Insert userList;
        
        // Insert Department
        Department__c dep = new Department__c();
        dep.Director__c = userList[0].id;
         dep.External_ID__c='50';
        Insert dep;
        
        // —— DATA PREPARATION ——
        
        // insert 1 Account
        Account acct = new Account(
            litify_pm__Last_Name__c = 'test lName',
            Name = 'Test Account');
        insert acct;
        
        // insert 1 Accounting Period
        AcctSeed__Accounting_Period__c acctPeriod = new AcctSeed__Accounting_Period__c(
            Name = '1991-10',
            AcctSeed__Start_Date__c = Date.newinstance(1991, 10, 1),
            AcctSeed__End_Date__c = Date.newinstance(1991, 10, 31),
            AcctSeed__Status__c = 'Open');
        insert acctPeriod;
        // 1 Cash GL-Account
        
        list<AcctSeed__GL_Account__c>listGL = new  list<AcctSeed__GL_Account__c>();
        AcctSeed__GL_Account__c cashGL = new AcctSeed__GL_Account__c(
            Name = '1000-Cash',
            AcctSeed__Active__c = true,
            AcctSeed__Type__c = 'Balance Sheet',
            AcctSeed__Bank__c = true,
            AcctSeed__Sub_Type_1__c = 'Assets',
            AcctSeed__Sub_Type_2__c = 'Cash');
        listGL.add(CashGL);
        
        AcctSeed__GL_Account__c expenseGl = new AcctSeed__GL_Account__c(
            Name = '1000-Cash',
            AcctSeed__Active__c = true,
            AcctSeed__Type__c = 'Balance Sheet',
            AcctSeed__Sub_Type_1__c = 'Assets',
            Department__c = dep.id,
            AcctSeed__Sub_Type_2__c = 'Cash');
        listGL.add(expenseGl);
        
        
            
        AcctSeed__GL_Account__c objACCGL = new AcctSeed__GL_Account__c(
            Name = '1200-Client Costs Advanced',
            AcctSeed__Active__c = true,
            AcctSeed__Type__c = 'Balance Sheet',
            AcctSeed__Sub_Type_1__c = 'Assets',
            Department__c = dep.id,
            AcctSeed__Sub_Type_2__c = 'Cash');
         listGL.add(objACCGL);
        
        listGL.add(new AcctSeed__GL_Account__c(
            Name = label.Project_task_Revenue_GL_Account,
            AcctSeed__Active__c = true,
            AcctSeed__Type__c = 'Balance Sheet',
            AcctSeed__Sub_Type_1__c = 'Assets',
            Department__c = dep.id,
            AcctSeed__Sub_Type_2__c = 'Cash'));
        
        insert listGL;
        
        // insert 4 billing formats
        AcctSeed__Billing_Format__c[] PDFformats = new List<AcctSeed__Billing_Format__c>();
        PDFformats.add(
            new AcctSeed__Billing_Format__c(
                Name = 'Default Billing Product',
                AcctSeed__Visualforce_PDF_Page__c = 'BillingProductPDF',
                AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                AcctSeed__Type__c = 'Billing',
                AcctSeed__Sort_Field__c = 'Name'
            )
        );
        
        PDFformats.add(
            new AcctSeed__Billing_Format__c(
                Name = 'Default Billing Service',
                AcctSeed__Visualforce_PDF_Page__c = 'BillingServicePDF',
                AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                AcctSeed__Type__c = 'Billing',
                AcctSeed__Sort_Field__c = 'Name'
            )
        );
        
        PDFformats.add(
            new AcctSeed__Billing_Format__c (
                Name = 'Billing Outstanding Statement',
                AcctSeed__Visualforce_PDF_Page__c = 'BillingOutstandingStatementPDF',
                AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                AcctSeed__ReplyTo_Email__c = 'test3463464364646@gmail.com',
                AcctSeed__Type__c = 'Outstanding Statement'
            )
        );
        
        PDFformats.add(
            new AcctSeed__Billing_Format__c (
                Name = 'Billing Activity Statement',
                AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF',
                AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                AcctSeed__ReplyTo_Email__c = 'test3463464364646@gmail.com',
                AcctSeed__Type__c = 'Activity Statement'
            )
        );
        
        PDFformats.add(
            new AcctSeed__Billing_Format__c(
                Name = 'Default Purchase Order',
                AcctSeed__Visualforce_PDF_Page__c = 'BillingServicePDF',
                AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                AcctSeed__Type__c = 'Purchase Order',
                AcctSeed__Sort_Field__c = 'Name'
            )
        );
        
        PDFformats.add(
            new AcctSeed__Billing_Format__c(
                Name = 'Default Packing Slip',
                AcctSeed__Visualforce_PDF_Page__c = 'BillingServicePDF',
                AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                AcctSeed__Type__c = 'Packing Slip',
                AcctSeed__Sort_Field__c = 'Name'
            )
        );
        
        insert PDFformats;
        // insert 1 Ledger records
        AcctSeed__Ledger__c ledger = new AcctSeed__Ledger__c(
            Name = 'Actual',
            AcctSeed__Type__c = 'Transactional',
            AcctSeed__Default_Bank_Account__c = CashGL.id,
            AcctSeed__Default_Billing_Format__c = PDFformats[0].Id,
            AcctSeed__Billing_Outstanding_Statement_Format__c = PDFformats[2].Id,
            AcctSeed__Billing_Activity_Statement_Format__c = PDFformats[3].Id,
            AcctSeed__Default_Purchase_Order_Format__c = PDFformats[4].Id,
            AcctSeed__Default_Packing_Slip_Format__c = PDFformats[5].Id);
        insert ledger;
        
         litify_pm__Matter__c objMatter = new litify_pm__Matter__c();
        objMatter.litify_pm__Client__c = acct.id;
        insert objMatter;
        
        List<AcctSeed__Project__c> listProject = [select id from AcctSeed__Project__c];
        
         List<litify_pm__Expense_Type__c>listExpType= new  List<litify_pm__Expense_Type__c>();
        litify_pm__Expense_Type__c type1 = new litify_pm__Expense_Type__c();
        type1.Category__c = 'Hard Cost';
        listExpType.add(type1);
        
        litify_pm__Expense_Type__c type2 = new litify_pm__Expense_Type__c();
        type2.Category__c = 'Soft Cost';
        listExpType.add(type2);
        insert listExpType;
        
        
        // Create Payable RECORD
        List<AcctSeed__Account_Payable__c> payableList = new List<AcctSeed__Account_Payable__c>();
        // 0
        payableList.add(
            new AcctSeed__Account_Payable__c(
                AcctSeed__Payee_Reference__c = '1',
                AcctSeed__Vendor__c = acct.Id,
                AcctSeed__Accounting_Period__c = acctPeriod.Id,
                Expense_Type__c = 'Operating',
                AcctSeed__Ledger__c = ledger.Id
            )  
        );
        
        // 1
        payableList.add(
            new AcctSeed__Account_Payable__c(
                AcctSeed__Payee_Reference__c = '2',
                AcctSeed__Vendor__c = acct.Id,
                AcctSeed__Accounting_Period__c = acctPeriod.Id,
                Expense_Type__c = 'Operating',
                AcctSeed__Ledger__c = ledger.Id
            )  
        );
        
        // 2
        payableList.add(
            new AcctSeed__Account_Payable__c(
                AcctSeed__Payee_Reference__c = '3',
                AcctSeed__Vendor__c = acct.Id,
                AcctSeed__Accounting_Period__c = acctPeriod.Id,
                Expense_Type__c = 'Matter',
                AcctSeed__Ledger__c = ledger.Id
            )  
        );
         // 3
        payableList.add(
            new AcctSeed__Account_Payable__c(
                AcctSeed__Payee_Reference__c = '4',
                AcctSeed__Vendor__c = acct.Id,
                AcctSeed__Accounting_Period__c = acctPeriod.Id,
                Expense_Type__c = 'Operating',
                AcctSeed__Ledger__c = ledger.Id
            )  
        );
        
        insert payableList;
        
        
        AcctSeed__Accounting_Variable__c  var2 = new AcctSeed__Accounting_Variable__c();
        var2.Name = 'Var 2';
        var2.AcctSeed__Type__c = 'GL Account Variable 2';
        Insert var2;
        
        AcctSeed__Accounting_Variable__c  var3 = new AcctSeed__Accounting_Variable__c();
        var3.Name = 'Var 3';
        var3.AcctSeed__Type__c = 'GL Account Variable 3';
        Insert var3;
        
        
        List<AcctSeed__Account_Payable_Line__c> payLineList = new List<AcctSeed__Account_Payable_Line__c>();
        //0
        payLineList.add(
            new AcctSeed__Account_Payable_Line__c(
                AcctSeed__Amount__c = 1500,
                AcctSeed__Account_Payable__c = payableList[0].id,
                AcctSeed__Expense_GL_Account__c = expenseGl.id,
                AcctSeed__GL_Account_Variable_2__c = var2.id,
                AcctSeed__GL_Account_Variable_3__c = var3.id
            )
        );
        
        //1
        payLineList.add(
            new AcctSeed__Account_Payable_Line__c(
                AcctSeed__Amount__c = 2500,
                AcctSeed__Account_Payable__c = payableList[1].id,
                AcctSeed__Expense_GL_Account__c = expenseGl.id,
                AcctSeed__GL_Account_Variable_2__c = var2.id,
                AcctSeed__GL_Account_Variable_3__c = var3.id
            )
        );
        //2
        payLineList.add(
            new AcctSeed__Account_Payable_Line__c(
                AcctSeed__Amount__c = 3000,
                AcctSeed__Account_Payable__c = payableList[2].id,
                AcctSeed__Expense_GL_Account__c = objACCGL.id,
                AcctSeed__GL_Account_Variable_2__c = var2.id,
                AcctSeed__GL_Account_Variable_3__c = var3.id,
                AcctSeed__Project__c = listProject[0].Id,
                Expense_Type__c = type1.Id
            )
        );
        //3
        payLineList.add(
            new AcctSeed__Account_Payable_Line__c(
                AcctSeed__Amount__c = 100,
                AcctSeed__Account_Payable__c = payableList[3].id,
                AcctSeed__Expense_GL_Account__c = objACCGL.id,
                AcctSeed__GL_Account_Variable_2__c = var2.id,
                AcctSeed__GL_Account_Variable_3__c = var3.id
                
            )
        );
        Insert payLineList;
        
    }
    
    @isTest
    static void submit_1() {
        List<AcctSeed__Account_Payable__c> payableList = [SELECT Id FROM AcctSeed__Account_Payable__c WHERE AcctSeed__Total__c < 500];
        
        Test.StartTest(); 
        ApexPages.currentPage().getParameters().put('id', String.valueOf(payableList[0].Id));
        CustomPayableApprovalCtrl  ctrl = new CustomPayableApprovalCtrl();
        ctrl.submit();
        ctrl.redirectToDetail();
        Test.StopTest();
    }
    
    @isTest
    static void submit_2() {
        List<AcctSeed__Account_Payable__c> payableList = [SELECT Id FROM AcctSeed__Account_Payable__c WHERE AcctSeed__Total__c = 1500];
        
        Test.StartTest(); 
        ApexPages.currentPage().getParameters().put('id', String.valueOf(payableList[0].Id));
        CustomPayableApprovalCtrl  ctrl = new CustomPayableApprovalCtrl();
        ctrl.submit();
        ctrl.redirectToDetail();
        Test.StopTest();
    }
    
    @isTest
    static void submit_3() {
        List<AcctSeed__Account_Payable__c> payableList = [SELECT Id FROM AcctSeed__Account_Payable__c WHERE AcctSeed__Total__c = 2500];
        
        Test.StartTest(); 
        ApexPages.currentPage().getParameters().put('id', String.valueOf(payableList[0].Id));
        CustomPayableApprovalCtrl  ctrl = new CustomPayableApprovalCtrl();
        ctrl.submit();
        ctrl.redirectToDetail();
        Test.StopTest();
    }
     @isTest
    static void submit_4() {
        List<AcctSeed__Account_Payable__c> payableList = [SELECT Id FROM AcctSeed__Account_Payable__c WHERE AcctSeed__Total__c = 3000];
        
        Test.StartTest(); 
        ApexPages.currentPage().getParameters().put('id', String.valueOf(payableList[0].Id));
        CustomPayableApprovalCtrl  ctrl = new CustomPayableApprovalCtrl();
        ctrl.submit();
        
        payableList[0].Origin__c='AP';
        update payableList[0];
        
        /*List<AcctSeed__Account_Payable_Line__c>listPayableLine = [select id,AcctSeed__Expense_GL_Account__c from AcctSeed__Account_Payable_Line__c where AcctSeed__Account_Payable__c=:payableList[0].id];
        listPayableLine[0].AcctSeed__Expense_GL_Account__c=null;
        update listPayableLine[0];*/
        
        ApexPages.currentPage().getParameters().put('id', String.valueOf(payableList[0].Id));
        CustomPayableApprovalCtrl  objCon = new CustomPayableApprovalCtrl();
        objCon.submit();
        
        ApexPages.currentPage().getParameters().put('id', String.valueOf(payableList[0].Id));
        CustomPayableApprovalCtrl  objCon1 = new CustomPayableApprovalCtrl();
        objCon1.submit();
        
        Test.StopTest();
    }
    
}