/*
For costRecoveryController and resolutionExpensesWrapper
*/
@istest
public class costRecoveryControllerTest {
    
    @testSetup
    public static void testsetup(){
        
        Account objAcc = new Account();
        objAcc.Name = 'test';
        objAcc.litify_pm__Last_Name__c = 'test lName';
        insert objAcc;
        
        
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
            Name = '1203-Client Costs Advanced',
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
                Name = '1001-Cash',
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
        
        
        litify_pm__Matter__c objMatter = new litify_pm__Matter__c();
        objMatter.litify_pm__Client__c = objAcc.id;
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
                Name = 'Trust',
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
        
        litify_pm__Resolution__c objResolution = new litify_pm__Resolution__c(
            Hard_Costs__c=200,
            Soft_Costs__c=100,
            litify_pm__Total_Expenses__c=300,
            litify_pm__Matter__c = objMatter.id,
            litify_pm__Settlement_Verdict_Amount__c=50000,
            litify_pm__Total_Damages__c =100,
            AAAA_Fee_Rate__c=33.333333
        );
        
        insert objResolution;
        
        litify_pm__Role__c objRole = new litify_pm__Role__c(litify_pm__Party__c=objAcc.Id,litify_pm__Matter__c=objMatter.Id);
        insert objRole;
        
        litify_pm__Damage__c objDamage = new litify_pm__Damage__c( litify_pm__Amount_Billed__c=100,litify_pm__Matter__c=objMatter.id,litify_pm__Provider__c = objRole.Id);
        insert objDamage;
        objDamage.Resolution__c=objResolution.id;
        update objDamage;
        
        expList[0].Resolution__c=objResolution.id;
        //expList[0].Billing_Status__c='Pre-Billed';
        expList[2].Resolution__c=objResolution.id;
        //expList[2].Billing_Status__c='Pre-Billed';
        update expList;
        
        
        litify_pm__Lien__c lien = new litify_pm__Lien__c();
        lien.Resolution__c=objResolution.id;
        lien.litify_pm__lit_Comments__c ='Test Comment';
        lien.litify_pm__lit_Amount__c =10;
        lien.litify_pm__lit_Reductions__c = 5.7;
        lien.Date_Issued__c =system.today();
        lien.litify_pm__lit_Matter__c =objMatter.id;
        lien.litify_pm__lit_Payee__c = objRole.id;
        lien.Type__c ='Lien';
        insert lien;  
        
        Referral_Fee__c objReferral = new Referral_Fee__c(Amount__c=1,Account__c=objAcc.Id,Resolution__c=objResolution.Id);
        //insert objReferral;
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