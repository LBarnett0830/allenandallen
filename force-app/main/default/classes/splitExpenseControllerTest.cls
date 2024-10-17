/*
Author: Cmentor/Sampath Suranji
Date  : 11/12/2020
Description : test coverage for splitExpenseController and splitExpenseWrapper

Updated by:Impak/Dave Williams
Date: 12/22/2021
Description:  Added invoice number to the new expenses created to stop tripping validation rule
*/
@isTest
public class splitExpenseControllerTest {
    
    
    @testSetup static void unitTestSetup(){
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
        Department__c dep = new Department__c();
        dep.Director__c = userList[0].id;
        Insert dep;
        
        list<AcctSeed__GL_Account__c>listGL = new list<AcctSeed__GL_Account__c>();
        AcctSeed__GL_Account__c objACCGL = new AcctSeed__GL_Account__c(
            Name = '1201-Client Costs Advanced',
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
        
        listGL.add(
            new AcctSeed__GL_Account__c(
                Name = '1002-Cash',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Bank__c = true,
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Cash'
            )
        );
        
        Firm_Ledger_COS_Fee_Revenue_GL_Account__c obj = new Firm_Ledger_COS_Fee_Revenue_GL_Account__c(Fee_Revenue_GL_Account__c='4000-Fee Income',Hard_Cost_Advanced__c='1200-Client Costs Advanced',Soft_Cost_Reimbursed__c='4500-Litigation Exp Reimbursed',Trust_Receivable_GL_Account__c='1151-Trust Receivable',Open_case_expenses_GL_Account__c='1000-Cash - Operating');
        obj.name='AAA';
        insert obj;
        /*List<Firm_Ledger_COS_Fee_Revenue_GL_Account__c> listCOSGLCustomSetting=[select Fee_Revenue_GL_Account__c,Hard_Cost_Advanced__c,Soft_Cost_Reimbursed__c,Trust_Receivable_GL_Account__c,Open_case_expenses_GL_Account__c
from Firm_Ledger_COS_Fee_Revenue_GL_Account__c];
*/
        
        listGL.add(new AcctSeed__GL_Account__c(
            Name = obj.Fee_Revenue_GL_Account__c,
            AcctSeed__Active__c = true,
            AcctSeed__Type__c = 'Balance Sheet',
            AcctSeed__Sub_Type_1__c = 'Assets',
            Department__c = dep.id,
            AcctSeed__Sub_Type_2__c = 'Cash'));
        
        listGL.add(new AcctSeed__GL_Account__c(
            Name = obj.Hard_Cost_Advanced__c,
            AcctSeed__Active__c = true,
            AcctSeed__Type__c = 'Balance Sheet',
            AcctSeed__Sub_Type_1__c = 'Assets',
            Department__c = dep.id,
            AcctSeed__Sub_Type_2__c = 'Cash'));
        
        listGL.add(new AcctSeed__GL_Account__c(
            Name = obj.Soft_Cost_Reimbursed__c,
            AcctSeed__Active__c = true,
            AcctSeed__Type__c = 'Balance Sheet',
            AcctSeed__Sub_Type_1__c = 'Assets',
            Department__c = dep.id,
            AcctSeed__Sub_Type_2__c = 'Cash'));
        
        listGL.add(new AcctSeed__GL_Account__c(
            Name = obj.Trust_Receivable_GL_Account__c,
            AcctSeed__Active__c = true,
            AcctSeed__Type__c = 'Balance Sheet',
            AcctSeed__Sub_Type_1__c = 'Assets',
            Department__c = dep.id,
            AcctSeed__Sub_Type_2__c = 'Cash'));
        
        listGL.add(new AcctSeed__GL_Account__c(
            Name = obj.Open_case_expenses_GL_Account__c,
            AcctSeed__Active__c = true,
            AcctSeed__Type__c = 'Balance Sheet',
            AcctSeed__Sub_Type_1__c = 'Assets',
            Department__c = dep.id,
            AcctSeed__Sub_Type_2__c = 'Cash'));
        
        
        insert listGL;
        
        
        
        List<AcctSeed__GL_Account__c> glAccountsExpense = new List<AcctSeed__GL_Account__c>();
        
        // 0
        glAccountsExpense.add(
            new AcctSeed__GL_Account__c(
                Name = '6050-Travel Expenses',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Expense',
                AcctSeed__Expense_Report_Name__c = 'Travel Expenses',
                AcctSeed__Billing_Description__c = 'Travel Expenses',
                AcctSeed__TM_Revenue_Conversion__c = listGL[2].Id,
                AcctSeed__Sub_Type_1__c = 'Sales & Marketing',
                AcctSeed__Sub_Type_2__c = 'Sales Travel'
            )
        );
        
        // 1
        glAccountsExpense.add(
            new AcctSeed__GL_Account__c(
                Name = '6060-Meals and Entertainment',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Expense',
                AcctSeed__Used_In_Expense_Reports__c = true,
                AcctSeed__Expense_Report_Name__c = 'Meals and Entertainment',
                AcctSeed__Billing_Description__c = 'Meals and Entertainment',
                AcctSeed__TM_Revenue_Conversion__c = listGL[2].Id,
                AcctSeed__Sub_Type_1__c = 'Sales & Marketing',
                AcctSeed__Sub_Type_2__c = 'Sales Travel'  
            )
        );
        
        // 2
        glAccountsExpense.add(
            new AcctSeed__GL_Account__c(
                Name = '6070-Mileage',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Expense',
                AcctSeed__Used_In_Expense_Reports__c = true,
                AcctSeed__Expense_Report_Name__c = 'Mileage',
                AcctSeed__Billing_Description__c = 'Mileage',
                AcctSeed__Mileage_Account__c = true,
                AcctSeed__Mileage_Rate__c = .52,
                AcctSeed__TM_Revenue_Conversion__c = listGL[2].Id,
                AcctSeed__Sub_Type_1__c = 'Sales & Marketing',
                AcctSeed__Sub_Type_2__c = 'Sales Travel'          
            )
        );
        
        insert glAccountsExpense;
        listGL.addAll(glAccountsExpense);
        
        
        
        List<AcctSeed__Billing_Format__c> billingFormats = new List<AcctSeed__Billing_Format__c>();
        billingFormats.add(
            new AcctSeed__Billing_Format__c(
                Name = 'Default Billing Product',
                AcctSeed__Visualforce_PDF_Page__c = 'BillingServiceModernPDF',
                AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                AcctSeed__Type__c = 'Billing',
                AcctSeed__Sort_Field__c = 'Name'
            )
        );  
        
        billingFormats.add(
            new AcctSeed__Billing_Format__c(
                Name = 'Default Billing Service',
                AcctSeed__Visualforce_PDF_Page__c = 'BillingServiceModernPDF',
                AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                AcctSeed__Type__c = 'Billing',
                AcctSeed__Sort_Field__c = 'Name'
            )
        );      
        
        billingFormats.add(
            new AcctSeed__Billing_Format__c (
                Name = 'Billing Outstanding Statment',
                AcctSeed__Visualforce_PDF_Page__c = 'BillingServiceModernPDF',
                AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                AcctSeed__ReplyTo_Email__c = 'test3463464364646@gmail.com',
                AcctSeed__Type__c = 'Outstanding Statement'
            )
        );    
        
        billingFormats.add(
            new AcctSeed__Billing_Format__c (
                Name = 'Billing Activity Statment',
                AcctSeed__Visualforce_PDF_Page__c = 'BillingServiceModernPDF',
                AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                AcctSeed__ReplyTo_Email__c = 'test3463464364646@gmail.com',
                AcctSeed__Type__c = 'Activity Statement'  
            )
        );
        
        billingFormats.add(
            new AcctSeed__Billing_Format__c (
                Name = 'Default Packing Slip',
                AcctSeed__Visualforce_PDF_Page__c = 'BillingServiceModernPDF',
                AcctSeed__Default_Email_Template__c = 'Billing_Email_Template',
                AcctSeed__ReplyTo_Email__c = 'test3463464364646@gmail.com',
                AcctSeed__Type__c = 'Packing Slip'  
            )
        );
        
        billingFormats.add(
            new AcctSeed__Billing_Format__c (
                Name = 'Default Purchase Orde',
                AcctSeed__Visualforce_PDF_Page__c = 'BillingServiceModernPDF',
                AcctSeed__Default_Email_Template__c = 'Billing_Email_Template',
                AcctSeed__ReplyTo_Email__c = 'test3463464364646@gmail.com',
                AcctSeed__Type__c = 'Purchase Order'  
            )
        );
        
        insert billingFormats;
        
        List<AcctSeed__Ledger__c> ledgers = new List<AcctSeed__Ledger__c>();
        
        ledgers.add(
            new AcctSeed__Ledger__c(
                Name = 'Actual',
                AcctSeed__Type__c = 'Transactional',
                AcctSeed__Default_Bank_Account__c = listGL[2].Id,
                AcctSeed__Default_Billing_Format__c = billingFormats[0].Id,
                AcctSeed__Billing_Outstanding_Statement_Format__c = billingFormats[2].Id,
                AcctSeed__Billing_Activity_Statement_Format__c = billingFormats[3].Id,
                AcctSeed__Default_Purchase_Order_Format__c = billingFormats[5].id,
                AcctSeed__Default_Packing_Slip_Format__c  = billingFormats[4].id
            )
        );
        
        
        ledgers.add(
            new AcctSeed__Ledger__c(
                Name = 'Budget',
                AcctSeed__Type__c = 'Budget',
                AcctSeed__Default_Bank_Account__c = listGL[2].Id,
                AcctSeed__Default_Billing_Format__c = billingFormats[0].Id,
                AcctSeed__Billing_Outstanding_Statement_Format__c = billingFormats[2].Id,
                AcctSeed__Billing_Activity_Statement_Format__c = billingFormats[3].Id,
                AcctSeed__Default_Purchase_Order_Format__c = billingFormats[5].id,
                AcctSeed__Default_Packing_Slip_Format__c  = billingFormats[4].id
            )
        );
        
        insert ledgers;
        
        List<AcctSeed__Accounting_Period__c> lstAccountingPeriod = new List<AcctSeed__Accounting_Period__c>();
        Date currentDate = Date.newInstance(2020, 9,1);
        
        for(Integer i = 0; i < 36; i++){
            
            AcctSeed__Accounting_Period__c objAccountingPeriod = new AcctSeed__Accounting_Period__c();
            
            objAccountingPeriod.AcctSeed__Start_Date__c = currentDate.addMonths(i);
            objAccountingPeriod.AcctSeed__End_Date__c = objAccountingPeriod.AcctSeed__Start_Date__c.addMonths(1).toStartOfMonth() - 1;
            objAccountingPeriod.Name = objAccountingPeriod.AcctSeed__Start_Date__c.year() + '-' + (string.valueOf(objAccountingPeriod.AcctSeed__Start_Date__c.month()).length() == 1?'0':'') + objAccountingPeriod.AcctSeed__Start_Date__c.month();
            lstAccountingPeriod.add(objAccountingPeriod);
        }
        
        insert lstAccountingPeriod;
        
        List<AcctSeed__Accounting_Settings__c> settings = new List<AcctSeed__Accounting_Settings__c>();
        
        Account objAcc = new Account();
        objAcc.name='test';
        objAcc.litify_pm__Last_Name__c = 'test lName';
        objAcc.AcctSeed__Accounting_Active__c=True;
        objAcc.AcctSeed__Accounting_Type__c = 'Vendor';
        objAcc.Matter_Vendor__c =true;
        insert objAcc;
        
        litify_pm__Matter__c matter = new litify_pm__Matter__c();
        matter.litify_pm__Client__c = objAcc.id;
        insert matter;
        
        litify_pm__Expense_Type__c type = new litify_pm__Expense_Type__c();
        type.Category__c = 'Hard Cost';
        insert type;
        
        litify_pm__Expense_Type__c type2 = new litify_pm__Expense_Type__c();
        type2.Category__c = 'Soft Cost';
        insert type2;
        
        
        List<litify_pm__Expense__c> expList = new List<litify_pm__Expense__c>();
        //0
        expList.add(
            new litify_pm__Expense__c(
                litify_pm__Amount__c = 100,
                litify_pm__Date__c = system.today(),
                litify_pm__Matter__c = matter.id,
                litify_pm__ExpenseType2__c = type.id,
                litify_pm__lit_Invoice__c ='test1',
                Initial_Submitter__c = userinfo.getUserEmail()
            )
        );
        //1
        expList.add(
            new litify_pm__Expense__c(
                litify_pm__Amount__c = 0,
                litify_pm__Date__c = system.today(),
                litify_pm__Matter__c = matter.id,
                litify_pm__ExpenseType2__c = type2.id,
                litify_pm__lit_Invoice__c ='test2',
                Initial_Submitter__c = userinfo.getUserEmail()
                
            )
        );
        //2
        expList.add(
            new litify_pm__Expense__c(
                litify_pm__Amount__c = 1000,
                litify_pm__Date__c = system.today(),
                litify_pm__Matter__c = matter.id,
                litify_pm__ExpenseType2__c = type.id,
                litify_pm__lit_Invoice__c ='test3',
                Initial_Submitter__c = userinfo.getUserEmail()
            )
        );
        //3
        expList.add(
            new litify_pm__Expense__c(
                litify_pm__Amount__c = 1000,
                litify_pm__Date__c = system.today(),
                litify_pm__Matter__c = matter.id,
                litify_pm__ExpenseType2__c = type.id,
                litify_pm__lit_Invoice__c ='test4',
                Initial_Submitter__c = userinfo.getUserEmail(),
                Origin__c='Litify'
            )
        );
        //4
        expList.add(
            new litify_pm__Expense__c(
                litify_pm__Amount__c = 1000,
                litify_pm__Date__c = system.today(),
                litify_pm__Matter__c = matter.id,
                litify_pm__ExpenseType2__c = type2.id,
                litify_pm__lit_Invoice__c ='test5',
                Initial_Submitter__c = userinfo.getUserEmail(),
                Origin__c='Matter'
            )
        );
        //5
        expList.add(
            new litify_pm__Expense__c(
                litify_pm__Amount__c = 1000,
                litify_pm__Date__c = system.today(),
                litify_pm__Matter__c = matter.id,
                litify_pm__ExpenseType2__c = type.id,
                litify_pm__lit_Invoice__c ='test5',
                Initial_Submitter__c = userinfo.getUserEmail(),
                Origin__c='Litify'
            )
        );
        
        insert expList;
        
        
        string accPeriodName = String.valueOf(System.today().year())+'-'+(string.valueOf(system.today().month()).length() ==1 ?'0'+String.valueOf(system.today().month()) : String.valueOf(system.today().month()));        
        system.debug('**accPeriodName**'+accPeriodName);        
        list<AcctSeed__Accounting_Period__c> periodList = new list<AcctSeed__Accounting_Period__c>();        
        periodList = [select Id,name from AcctSeed__Accounting_Period__c where name =: accPeriodName];
        
        list<AcctSeed__Accounting_Variable__c> listGLVariables = new list<AcctSeed__Accounting_Variable__c> ();
        AcctSeed__Accounting_Variable__c objGLV2 = new AcctSeed__Accounting_Variable__c(name='Location var',AcctSeed__Active__c=true,AcctSeed__Type__c='GL Account Variable 2');
        AcctSeed__Accounting_Variable__c objGLV3 = new AcctSeed__Accounting_Variable__c(name='Department var',AcctSeed__Active__c=true,AcctSeed__Type__c='GL Account Variable 3');
        listGLVariables.add(objGLV2);
        listGLVariables.add(objGLV3);
        insert listGLVariables;
        
        AcctSeed__Account_Payable__c objPayable = new AcctSeed__Account_Payable__c();
        objPayable.AcctSeed__Vendor__c = objAcc.Id;
        objPayable.AcctSeed__Payee_Reference__c = 'Test Payable 123';
        objPayable.AcctSeed__Accounting_Period__c = periodList[0].Id;
        objPayable.AcctSeed__Ledger__c = ledgers[0].id;
        insert objPayable;
        
        AcctSeed__Account_Payable_Line__c apLine = new AcctSeed__Account_Payable_Line__c();
        apLine.AcctSeed__Account_Payable__c = objPayable.Id;
        apLine.AcctSeed__Amount__c = 45;
        apLine.AcctSeed__Expense_GL_Account__c = glAccountsExpense[0].Id;
        apLine.Expense__c = expList[0].id;
        apLine.AcctSeed__GL_Account_Variable_2__c = objGLV2.Id;
        apLine.AcctSeed__GL_Account_Variable_3__c = objGLV3.Id;
        insert apLine; 
        
        
        
    }
    
    public static testmethod void getExpenseWrapperTest(){
        list<litify_pm__Expense__c>listExp =[select id from litify_pm__Expense__c limit 1];
        splitExpenseController.getExpenseWrapper(listExp[0].Id);
    }
    
    public static testmethod void saveExpenseDetailsTest(){
        list<litify_pm__Expense__c>listExp =[select id,litify_pm__Matter__c,litify_pm__Matter__r.Name from litify_pm__Expense__c limit 1];
        
        splitExpenseWrapper objWrp= splitExpenseController.getExpenseWrapper(listExp[0].Id);
        splitExpenseWrapper.splitExpenseLineWrapper objLineWrp = new splitExpenseWrapper.splitExpenseLineWrapper();
        objLineWrp.matterId = listExp[0].litify_pm__Matter__c;
        objLineWrp.matterName='';
        objLineWrp.amount = 5;
        list<splitExpenseWrapper.splitExpenseLineWrapper> listLineWrapper = new  list<splitExpenseWrapper.splitExpenseLineWrapper>();
        listLineWrapper.add(objLineWrp);
        objWrp.listInvoiceLines =listLineWrapper;
        objWrp.remainingAmount = 10;
        objWrp.totalAmountSplit = 10;
        objWrp.totalLineAmount = 10;
        
        splitExpenseController.saveExpenseDetails( listExp[0].Id, objWrp);
        
        Split_Expenses_GL_Accounts__c objSetting = new Split_Expenses_GL_Accounts__c(Credit_GL_Account__c='1201-Client Costs Advanced',Debit_GL_Account__c='1002-Cash');
        insert objSetting;
        splitExpenseController.saveExpenseDetails( listExp[0].Id, objWrp);
    }
    
}