@isTest
public class clientCostRefundControllerTest {
    
    @testSetup
    public static void testsetup(){
        list<Account>listAcc =new list<Account>();        
        listAcc.add(new Account(
            Name = 'test',
            litify_pm__Last_Name__c = 'test lName'));
        
        Id vendorRecTypeId= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Provider Contact Information').getRecordTypeId();
        listAcc.add( new Account(
            recordTypeId=vendorRecTypeId,
            AcctSeed__Accounting_Type__c='Vendor',
            Name = 'Vendor',
            AcctSeed__Accounting_Active__c =true,
            litify_pm__Last_Name__c = 'test')
                   );
        listAcc.add( new Account(
            recordTypeId=vendorRecTypeId,
            AcctSeed__Accounting_Type__c='Vendor',
            Name = label.Firm_Distribution_Account_AAA,
            AcctSeed__Accounting_Active__c =true,
            litify_pm__Last_Name__c = 'test')
                   );
        insert listAcc;
        
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
        
        listGL.add(new AcctSeed__GL_Account__c(
            Name = '1050-Cash - Case Costs',
            AcctSeed__Active__c = true,
            AcctSeed__Type__c = 'Balance Sheet',
            AcctSeed__Sub_Type_1__c = 'Assets',
            Department__c = dep.id,
            AcctSeed__Sub_Type_2__c = 'Cash'));
        
        insert listGL;
        
        
        litify_pm__Matter__c objMatter = new litify_pm__Matter__c();
        objMatter.litify_pm__Client__c = listAcc[1].id;
        objMatter.litify_pm__Contingency_Fee_Rate__c=10;
        insert objMatter;
        
        litify_pm__Matter_Team_Role__c objTeamRole = new litify_pm__Matter_Team_Role__c(Name='Attorney');
        insert objTeamRole;
        litify_pm__Matter_Team_Member__c matterTeamMem = new litify_pm__Matter_Team_Member__c();
        matterTeamMem.Name='Test';
        matterTeamMem.litify_pm__Matter__c = objMatter.id;
        matterTeamMem.litify_pm__User__c = userinfo.getUserId();
        matterTeamMem.litify_pm__Role__c = objTeamRole.id;
        insert matterTeamMem;
        
        List<litify_pm__Expense_Type__c>listExpType= new  List<litify_pm__Expense_Type__c>();
        litify_pm__Expense_Type__c type = new litify_pm__Expense_Type__c();
        type.Category__c = 'Hard Cost';
        listExpType.add(type);
        
        litify_pm__Expense_Type__c type2 = new litify_pm__Expense_Type__c();
        type2.Category__c = 'Soft Cost';
        listExpType.add(type2);
        insert listExpType;
        
        List<litify_pm__Expense__c> expList = new List<litify_pm__Expense__c>();
        //0
        expList.add(
            new litify_pm__Expense__c(
                litify_pm__Amount__c = 200,
                litify_pm__Date__c = system.today(),
                litify_pm__Matter__c = objMatter.id,
                litify_pm__ExpenseType2__c = type.id,
                litify_pm__lit_Invoice__c ='test1',
                Stage__c = 'In-Process'
            )
        );
        
        //1
        expList.add(
            new litify_pm__Expense__c(
                litify_pm__Amount__c = 9000,
                litify_pm__Date__c = system.today(),
                litify_pm__Matter__c = objMatter.id,
                litify_pm__ExpenseType2__c = type.id,
                litify_pm__lit_Invoice__c ='test2',
                Stage__c = 'In-Process'
            )
        );
        //2
        expList.add(
            new litify_pm__Expense__c(
                litify_pm__Amount__c = 100,
                litify_pm__Date__c = system.today(),
                litify_pm__Matter__c = objMatter.id,
                litify_pm__ExpenseType2__c = type2.id,
                litify_pm__lit_Invoice__c ='test3',
                Stage__c = 'In-Process'
            )
        );
        insert expList;
        
        List<AcctSeed__Billing_Format__c> billingFormats = new List<AcctSeed__Billing_Format__c>();
        billingFormats.add(
            new AcctSeed__Billing_Format__c(
                Name = 'Default Billing Product',
                AcctSeed__Visualforce_PDF_Page__c = 'BillingOutstandingStatementPDF',
                AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                AcctSeed__Type__c = 'Billing',
                AcctSeed__Sort_Field__c = 'Name'
            )
        );
        
        billingFormats.add(
            new AcctSeed__Billing_Format__c(
                Name = 'Default Billing Service',
                AcctSeed__Visualforce_PDF_Page__c = 'BillingOutstandingStatementPDF',
                AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                AcctSeed__Type__c = 'Billing',
                AcctSeed__Sort_Field__c = 'Name'
            )
        );
        
        billingFormats.add(
            new AcctSeed__Billing_Format__c (
                Name = 'Billing Outstanding Statment',
                AcctSeed__Visualforce_PDF_Page__c = 'BillingOutstandingStatementPDF',
                AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                AcctSeed__ReplyTo_Email__c = 'test3463464364646@gmail.com',
                AcctSeed__Type__c = 'Outstanding Statement'
            )
        );
        
        billingFormats.add(
            new AcctSeed__Billing_Format__c (
                Name = 'Billing Activity Statment',
                AcctSeed__Visualforce_PDF_Page__c = 'BillingOutstandingStatementPDF',
                AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                AcctSeed__ReplyTo_Email__c = 'test3463464364646@gmail.com',
                AcctSeed__Type__c = 'Activity Statement'
            )
        );
        
        billingFormats.add(
            new AcctSeed__Billing_Format__c (
                Name = 'Default Packing Slip',
                AcctSeed__Visualforce_PDF_Page__c = 'BillingOutstandingStatementPDF',
                AcctSeed__Default_Email_Template__c = 'Billing_Email_Template',
                AcctSeed__ReplyTo_Email__c = 'test3463464364646@gmail.com',
                AcctSeed__Type__c = 'Packing Slip'
            )
        );
        
        billingFormats.add(
            new AcctSeed__Billing_Format__c (
                Name = 'Default Purchase Orde',
                AcctSeed__Visualforce_PDF_Page__c = 'BillingOutstandingStatementPDF',
                AcctSeed__Default_Email_Template__c = 'Billing_Email_Template',
                AcctSeed__ReplyTo_Email__c = 'test3463464364646@gmail.com',
                AcctSeed__Type__c = 'Purchase Order'
            )
        );
        
        insert billingFormats;
        
        List<AcctSeed__Ledger__c> ledgers = new List<AcctSeed__Ledger__c>();
        
        
        ledgers.add(
            new AcctSeed__Ledger__c(
                Name = 'TRUST',
                AcctSeed__Type__c = 'Budget',
                AcctSeed__Default_Bank_Account__c = listGL[2].Id,
                AcctSeed__Default_Billing_Format__c = billingFormats[0].Id,
                AcctSeed__Billing_Outstanding_Statement_Format__c = billingFormats[2].Id,
                AcctSeed__Billing_Activity_Statement_Format__c = billingFormats[3].Id,
                AcctSeed__Default_Purchase_Order_Format__c = billingFormats[5].id,
                AcctSeed__Default_Packing_Slip_Format__c = billingFormats[4].id
            )
        );
        ledgers.add(
            new AcctSeed__Ledger__c(
                Name = 'FIRM',
                AcctSeed__Type__c = 'Transactional',
                AcctSeed__Default_Bank_Account__c = listGL[2].Id,
                AcctSeed__Default_Billing_Format__c = billingFormats[0].Id,
                AcctSeed__Billing_Outstanding_Statement_Format__c = billingFormats[2].Id,
                AcctSeed__Billing_Activity_Statement_Format__c = billingFormats[3].Id,
                AcctSeed__Default_Purchase_Order_Format__c = billingFormats[5].id,
                AcctSeed__Default_Packing_Slip_Format__c = billingFormats[4].id
            )
        );
        insert ledgers;
        
        list<AcctSeed__Accounting_Variable__c>listGLVariables = new  list<AcctSeed__Accounting_Variable__c>();
        AcctSeed__Accounting_Variable__c objGLV2 = new AcctSeed__Accounting_Variable__c(name='Location var',AcctSeed__Active__c=true,AcctSeed__Type__c='GL Account Variable 2');
        AcctSeed__Accounting_Variable__c objGLV3 = new AcctSeed__Accounting_Variable__c(name='Department var',AcctSeed__Active__c=true,AcctSeed__Type__c='GL Account Variable 3');
        listGLVariables.add(objGLV2);
        listGLVariables.add(objGLV3);
        listGLVariables.add(new AcctSeed__Accounting_Variable__c(name='Richmond',AcctSeed__Active__c=true,AcctSeed__Type__c='GL Account Variable 2'));
        listGLVariables.add(new AcctSeed__Accounting_Variable__c(name='test1',AcctSeed__Active__c=true,AcctSeed__Type__c='GL Account Variable 1'));
        listGLVariables.add(new AcctSeed__Accounting_Variable__c(name='test4',AcctSeed__Active__c=true,AcctSeed__Type__c='GL Account Variable 4'));
        listGLVariables.add( new AcctSeed__Accounting_Variable__c(name='PI',AcctSeed__Active__c=true,AcctSeed__Type__c='GL Account Variable 1'));
        
        insert listGLVariables; 
        
        List<AcctSeed__Accounting_Period__c> lstAccountingPeriod = new List<AcctSeed__Accounting_Period__c>();
        Date currentDate = system.today();
        
        for (Integer i = 0; i < 10; i++) {            
            AcctSeed__Accounting_Period__c objAccountingPeriod = new AcctSeed__Accounting_Period__c();            
            objAccountingPeriod.AcctSeed__Start_Date__c = currentDate.addMonths(i);
            objAccountingPeriod.AcctSeed__End_Date__c = objAccountingPeriod.AcctSeed__Start_Date__c.addMonths(1).toStartOfMonth() - 1;
            objAccountingPeriod.Name = objAccountingPeriod.AcctSeed__Start_Date__c.year() + '-' + (string.valueOf(objAccountingPeriod.AcctSeed__Start_Date__c.month()).length() == 1 ? '0' : '') + objAccountingPeriod.AcctSeed__Start_Date__c.month();
            objAccountingPeriod.AcctSeed__Status__c='Open';                       
            lstAccountingPeriod.add(objAccountingPeriod);
        }
        insert lstAccountingPeriod;
        
        
        
        
    }
    
    public static testmethod void getExpenseDetailsTest(){
        List<litify_pm__Expense__c> expList = [select id from litify_pm__Expense__c limit 1];
        clientCostRefundController.getExpenseDetails(expList[0].id);
    }
    public static testmethod void saveRefundTest(){
        list<litify_pm__Matter__c>listMatter = [select id from litify_pm__Matter__c limit 1];
        List<litify_pm__Expense__c> expList = [select id from litify_pm__Expense__c limit 1];
        clientCostRefundController.saveRefund(listMatter[0].Id,100,expList[0].id,'');
        
        list<AcctSeed__GL_Account__c>listGL = [select id,name from AcctSeed__GL_Account__c where name in('1050-Cash - Case Costs','1200-Client Costs Advanced') ];
        ATO_Void_GL_Accounts__c objSetting = new ATO_Void_GL_Accounts__c(Credit_Account__c= '1200-Client Costs Advanced',Debit_Account__c='1050-Cash - Case Costs');
        insert objSetting;
        clientCostRefundController.saveRefund(listMatter[0].Id,100,expList[0].id,'');
        
        litify_pm__Expense_Type__c objExpType = new litify_pm__Expense_Type__c(name='Refund',Category__c='Soft Cost');
        insert objExpType;
        clientCostRefundController.saveRefund(listMatter[0].Id,100,expList[0].id,'');
        
    }
    
}