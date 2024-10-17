@isTest
public class depositForExpenseControllerTest {

    @testsetup
    public static void testSetup(){
        list<Account>listAcc =new list<Account>();        
        listAcc.add(new Account(
            Name = 'test',
            litify_pm__Last_Name__c = 'test lName',
            AcctSeed__Accounting_Active__c =true,
            AcctSeed__Accounting_Type__c='Vendor'));
        
        listAcc.add( new Account(
            AcctSeed__Accounting_Type__c='Vendor',
            Name = 'Vendor',
            AcctSeed__Accounting_Active__c =true,
            litify_pm__Last_Name__c = 'test')
                   );
        listAcc.add( new Account(
            AcctSeed__Accounting_Type__c='Vendor',
            Name = label.Payee_for_Hard_Cost_and_Soft_Cost,
            AcctSeed__Accounting_Active__c =true,
            litify_pm__Last_Name__c = label.Payee_for_Hard_Cost_and_Soft_Cost)
                   );
        listAcc.add( new Account(
            AcctSeed__Accounting_Type__c='Vendor',
            Name = label.payee_for_Contigency_Fee,
            AcctSeed__Accounting_Active__c =true,
            litify_pm__Last_Name__c = label.payee_for_Contigency_Fee)
                   );
        insert listAcc;
        
        List<Account>listAcc1 = [select id,name from Account];
        
        
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
        
        
        
        
        COS_Fee_Revenue_GL_Account__c objFeeRevSetting = new COS_Fee_Revenue_GL_Account__c(Fee_Revenue_GL_Account__c='4000-Fee Income',Hard_Cost_Advanced__c='1300-Client Costs Advanced',Soft_Cost_Reimbursed__c='4500-Litigation Exp Reimbursed',Trust_Receivable_GL_Account__c='1151-Trust Receivable',Settlement_Liability_GL_Account__c='2200-Client Trust Liability' );
        objFeeRevSetting.name='KREIN';
        insert objFeeRevSetting;
        
        Trust_GL_Accounts__c objTrustGL = new Trust_GL_Accounts__c(Trust_Cash_GL_Account__c='4000-Fee Income',Trust_Liability_GL_Account__c='2200-Client Trust Liability');
        insert objTrustGL;
        List<AcctSeed__GL_Account__c> glAccounts = new List<AcctSeed__GL_Account__c>();
        // 0
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '1006-Cash',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Bank__c = true,
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Cash',
                External_ID__c='1006'
            )
        );
        
        // 1
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '1050-Unapplied Cash',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Bank__c = false,
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Cash',
                External_ID__c='1050'
            )
        );
        
        // 2
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '1200-Accounts Receivable',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Current Assets',
                External_ID__c='1200'
            )
        );
        
        // 3
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '1600-Work In Process',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Current Assets',
                External_ID__c='1600'
            )
        );
        
        // 4
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '2000-Accounts Payable',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Liabilities',
                AcctSeed__Sub_Type_2__c = 'Current Liabilities',
                External_ID__c='2000'
            )
        );
        
        // 5
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '2010-Vouchers Payable',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Liabilities',
                AcctSeed__Sub_Type_2__c = 'Current Liabilities',
                External_ID__c='2010'
            )
        );
        
        // 6
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '1117-billing revenue',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Liabilities',
                AcctSeed__Sub_Type_2__c = 'Current Liabilities',
                External_ID__c='1117'
            )
        );
        
        
        // 7
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '3000-Owners Equity',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Owners Equity',
                AcctSeed__Sub_Type_2__c = 'Equity',
                External_ID__c='3000'
            )
        );
        
        // 8
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '3050-Retained Earnings',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Owners Equity',
                AcctSeed__Sub_Type_2__c = 'Equity',
                External_ID__c='3050'
            )
        );
        
        // 9
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '3060-Current Year Earnings',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Owners Equity',
                AcctSeed__Sub_Type_2__c = 'Equity',
                External_ID__c='3060'
            )
        );
        
        // 10
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '4001-Product Revenue',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Revenue',
                AcctSeed__Sub_Type_1__c = 'Product Revenue',
                AcctSeed__Sub_Type_2__c = 'Product Family 1',
                External_ID__c='4001'
            )
        );
        
        // 11
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '1112-Je Reverse',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Revenue',
                AcctSeed__Sub_Type_1__c = 'Service Revenue',
                AcctSeed__Sub_Type_2__c = 'Service Family 1',
                External_ID__c='1112'
            )
        );
        
        // 12
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '5000-Cost of Goods Sold',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Expense',
                AcctSeed__Sub_Type_1__c = 'Cost of Goods Sold',
                AcctSeed__Sub_Type_2__c = 'Materials',
                External_ID__c='5000'
            )
        );
        
        // 13
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '5010-Inventory Cost Variance',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Expense',
                AcctSeed__Sub_Type_1__c = 'Cost of Goods Sold',
                AcctSeed__Sub_Type_2__c = 'Materials',
                External_ID__c='5010'
            )
        );
        
        // 14
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '5040-Vendor Payment Discounts',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Expense',
                AcctSeed__Sub_Type_1__c = 'Cost of Goods Sold',
                AcctSeed__Sub_Type_2__c = 'Materials',
                External_ID__c='5040'
            )
        );
        
        // 15
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '5050-Labor',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Expense',
                AcctSeed__Sub_Type_1__c = 'Cost of Goods Sold',
                AcctSeed__Sub_Type_2__c = 'Salaries & Wages',
                External_ID__c='5050'
            )
        );
        
        // 16
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '6000-Marketing Expense',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Expense',
                AcctSeed__Sub_Type_1__c = 'Sales & Marketing',
                AcctSeed__Sub_Type_2__c = 'Marketing Events',
                External_ID__c='6000'
            )
        );
        
        // 17
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '7000-Facilities Expense',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Expense',
                AcctSeed__Sub_Type_1__c = 'Facilities',
                AcctSeed__Sub_Type_2__c = 'Rent',
                External_ID__c='7000'
            )
        );
        
        // 18
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '1119-auth',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Expense',
                AcctSeed__Sub_Type_1__c = 'Facilities',
                AcctSeed__Sub_Type_2__c = 'Utilities',
                External_ID__c='1119'
            )
        );
        
        // 19
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '1120-zLabor Clearing',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Expense',
                External_ID__c='1120'
            )
        );
        
        // 20
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '1121-zProject Labor',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Expense',
                External_ID__c='1121'
            )
        );
        
        // 21
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '4900-Customer Payment Discounts',
                AcctSeed__Active__c = true,
                AcctSeed__Bank__c = false,
                AcctSeed__Type__c = 'Revenue',
                AcctSeed__Sub_Type_1__c = 'Product Revenue',
                AcctSeed__Sub_Type_2__c = 'Product Family 1',
                External_ID__c='4900'
            )
        );
        
        // 22
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '1500-Inventory',
                AcctSeed__Active__c = true,
                AcctSeed__Bank__c = false,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Current Assets',
                External_ID__c='1500'
            )
        );
        //23
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '1000-Cash',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Bank__c = true,
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Cash',
                External_ID__c='1000'
            )
        );
        
        //24
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '1206-Client Costs Advanced',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Bank__c = true,
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Cash',
                External_ID__c='1206'
            )
        );
        
        //25
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '1010-JP Morgan - NY IOLA Trust Acct',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Bank__c = true,
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Cash',
                External_ID__c='1010'
            )
        );
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = objFeeRevSetting.Hard_Cost_Advanced__c,
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Current Assets',
                External_ID__c='1300'
            )
        );
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = objTrustGL.Trust_Liability_GL_Account__c,
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Current Assets',
                External_ID__c='2200'
            )
        );
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = objTrustGL.Trust_Cash_GL_Account__c,
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Current Assets',
                External_ID__c='4000'
            )
        );
        
        insert glAccounts;
        
        //2nd script
        //
        Map<String,AcctSeed__GL_Account__c> glAccountsMap = new Map<String,AcctSeed__GL_Account__c>();
        
        for(AcctSeed__GL_Account__c obj : [SELECT Id,Name FROM AcctSeed__GL_Account__c] ){
            // System.debug('obj.Name '+obj.Name);
            glAccountsMap.put(obj.Name,obj);
        }
        
        List<AcctSeed__GL_Account__c> glAccountsExpense = new List<AcctSeed__GL_Account__c>();
        
        // 0
        glAccountsExpense.add(
            new AcctSeed__GL_Account__c(
                Name = '6050-Travel Expenses',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Expense',
                AcctSeed__Expense_Report_Name__c = 'Travel Expenses',
                AcctSeed__Billing_Description__c = 'Travel Expenses',
                AcctSeed__TM_Revenue_Conversion__c = glAccountsMap.get('1112-Je Reverse').Id,
                AcctSeed__Sub_Type_1__c = 'Sales & Marketing',
                AcctSeed__Sub_Type_2__c = 'Sales Travel',
                External_ID__c='6050'
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
                AcctSeed__TM_Revenue_Conversion__c = glAccountsMap.get('1112-Je Reverse').Id,
                AcctSeed__Sub_Type_1__c = 'Sales & Marketing',
                AcctSeed__Sub_Type_2__c = 'Sales Travel',
                External_ID__c='6060'
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
                AcctSeed__TM_Revenue_Conversion__c = glAccountsMap.get('1112-Je Reverse').Id,
                AcctSeed__Sub_Type_1__c = 'Sales & Marketing',
                AcctSeed__Sub_Type_2__c = 'Sales Travel',
                External_ID__c='6070'
            )
        );
        
        insert glAccountsExpense;
        
        
        
        //3rd script
        Map<String,AcctSeed__GL_Account__c> glAccountsMap1 = new Map<String,AcctSeed__GL_Account__c>();
        
        for(AcctSeed__GL_Account__c objGL : [SELECT Id,Name FROM AcctSeed__GL_Account__c] ){
            glAccountsMap1.put(objGL.Name,objGL);
        }
        
        
        
        litify_pm__Matter__c objMatter = new litify_pm__Matter__c();
        objMatter.litify_pm__Client__c = listAcc[0].id;
        objMatter.litify_pm__Contingency_Fee_Rate__c=10;
        objMatter.litify_pm__Principal_Attorney__c =userList[0].id;
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
        type2.Name = Label.Expense_Type_for_Deposit;
        listExpType.add(type2);
        
        litify_pm__Expense_Type__c type3 = new litify_pm__Expense_Type__c();
        type3.Category__c = 'Other';
        type3.Name = Label.Expense_Type_for_Deposit;
        listExpType.add(type3);
        insert listExpType;
        
        List<litify_pm__Expense__c> expList = new List<litify_pm__Expense__c>();
        //0
        expList.add(
            new litify_pm__Expense__c(
                litify_pm__Amount__c = 200,
                litify_pm__Date__c = system.today(),
                litify_pm__Matter__c = objMatter.id,
                litify_pm__ExpenseType2__c = type.id,
                litify_pm__lit_Invoice__c ='test1'
                
            )
        );
        
        //1
        expList.add(
            new litify_pm__Expense__c(
                litify_pm__Amount__c = 9000,
                litify_pm__Date__c = system.today(),
                litify_pm__Matter__c = objMatter.id,
                litify_pm__ExpenseType2__c = type.id,
                litify_pm__lit_Invoice__c ='test2'
                
            )
        );
        //2
        expList.add(
            new litify_pm__Expense__c(
                litify_pm__Amount__c = 100,
                litify_pm__Date__c = system.today(),
                litify_pm__Matter__c = objMatter.id,
                litify_pm__ExpenseType2__c = type2.id,
                litify_pm__lit_Invoice__c ='test3'
                
            )
        );
        insert expList;
        
        AcctSeed__Project__c objProject = new AcctSeed__Project__c(Matter__c = objMatter.id);
        insert objProject;
        
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
                Name = 'Actual',
                AcctSeed__Type__c = 'Transactional',
                AcctSeed__Default_Bank_Account__c = glAccountsMap.get('1006-Cash').Id,
                AcctSeed__Default_Billing_Format__c = billingFormats[0].Id,
                AcctSeed__Billing_Outstanding_Statement_Format__c = billingFormats[2].Id,
                AcctSeed__Billing_Activity_Statement_Format__c = billingFormats[3].Id,
                AcctSeed__Default_Purchase_Order_Format__c = billingFormats[5].id,
                AcctSeed__Default_Packing_Slip_Format__c = billingFormats[4].id
            )
        );
        
        ledgers.add(
            new AcctSeed__Ledger__c(
                Name = 'Budget',
                AcctSeed__Type__c = 'Budget',
                AcctSeed__Default_Bank_Account__c = glAccountsMap.get('1006-Cash').Id,
                AcctSeed__Default_Billing_Format__c = billingFormats[0].Id,
                AcctSeed__Billing_Outstanding_Statement_Format__c = billingFormats[2].Id,
                AcctSeed__Billing_Activity_Statement_Format__c = billingFormats[3].Id,
                AcctSeed__Default_Purchase_Order_Format__c = billingFormats[5].id,
                AcctSeed__Default_Packing_Slip_Format__c = billingFormats[4].id
            )
        );
        insert ledgers;
        
        list<AcctSeed__Accounting_Variable__c>listGLVariables = new  list<AcctSeed__Accounting_Variable__c>();
        AcctSeed__Accounting_Variable__c objGLV2 = new AcctSeed__Accounting_Variable__c(name='Location var',AcctSeed__Active__c=true,AcctSeed__Type__c='GL Account Variable 2',external_ID__c='Location var');
        AcctSeed__Accounting_Variable__c objGLV3 = new AcctSeed__Accounting_Variable__c(name='Department var',AcctSeed__Active__c=true,AcctSeed__Type__c='GL Account Variable 3',external_ID__c='Department var');
        listGLVariables.add(objGLV2);
        listGLVariables.add(objGLV3);
        listGLVariables.add(new AcctSeed__Accounting_Variable__c(name='Richmond',AcctSeed__Active__c=true,AcctSeed__Type__c='GL Account Variable 2',external_ID__c='Richmond'));
        listGLVariables.add(new AcctSeed__Accounting_Variable__c(name='test1',AcctSeed__Active__c=true,AcctSeed__Type__c='GL Account Variable 1',external_ID__c='test1'));
        listGLVariables.add(new AcctSeed__Accounting_Variable__c(name='test4',AcctSeed__Active__c=true,AcctSeed__Type__c='GL Account Variable 4',external_ID__c='test4'));
        listGLVariables.add( new AcctSeed__Accounting_Variable__c(name='PI',AcctSeed__Active__c=true,AcctSeed__Type__c='GL Account Variable 1',external_ID__c='PI'));
        
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
        
        //litify_pm__Expense_Type__c objExpType = [SELECT Id FROM litify_pm__Expense_Type__c WHERE Name =: Label.Expense_Type_for_Deposit];
        
        Trust_Deposit__c objTrustDeposit = new Trust_Deposit__c(
            name='test',
            Date__c=system.date.today(),
            Number_of_Items__c=1,
            Status__c='In-Process',
            Total__c=10
        );
        insert objTrustDeposit;  
        
        AcctSeed__Journal_Entry__c  objJE = new AcctSeed__Journal_Entry__c();
        objJE.Name ='Test JE';
        objJE.AcctSeed__Journal_Date__c = objTrustDeposit.Date__c;
        objJE.AcctSeed__Accounting_Period__c = lstAccountingPeriod[0].Id;
        objJE.Trust_Deposit__c = objTrustDeposit.Id;
        objJE.AcctSeed__Ledger__c = ledgers[0].id;
        insert objJE;
        
        //Credit JE Line
        AcctSeed__Journal_Entry_Line__c objCreditJELine = new AcctSeed__Journal_Entry_Line__c();
        objCreditJELine.AcctSeed__Credit__c = 10;
        objCreditJELine.Payor__c = 'Test Payor';
        objCreditJELine.AcctSeed__GL_Account__c = glAccounts[0].Id;
        objCreditJELine.AcctSeed__Date__c = system.today();
        objCreditJELine.AcctSeed__Reference__c = 'Test ref';
        objCreditJELine.Is_Expense_Created__c = 'Positive';
        objCreditJELine.Expense_Status__c = 'Billed';
        objCreditJELine.AcctSeed__Journal_Entry__c = objJE.Id;
        objCreditJELine.AcctSeed__Project__c = objProject.Id;
        objCreditJELine.Expense_Type__c = type2.Id;
        insert objCreditJELine;
        
        //Debit JE Line
        AcctSeed__Journal_Entry_Line__c objDebitJELine = new AcctSeed__Journal_Entry_Line__c();
        objDebitJELine.AcctSeed__Credit__c = 10;
        objDebitJELine.Payor__c = 'Test Payor';
        objDebitJELine.AcctSeed__GL_Account__c = glAccounts[25].Id;
        objDebitJELine.AcctSeed__Date__c = system.today();
        objDebitJELine.AcctSeed__Reference__c = 'Test ref';
        objDebitJELine.AcctSeed__Journal_Entry__c = objJE.Id;
        objDebitJELine.AcctSeed__Project__c = objProject.Id;
        insert objDebitJELine;
    }
    
    public static testmethod void testMethod_depositForExpenseController(){
        List<Trust_Deposit__c>listTrustDeposit = [SELECT Id from Trust_Deposit__c WHERE Name='test'];
        List<litify_pm__Matter__c> matterList = [SELECT Id FROM litify_pm__Matter__c];
            
        List<AcctSeed__Project__c> projectList = depositForExpenseController.getRelatedProjects(matterList[0].Id);
        List<AcctSeed__Project__c> projectList1 = depositForExpenseController.getRelatedProjects('');
        
        List<AcctSeed__GL_Account__c> glAccounts = [SELECT Id, Name FROM AcctSeed__GL_Account__c WHERE Name = '1006-Cash'];
        
        System.debug('glAccounts ===> '+glAccounts);
        
        depositForExpenseController.depositWrapper objWrapper1= depositForExpenseController.getDepositDetails(listTrustDeposit[0].Id);
        depositForExpenseController.depositWrapper objWrapper2= depositForExpenseController.getDepositDetailsFromTab();
        
        System.debug('objWrapper1 ===> '+objWrapper1.objDeposit);
        System.debug('objWrapper1 ===> '+objWrapper1.listJELineWrapper);
        
        depositForExpenseController.saveDepositDetails(objWrapper1,glAccounts[0].Id);
        //depositForExpenseController.saveDepositDetails(objWrapper2,glAccounts[0].Id);
        
        depositForExpenseController.saveAndSubmitDepositDetails(objWrapper1,glAccounts[0].Id);
    }
}