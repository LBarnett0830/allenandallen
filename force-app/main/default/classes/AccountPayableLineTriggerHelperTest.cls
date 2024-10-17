@isTest
public class AccountPayableLineTriggerHelperTest {
    @testSetup static void unitTestSetup(){
        
        List<AcctSeed__GL_Account__c> glAccounts = new List<AcctSeed__GL_Account__c>();
        // 0
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '1006-Cash',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Bank__c = true,
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Cash'
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
                AcctSeed__Sub_Type_2__c = 'Cash'
            )
        );
        
        // 2
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '1200-Client Costs Advanced',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Current Assets'
            )
        );
        
        // 3
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '1600-Work In Process',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Current Assets'
            )
        );
        
        // 4
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '2000-Accounts Payable',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Liabilities',
                AcctSeed__Sub_Type_2__c = 'Current Liabilities'
            )
        );
        
        // 5
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '2010-Vouchers Payable',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Liabilities',
                AcctSeed__Sub_Type_2__c = 'Current Liabilities'
            )
        );
        
        // 6
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = 'billing revenue',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Liabilities',
                AcctSeed__Sub_Type_2__c = 'Current Liabilities'
            )
        );
        
        
        // 7
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '3000-Owners Equity',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Owners Equity',
                AcctSeed__Sub_Type_2__c = 'Equity'
            )
        );
        
        // 8
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '3050-Retained Earnings',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Owners Equity',
                AcctSeed__Sub_Type_2__c = 'Equity'
            )
        );
        
        // 9
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '3060-Current Year Earnings',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Owners Equity',
                AcctSeed__Sub_Type_2__c = 'Equity'
            )
        );
        
        // 10
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '4001-Product Revenue',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Revenue',
                AcctSeed__Sub_Type_1__c = 'Product Revenue',
                AcctSeed__Sub_Type_2__c = 'Product Family 1'
            )
        );
        
        // 11
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = 'Je Reverse',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Revenue',
                AcctSeed__Sub_Type_1__c = 'Service Revenue',
                AcctSeed__Sub_Type_2__c = 'Service Family 1'
            )
        );
        
        // 12
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '5000-Cost of Goods Sold',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Expense',
                AcctSeed__Sub_Type_1__c = 'Cost of Goods Sold',
                AcctSeed__Sub_Type_2__c = 'Materials'
            )
        );
        
        // 13
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '5010-Inventory Cost Variance',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Expense',
                AcctSeed__Sub_Type_1__c = 'Cost of Goods Sold',
                AcctSeed__Sub_Type_2__c = 'Materials'
            )
        );
        
        // 14
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '5040-Vendor Payment Discounts',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Expense',
                AcctSeed__Sub_Type_1__c = 'Cost of Goods Sold',
                AcctSeed__Sub_Type_2__c = 'Materials'
            )
        );
        
        // 15
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '5050-Labor',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Expense',
                AcctSeed__Sub_Type_1__c = 'Cost of Goods Sold',
                AcctSeed__Sub_Type_2__c = 'Salaries & Wages'
            )
        );
        
        // 16
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '6000-Marketing Expense',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Expense',
                AcctSeed__Sub_Type_1__c = 'Sales & Marketing',
                AcctSeed__Sub_Type_2__c = 'Marketing Events'
            )
        );
        
        // 17
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '7000-Facilities Expense',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Expense',
                AcctSeed__Sub_Type_1__c = 'Facilities',
                AcctSeed__Sub_Type_2__c = 'Rent'
            )
        );
        
        // 18
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = 'auth',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Expense',
                AcctSeed__Sub_Type_1__c = 'Facilities',
                AcctSeed__Sub_Type_2__c = 'Utilities'
            )
        );
        
        // 19
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = 'zLabor Clearing',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Expense'
            )
        );
        
        // 20
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = 'zProject Labor',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Expense'
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
                AcctSeed__Sub_Type_2__c = 'Product Family 1'
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
                AcctSeed__Sub_Type_2__c = 'Current Assets'
            )
        );
        //23
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '1000-Cash - Operating',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Bank__c = true,
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Cash'
            )
        );
        //24
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = label.Fee_Income_GL_Account,
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Bank__c = true,
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Cash'
            )
        );
        //25
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '1206-Client Costs Advanced',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Bank__c = true,
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Cash'
            )
        );
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '1205-Client Costs Advanced',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Current Assets'
            )
        );
        insert glAccounts;
        
        //2nd script
        //
        Map<String,AcctSeed__GL_Account__c> glAccountsMap = new Map<String,AcctSeed__GL_Account__c>();
        
        for(AcctSeed__GL_Account__c obj : [SELECT Id,Name FROM AcctSeed__GL_Account__c] ){
            System.debug('obj.Name '+obj.Name);
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
                AcctSeed__TM_Revenue_Conversion__c = glAccountsMap.get('Je Reverse').Id,
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
                AcctSeed__TM_Revenue_Conversion__c = glAccountsMap.get('Je Reverse').Id,
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
                AcctSeed__TM_Revenue_Conversion__c = glAccountsMap.get('Je Reverse').Id,
                AcctSeed__Sub_Type_1__c = 'Sales & Marketing',
                AcctSeed__Sub_Type_2__c = 'Sales Travel'
            )
        );
        glAccountsExpense.add(
            new AcctSeed__GL_Account__c(
                Name = label.Trust_Ledger_Debit_GL_Account,
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Expense',
                AcctSeed__Used_In_Expense_Reports__c = true,
                AcctSeed__Expense_Report_Name__c = 'Mileage',
                AcctSeed__Billing_Description__c = 'Mileage',
                AcctSeed__Mileage_Account__c = true,
                AcctSeed__Mileage_Rate__c = .52,
                AcctSeed__TM_Revenue_Conversion__c = glAccountsMap.get('Je Reverse').Id,
                AcctSeed__Sub_Type_1__c = 'Sales & Marketing',
                AcctSeed__Sub_Type_2__c = 'Sales Travel'
            )
        );
        
        insert glAccountsExpense;
        
        
        
        
        
        //3rd script
        Map<String,AcctSeed__GL_Account__c> glAccountsMap1 = new Map<String,AcctSeed__GL_Account__c>();
        
        for(AcctSeed__GL_Account__c obj : [SELECT Id,Name FROM AcctSeed__GL_Account__c] ){
            glAccountsMap1.put(obj.Name,obj);
        }
        
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
                Name = 'TRUST',
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
        
        //4 script
        //
        Map<String,AcctSeed__GL_Account__c> glAccountsMap2 = new Map<String,AcctSeed__GL_Account__c>();
        
        for(AcctSeed__GL_Account__c obj : [SELECT Id,Name FROM AcctSeed__GL_Account__c] ){
            glAccountsMap2.put(obj.Name,obj);
        }
        
        Map<String,AcctSeed__Billing_Format__c> billingFormatsMap = new Map<String,AcctSeed__Billing_Format__c>();
        
        for(AcctSeed__Billing_Format__c obj : [SELECT Id,Name FROM AcctSeed__Billing_Format__c] ){
            billingFormatsMap.put(obj.Name,obj);
        }
        
        Map<String,AcctSeed__Ledger__c> ledgersMap = new Map<String,AcctSeed__Ledger__c>();
        
        for(AcctSeed__Ledger__c obj : [SELECT Id,Name FROM AcctSeed__Ledger__c] ){
            ledgersMap.put(obj.Name,obj);
        }
        
        List<AcctSeed__Accounting_Period__c> lstAccountingPeriod = new List<AcctSeed__Accounting_Period__c>();
        Date currentDate = Date.newInstance(2018, 9, 1);
        
        for (Integer i = 0; i < 36; i++) {
            
            AcctSeed__Accounting_Period__c objAccountingPeriod = new AcctSeed__Accounting_Period__c();
            
            objAccountingPeriod.AcctSeed__Start_Date__c = currentDate.addMonths(i);
            objAccountingPeriod.AcctSeed__End_Date__c = objAccountingPeriod.AcctSeed__Start_Date__c.addMonths(1).toStartOfMonth() - 1;
            objAccountingPeriod.Name = objAccountingPeriod.AcctSeed__Start_Date__c.year() + '-' + (string.valueOf(objAccountingPeriod.AcctSeed__Start_Date__c.month()).length() == 1 ? '0' : '') + objAccountingPeriod.AcctSeed__Start_Date__c.month();
            
            objAccountingPeriod.AcctSeed__Status__c='Open';                       
            lstAccountingPeriod.add(objAccountingPeriod);
        }
        
        
        
        insert lstAccountingPeriod;
        
        List<AcctSeed__Accounting_Settings__c> settings = new List<AcctSeed__Accounting_Settings__c>();
        
        settings.add(
            new AcctSeed__Accounting_Settings__c (
                AcctSeed__AR_Control_GL_Account__c = glAccountsMap.get('1205-Client Costs Advanced').Id,
                AcctSeed__AP_Control_GL_Account__c = glAccountsMap.get('2000-Accounts Payable').Id,
                AcctSeed__Labor_GL_Account__c = glAccountsMap.get('zLabor Clearing').Id,
                AcctSeed__Payment_Discount_GL_Account__c = glAccountsMap.get('5040-Vendor Payment Discounts').Id,
                AcctSeed__Unapplied_Cash_GL_Account__c = glAccountsMap.get('1050-Unapplied Cash').Id,
                AcctSeed__Retained_Earnings_GL_Account__c = glAccountsMap.get('3050-Retained Earnings').Id,
                AcctSeed__Default_Ledger__c = ledgersMap.get('Actual').Id,
                AcctSeed__Default_Bank_Account__c = glAccountsMap.get('1006-Cash').Id,
                AcctSeed__Revenue_GL_Account__c = glAccountsMap.get('4001-Product Revenue').Id,
                AcctSeed__Default_Project_Task_Labor_GL_Account__c = glAccountsMap.get('zProject Labor').Id,
                AcctSeed__Default_Billing_Format__c = billingFormatsMap.get('Default Billing Product').Id,
                AcctSeed__Billing_Outstanding_Statement_Format__c = billingFormatsMap.get('Billing Outstanding Statment').Id,
                AcctSeed__Billing_Activity_Statement_Format__c = billingFormatsMap.get('Billing Activity Statment').Id,
                AcctSeed__Current_Year_Earnings_GL_Account__c = glAccountsMap.get('3060-Current Year Earnings').Id,
                AcctSeed__Enable_Product_Costing__c = true,
                AcctSeed__Work_in_Process_GL_Account__c = glAccountsMap.get('1600-Work In Process').Id,
                AcctSeed__Vouchers_Payable_GL_Account__c = glAccountsMap.get('2010-Vouchers Payable').Id,
                AcctSeed__Inventory_Variance_GL_Account__c = glAccountsMap.get('5010-Inventory Cost Variance').Id,
                AcctSeed__Customer_Payment_Adjustment_GL_Account__c = glAccountsMap.get('4900-Customer Payment Discounts').Id,
                AcctSeed__Display_Billable_Flag_in_Time_Card_Entry__c = true,
                AcctSeed__Enable_Billing_Period_Sensitive_Aging__c = true,
                AcctSeed__Enable_AP_Period_Sensitive_Aging__c = true
            )
        );
        insert settings;
        
        Account acc = new Account();
        acc.name = 'test1';
        acc.litify_pm__Last_Name__c ='test lName';
        insert acc;
        
        
        litify_pm__Matter__c matter = new litify_pm__Matter__c();
        matter.litify_pm__Client__c = acc.id;
        insert matter;
        
        List<litify_pm__Expense__c> expList = new List<litify_pm__Expense__c>();
        //0
        expList.add(
            new litify_pm__Expense__c(
                litify_pm__Amount__c = 101,
                litify_pm__Date__c = system.today(),
                litify_pm__Matter__c = matter.id,
                Stage__c = 'In-Process'
            )
        );
        
        insert expList;
        
        
        
        AcctSeed__Account_Payable__c[] payables = new List <AcctSeed__Account_Payable__c> ();
        payables.add(
            new AcctSeed__Account_Payable__c(
                AcctSeed__Vendor__c = [Select Id From Account limit 1].Id,
                AcctSeed__Payee_Reference__c = 'ThisIsATestPayeeReference123',
                AcctSeed__Accounting_Period__c= lstAccountingPeriod[0].Id,
                AcctSeed__Ledger__c=ledgers[0].Id,
                // Expense_Type__c='Matter',
                AcctSeed__Status__c='Approved'
            )
        );
        
        payables.add(
            new AcctSeed__Account_Payable__c(
                AcctSeed__Vendor__c = [Select Id From Account limit 1].Id,
                AcctSeed__Payee_Reference__c = 'ThisIsATestPayeeReference456',
                AcctSeed__Accounting_Period__c= lstAccountingPeriod[0].Id,
                AcctSeed__Ledger__c=ledgers[0].Id,
                // Expense_Type__c='Matter',
                AcctSeed__Status__c='Approved'
                
            )
        );
        
        
        
        insert payables;
        
        List<user>listUser = [select id, Alias from user where id=:userinfo.getUserId()];
        string attorney = listUser[0].alias;
        list<AcctSeed__Accounting_Variable__c>listGLVariables = new  list<AcctSeed__Accounting_Variable__c>();
        AcctSeed__Accounting_Variable__c objGLV2 = new AcctSeed__Accounting_Variable__c(name='Location var',AcctSeed__Active__c=true,AcctSeed__Type__c='GL Account Variable 2');
        AcctSeed__Accounting_Variable__c objGLV3 = new AcctSeed__Accounting_Variable__c(name='Department var',AcctSeed__Active__c=true,AcctSeed__Type__c='GL Account Variable 3');
        AcctSeed__Accounting_Variable__c objGLV4 = new AcctSeed__Accounting_Variable__c(name=attorney,AcctSeed__Active__c=true,AcctSeed__Type__c='GL Account Variable 4');
        listGLVariables.add(objGLV2);
        listGLVariables.add(objGLV3);
        listGLVariables.add(objGLV4);
        insert listGLVariables;
        
        // Create account payable line records to post and unpost
        AcctSeed__Account_Payable_Line__c[] apLines = new List <AcctSeed__Account_Payable_Line__c> ();
        AcctSeed__GL_Account__c glAccount = [Select Id From AcctSeed__GL_Account__c  Where  AcctSeed__Type__c = 'Expense'  limit 1];
        list<AcctSeed__Project__c>listProject = [select id from AcctSeed__Project__c];
        
        litify_pm__Expense_Type__c type1 = new litify_pm__Expense_Type__c();
        type1.Category__c = 'Hard Cost';
        insert type1;
        
        litify_pm__Expense_Type__c type2 = new litify_pm__Expense_Type__c();
        type2.Category__c = 'Soft Cost';
        insert type2;
        
        for (AcctSeed__Account_Payable__c ap : payables) {
            AcctSeed__Account_Payable_Line__c apLine = new AcctSeed__Account_Payable_Line__c();
            apLine.AcctSeed__Account_Payable__c = ap.Id;
            apLine.AcctSeed__Amount__c = 45;
            apLine.AcctSeed__Expense_GL_Account__c =  glAccount.Id;
            apLine.Expense__c=expList[0].id;
            apLine.AcctSeed__GL_Account_Variable_2__c = objGLV2.Id;
            apLine.AcctSeed__GL_Account_Variable_3__c = objGLV3.Id;
            apLine.Matter__c = matter.id;
            //apLine.AcctSeed__Project__c = listProject[0].id;
            // apLine.Expense_Type__c = type1.id;
            apLines.add(apLine);
            
            apLine = new AcctSeed__Account_Payable_Line__c();
            apLine.AcctSeed__Account_Payable__c = ap.Id;
            apLine.AcctSeed__Amount__c = 25;
            apLine.AcctSeed__Expense_GL_Account__c =  glAccount.Id;
            apLine.Expense__c=expList[0].id;
            apLine.AcctSeed__GL_Account_Variable_2__c = objGLV2.Id;
            apLine.AcctSeed__GL_Account_Variable_3__c = objGLV3.Id;
            apLine.Matter__c = matter.id;
            // apLine.AcctSeed__Project__c = listProject[0].id;
            //apLine.Expense_Type__c = type1.id;
            apLines.add(apLine);
        }
        
        insert apLines;
        
        // Call the post service
        AcctSeed.PostResult[] postResults = AcctSeed.AccountPayablePostService.postAccountPayables(payables);
        
        
        
    }
    
    @isTest
    static void testMethod1(){
        list<AcctSeed__GL_Account__c> lstGLAccount = [Select Id from AcctSeed__GL_Account__c where name='1200-Client Costs Advanced'];
        
        list<AcctSeed__Account_Payable__c> lstAccountPayable = new List<AcctSeed__Account_Payable__c>();
        //list<AcctSeed__Project_Task__c> lstProjectTask = [Select Id from AcctSeed__Project_Task__c];
        
        string accPeriodName = String.valueOf(System.today().year())+'-'+(string.valueOf(system.today().month()).length() ==1 ?'0'+String.valueOf(system.today().month()) : String.valueOf(system.today().month()));        
        system.debug('**accPeriodName**'+accPeriodName);        
        list<AcctSeed__Accounting_Period__c> periodList = new list<AcctSeed__Accounting_Period__c>();        
        periodList = [select Id,name from AcctSeed__Accounting_Period__c where name =: accPeriodName];
        
        Account ObjAccount = new Account();
        ObjAccount.Name = 'Test Account 1';
        ObjAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Provider Contact Information').getRecordTypeId();
        ObjAccount.AcctSeed__Accounting_Active__c = True;
        ObjAccount.AcctSeed__Accounting_Type__c = 'Vendor';
        ObjAccount.litify_pm__Last_Name__c='test';
        ObjAccount.Matter_Vendor__c =true;
        insert ObjAccount;
        
        litify_pm__Expense_Type__c objExpType= new litify_pm__Expense_Type__c();
        objExpType.Name='test exp type';
        objExpType.Category__c='Hard Cost';
        insert objExpType;
        
        Test.startTest();
        AcctSeed__Account_Payable__c objPayable = new AcctSeed__Account_Payable__c();
        objPayable.AcctSeed__Vendor__c = ObjAccount.Id;
        objPayable.AcctSeed__Payee_Reference__c = 'Test Payable 123';
        objPayable.AcctSeed__Accounting_Period__c = periodList[0].Id;
        objPayable.Origin__c = 'AP';
        objPayable.AcctSeed__Status__c='Approved';
        objPayable.Expense_Type__c='Matter';
        lstAccountPayable.add(objPayable);
        insert objPayable;
        
        id projectTaskId;
        List<AcctSeed__Project__c> lstProject = [select id,Matter__c,(select id,Name,AcctSeed__Sort_Order__c,AcctSeed__Labor_GL_Account__c from  AcctSeed__Project_Tasks__r where name='Default Task') from  AcctSeed__Project__c];
        if(lstProject.size()>0){
            for(AcctSeed__Project__c objProject:lstProject){
                for(AcctSeed__Project_Task__c pTask :objProject.AcctSeed__Project_Tasks__r ){
                    projectTaskId= pTask.Id;
                }
            }            
            
        }
        list<AcctSeed__Accounting_Variable__c> listGLV2 = [select id from AcctSeed__Accounting_Variable__c where name='Location var'];
        AcctSeed__Account_Payable_Line__c apLine = new AcctSeed__Account_Payable_Line__c();
        apLine.AcctSeed__Account_Payable__c = objPayable.Id;
        apLine.AcctSeed__Amount__c = 45;
        apLine.AcctSeed__Expense_GL_Account__c =  lstGLAccount[0].Id;// 1200-Client Costs Advanced
        apLine.AcctSeed__Project__c = lstProject[0].Id;
        apLine.AcctSeed__Project_Task__c = projectTaskId;
        apLine.AcctSeed__GL_Account_Variable_2__c=listGLV2[0].Id;
        apLine.Expense_Type__c= objExpType.id;
        insert apLine;
        
        
        
        // update apline;        
        Delete apLine;
        
        Test.stopTest();
        
    }
    
    @isTest
    static void testMethod2(){
        list<AcctSeed__GL_Account__c> lstGLAccount = [Select Id from AcctSeed__GL_Account__c where name='1200-Client Costs Advanced'];
        list<AcctSeed__Account_Payable__c> lstAccountPayable = new List<AcctSeed__Account_Payable__c>();
        list<AcctSeed__Project__c> lstProject = [Select Id,(select id from AcctSeed__Project_Tasks__r) from AcctSeed__Project__c];
        list<AcctSeed__Project_Task__c> lstProjectTask = [Select Id from AcctSeed__Project_Task__c];
        
        string accPeriodName = String.valueOf(System.today().year())+'-'+(string.valueOf(system.today().month()).length() ==1 ?'0'+String.valueOf(system.today().month()) : String.valueOf(system.today().month()));        
        system.debug('**accPeriodName**'+accPeriodName);        
        list<AcctSeed__Accounting_Period__c> periodList = new list<AcctSeed__Accounting_Period__c>();        
        periodList = [select Id,name from AcctSeed__Accounting_Period__c where name =: accPeriodName];
        
        Account ObjAccount = new Account();
        ObjAccount.Name = 'Test Account 1';
        ObjAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Provider Contact Information').getRecordTypeId();
        ObjAccount.AcctSeed__Accounting_Active__c = True;
        ObjAccount.AcctSeed__Accounting_Type__c = 'Litify Individual';
        ObjAccount.litify_pm__Last_Name__c='test';
        ObjAccount.Matter_Vendor__c =true;
        insert ObjAccount;
        
        
        litify_pm__Expense_Type__c objExpType= new litify_pm__Expense_Type__c();
        objExpType.Name='test exp type';
        objExpType.Category__c='Hard Cost';
        insert objExpType;
        
        Test.startTest();
        AcctSeed__Account_Payable__c objPayable = new AcctSeed__Account_Payable__c();
        objPayable.AcctSeed__Vendor__c = ObjAccount.Id;
        objPayable.AcctSeed__Payee_Reference__c = 'Test Payable 123';
        objPayable.AcctSeed__Accounting_Period__c = periodList[0].Id;
        objPayable.Origin__c = 'Litify';
        objPayable.Expense_Type__c='Matter';
        objPayable.AcctSeed__Status__c='Approved';
        lstAccountPayable.add(objPayable);
        insert objPayable;
        
        AcctSeed__Account_Payable_Line__c apLine = new AcctSeed__Account_Payable_Line__c();
        apLine.AcctSeed__Account_Payable__c = objPayable.Id;
        apLine.AcctSeed__Amount__c = 45;
        apLine.AcctSeed__Expense_GL_Account__c = lstGLAccount[0].Id;// 1200-Client Costs Advanced
        apLine.AcctSeed__Project__c = lstProject[0].Id;
        // apLine.AcctSeed__Project_Task__c = lstProject[0].AcctSeed__Project_Tasks__r[0].Id;
        apLine.Expense_Type__c= objExpType.id;
        insert apLine;
        
        List<litify_pm__Expense__c> expList = new List<litify_pm__Expense__c>([select id,Stage__c from litify_pm__Expense__c]);
        expList[0].Stage__c='Approved';
        update expList[0];
        
        apLine.AcctSeed__Amount__c = 50;
        update apLine;
        //AcctSeed.PostResult[] postResults = AcctSeed.AccountPayablePostService.postAccountPayables(lstAccountPayable);
        
        Test.stopTest();
        
    }
    
}